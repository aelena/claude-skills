#!/usr/bin/env python3
"""seo-geo-audit: derive CSV and SARIF from the canonical audit JSON.

Usage:
  render-formats.py AUDIT.json [--csv [PATH]] [--sarif [PATH]]
                               [--outdir DIR] [--no-validate] [--quiet]

The JSON described by schema/audit-result.schema.json is the single authored
artifact. CSV and SARIF are projections of it, produced here rather than
written by hand, so the three outputs cannot drift apart.

Validation runs by default and exits 1 on failure. It enforces the rules in
checks/scoring.md mechanically -- the per-check-ID ladder, the arithmetic, the
grade band, and the rule that a check may not be both a finding and N/A. A
score that cannot be reproduced from its own findings is a bug, not a nuance.

Python 3.8+, standard library only.
"""

import argparse
import csv
import json
import os
import sys

SCHEMA_VERSION = "1.0"

# checks/scoring.md -- severity x prevalence ladder, keyed by tier floor.
LADDER = {
    "high":   {1: -8, 2: -12, 6: -16},
    "medium": {1: -3, 2: -5,  6: -6},
    "low":    {1: -1, 2: -2,  6: -2},
    "info":   {1: 0,  2: 0,   6: 0},
}

GRADE_BANDS = [
    (95, "A+"), (90, "A"), (85, "A-"), (80, "B+"), (75, "B"), (70, "B-"),
    (65, "C+"), (60, "C"), (55, "C-"), (50, "D"), (0, "F"),
]

SARIF_LEVEL = {"high": "error", "medium": "warning", "low": "note", "info": "none"}


def expected_deduction(severity, count):
    tiers = LADDER.get(severity)
    if tiers is None:
        return None
    if count >= 6:
        return tiers[6]
    if count >= 2:
        return tiers[2]
    return tiers[1]


def expected_grade(score):
    for floor, grade in GRADE_BANDS:
        if score >= floor:
            return grade
    return "F"


def validate(doc):
    """Return a list of human-readable problems. Empty list means valid."""
    errs = []

    if doc.get("schema_version") != SCHEMA_VERSION:
        errs.append("schema_version is %r, expected %r"
                    % (doc.get("schema_version"), SCHEMA_VERSION))

    for key in ("audited_at", "target", "framework", "scores", "findings"):
        if key not in doc:
            errs.append("missing required key: %s" % key)
    if errs:
        return errs

    findings = doc.get("findings") or []
    unverified = doc.get("unverified") or []
    not_applicable = doc.get("not_applicable") or []

    # A check ID is charged once. Duplicates mean per-occurrence scoring crept
    # back in, which is what makes scores incomparable between sites.
    seen = {}
    for f in findings:
        fid = f.get("id")
        if fid in seen:
            errs.append("check %s appears %d times in findings; scoring.md charges "
                        "a check ID once, with prevalence carried by 'count'"
                        % (fid, seen[fid] + 1))
        seen[fid] = seen.get(fid, 0) + 1

    other_ids = {u.get("id") for u in unverified} | {n.get("id") for n in not_applicable}
    for fid in seen:
        if fid in other_ids:
            errs.append("check %s is both a finding and unverified/not-applicable; "
                        "it must be exactly one" % fid)

    for f in findings:
        fid = f.get("id", "<no id>")
        sev = f.get("severity")
        count = f.get("count")
        ded = f.get("deduction")

        if sev not in LADDER:
            errs.append("%s: severity %r is not one of %s" % (fid, sev, sorted(LADDER)))
            continue
        if not isinstance(count, int) or count < 1:
            errs.append("%s: count must be an integer >= 1, got %r" % (fid, count))
            continue
        if not isinstance(ded, int):
            errs.append("%s: deduction must be an integer, got %r" % (fid, ded))
            continue

        want = expected_deduction(sev, count)
        if ded != want:
            errs.append("%s: deduction %d does not match the ladder -- severity %s "
                        "with %d occurrence(s) is %d (see checks/scoring.md)"
                        % (fid, ded, sev, count, want))

        if f.get("category") not in ("seo", "geo"):
            errs.append("%s: category must be 'seo' or 'geo', got %r"
                        % (fid, f.get("category")))

        for o in f.get("occurrences") or []:
            if not o.get("file"):
                errs.append("%s: an occurrence has no 'file'" % fid)

    # Score must be reproducible from the findings it claims.
    for cat in ("seo", "geo"):
        block = (doc.get("scores") or {}).get(cat)
        if not block:
            continue
        charged = sum(f.get("deduction", 0) for f in findings
                      if f.get("category") == cat and isinstance(f.get("deduction"), int))
        want_score = max(0, 100 + charged)
        got_score = block.get("score")
        if got_score != want_score:
            errs.append("%s score is %r but its findings sum to %d, giving %d "
                        "(100 %+d, floored at 0)"
                        % (cat, got_score, charged, want_score, charged))
        if isinstance(got_score, int):
            want_grade = expected_grade(got_score)
            if block.get("grade") != want_grade:
                errs.append("%s grade is %r but score %d falls in band %r"
                            % (cat, block.get("grade"), got_score, want_grade))

        n_unver = len([u for u in unverified if u.get("category") == cat])
        if block.get("unverified") is not None and block["unverified"] != n_unver:
            errs.append("%s scores.unverified is %r but %d unverified entries carry "
                        "that category" % (cat, block["unverified"], n_unver))
        n_na = len([n for n in not_applicable if n.get("category") == cat])
        if block.get("na") is not None and block["na"] != n_na:
            errs.append("%s scores.na is %r but %d not_applicable entries carry that "
                        "category" % (cat, block["na"], n_na))

    return errs


CSV_FIELDS = [
    "site", "target", "audited_at", "category", "category_grade", "category_score",
    "status", "check_id", "severity", "deduction", "occurrence_count", "title",
    "file", "line", "detail",
]


def rows_for_csv(doc):
    site = doc.get("site_name") or doc.get("target") or ""
    target = doc.get("target", "")
    when = doc.get("audited_at", "")
    scores = doc.get("scores") or {}

    def cat_bits(cat):
        b = scores.get(cat) or {}
        return b.get("grade", ""), b.get("score", "")

    out = []

    for f in doc.get("findings") or []:
        cat = f.get("category", "")
        grade, score = cat_bits(cat)
        for o in (f.get("occurrences") or [{}]):
            out.append({
                "site": site, "target": target, "audited_at": when,
                "category": cat, "category_grade": grade, "category_score": score,
                "status": "finding",
                "check_id": f.get("id", ""), "severity": f.get("severity", ""),
                "deduction": f.get("deduction", ""),
                "occurrence_count": f.get("count", ""),
                "title": f.get("title", ""),
                "file": o.get("file", ""), "line": o.get("line", ""),
                "detail": o.get("detail", "") or f.get("description", ""),
            })

    for u in doc.get("unverified") or []:
        cat = u.get("category", "")
        grade, score = cat_bits(cat)
        occ = u.get("occurrences") or [{}]
        for o in occ:
            out.append({
                "site": site, "target": target, "audited_at": when,
                "category": cat, "category_grade": grade, "category_score": score,
                "status": "unverified",
                "check_id": u.get("id", ""), "severity": "", "deduction": 0,
                "occurrence_count": len(u.get("occurrences") or []),
                "title": u.get("title", ""),
                "file": o.get("file", ""), "line": o.get("line", ""),
                "detail": u.get("reason", ""),
            })

    for n in doc.get("not_applicable") or []:
        cat = n.get("category", "")
        grade, score = cat_bits(cat)
        out.append({
            "site": site, "target": target, "audited_at": when,
            "category": cat, "category_grade": grade, "category_score": score,
            "status": "not_applicable",
            "check_id": n.get("id", ""), "severity": "", "deduction": 0,
            "occurrence_count": 0, "title": n.get("title", ""),
            "file": "", "line": "", "detail": n.get("why", ""),
        })

    return out


def write_csv(doc, path):
    rows = rows_for_csv(doc)
    with open(path, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=CSV_FIELDS)
        w.writeheader()
        for r in rows:
            w.writerow(r)
    return len(rows)


def build_sarif(doc):
    rules, results = [], []
    seen_rules = set()

    def add_rule(cid, title, desc, severity, category, tags):
        if cid in seen_rules:
            return
        seen_rules.add(cid)
        rules.append({
            "id": cid,
            "name": cid.replace("-", ""),
            "shortDescription": {"text": title or cid},
            "fullDescription": {"text": desc or title or cid},
            "defaultConfiguration": {"level": SARIF_LEVEL.get(severity, "note")},
            "properties": {"category": category, "severity": severity or "info",
                           "tags": tags},
        })

    def locations(occ):
        locs = []
        for o in occ or []:
            if not o.get("file"):
                continue
            phys = {"artifactLocation": {"uri": o["file"].replace("\\", "/")}}
            if isinstance(o.get("line"), int) and o["line"] >= 1:
                phys["region"] = {"startLine": o["line"]}
            locs.append({"physicalLocation": phys})
        return locs

    for f in doc.get("findings") or []:
        cid = f.get("id", "UNKNOWN")
        sev = f.get("severity", "info")
        cat = f.get("category", "")
        add_rule(cid, f.get("title"), f.get("description"), sev, cat, [cat, sev])
        msg = f.get("title", cid)
        if f.get("count", 1) > 1:
            msg = "%s (%d occurrences)" % (msg, f["count"])
        if f.get("fix"):
            msg = "%s -- fix: %s" % (msg, f["fix"])
        res = {
            "ruleId": cid,
            "level": SARIF_LEVEL.get(sev, "note"),
            "message": {"text": msg},
            "properties": {"deduction": f.get("deduction", 0), "status": "finding"},
        }
        locs = locations(f.get("occurrences"))
        if locs:
            res["locations"] = locs
        results.append(res)

    # Unverified checks ship as notes: visible in review, never blocking, and
    # explicitly not the same thing as a failure.
    for u in doc.get("unverified") or []:
        cid = u.get("id", "UNKNOWN")
        cat = u.get("category", "")
        add_rule(cid, u.get("title"), u.get("reason"), "info", cat, [cat, "unverified"])
        msg = "UNVERIFIED: %s -- %s" % (u.get("title", cid), u.get("reason", ""))
        if u.get("how_to_verify"):
            msg = "%s To settle: %s" % (msg, u["how_to_verify"])
        res = {
            "ruleId": cid,
            "level": "note",
            "message": {"text": msg},
            "properties": {"deduction": 0, "status": "unverified"},
        }
        locs = locations(u.get("occurrences"))
        if locs:
            res["locations"] = locs
        results.append(res)

    scores = doc.get("scores") or {}
    return {
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "version": "2.1.0",
        "runs": [{
            "tool": {"driver": {
                "name": "seo-geo-audit",
                "version": doc.get("skill_version", "0.0.0"),
                "informationUri": "https://github.com/aelena/claude-skills",
                "rules": rules,
            }},
            "automationDetails": {"id": "seo-geo-audit/%s" % doc.get("target", "")},
            "properties": {
                "seoScore": (scores.get("seo") or {}).get("score"),
                "seoGrade": (scores.get("seo") or {}).get("grade"),
                "geoScore": (scores.get("geo") or {}).get("score"),
                "geoGrade": (scores.get("geo") or {}).get("grade"),
                "note": "SARIF carries no category score; grades are mirrored here "
                        "as run properties. The JSON remains authoritative.",
            },
            "results": results,
        }],
    }


def main(argv=None):
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("audit", help="canonical audit JSON")
    ap.add_argument("--csv", nargs="?", const=True, default=None, metavar="PATH")
    ap.add_argument("--sarif", nargs="?", const=True, default=None, metavar="PATH")
    ap.add_argument("--outdir", default=None)
    ap.add_argument("--no-validate", action="store_true")
    ap.add_argument("--quiet", action="store_true")
    args = ap.parse_args(argv)

    try:
        with open(args.audit, encoding="utf-8") as fh:
            doc = json.load(fh)
    except FileNotFoundError:
        print("render-formats: no such file: %s" % args.audit, file=sys.stderr)
        return 2
    except json.JSONDecodeError as e:
        print("render-formats: %s is not valid JSON: %s" % (args.audit, e),
              file=sys.stderr)
        return 2

    if not args.no_validate:
        errs = validate(doc)
        if errs:
            print("render-formats: %s failed validation (%d problem%s):"
                  % (args.audit, len(errs), "" if len(errs) == 1 else "s"),
                  file=sys.stderr)
            for e in errs:
                print("  - %s" % e, file=sys.stderr)
            print("", file=sys.stderr)
            print("Nothing was written. Fix the audit JSON, or pass --no-validate "
                  "to render anyway.", file=sys.stderr)
            return 1
        if not args.quiet:
            print("validation: OK (scores reproduce from findings)")

    base = os.path.splitext(os.path.basename(args.audit))[0]
    outdir = args.outdir or os.path.dirname(os.path.abspath(args.audit))
    if args.outdir:
        os.makedirs(outdir, exist_ok=True)

    if args.csv is None and args.sarif is None:
        if not args.quiet:
            print("no output format requested; pass --csv and/or --sarif")
        return 0

    if args.csv is not None:
        path = args.csv if isinstance(args.csv, str) else os.path.join(outdir, base + ".csv")
        n = write_csv(doc, path)
        if not args.quiet:
            print("csv:   %s (%d rows)" % (path, n))

    if args.sarif is not None:
        path = args.sarif if isinstance(args.sarif, str) else os.path.join(outdir, base + ".sarif")
        sarif = build_sarif(doc)
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(sarif, fh, indent=2)
            fh.write("\n")
        if not args.quiet:
            print("sarif: %s (%d results)" % (path, len(sarif["runs"][0]["results"])))

    return 0


if __name__ == "__main__":
    sys.exit(main())
