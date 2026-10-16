# _memoria — Reputation Monitor

Local working notes; untracked on purpose (excluded via `.git/info/exclude`). Kept by the `memoria` skill.

<!-- memoria:resume:start — filled by the memoria SessionStart hook; edits between the markers are overwritten -->
## Resume

- **Last session:** `7f3c2a91-4b6e-4d2a-9c1f-2e8b5d0a6c34` (2026-10-14, startup)
- Resume with: `claude --resume 7f3c2a91-4b6e-4d2a-9c1f-2e8b5d0a6c34` (run from this folder)
- Earlier sessions: `0c4e9a12-77d1-4f0b-9b3e-5a1c2e8f6d40` (2026-10-13)
<!-- memoria:resume:end -->

## Now

Nothing in flight; everything committed and pushed (last: `c4098d2` AI triage).

## Repo

- Remote: github.com/example/reputation-monitor (branch `main`)
- History starts 2026-10-13: the folder had no `.git`, so it was initialised fresh
- `.ignore` in the root is untracked and not ours; leave it
- `config.json` (root) names two real client contacts: remove before ever making the repo public

## Running it

- `docker compose up -d --build` → UI http://localhost:9200, API http://localhost:9201
- `.env` (git-ignored) holds `ADMIN_*`, `JWT_SECRET_KEY`, `SERPAPI_API_KEY` (**free plan: 250 searches/month**), `PERPLEXITY_API_KEY`; no OpenAI key
- Admin is created at startup if none exists (`ensure_bootstrap_admin`)
- Backend tests: `cd src/backend && .venv/Scripts/python -m pytest`; auth tests need `TEST_DATABASE_URL` pointing at a disposable Postgres (`docker run -d --rm -p 55432:5432 -e POSTGRES_PASSWORD=postgres postgres:18`)
- Frontend: `cd src/frontend && npm run typecheck && npm run build`
- Image pulls hang with "Client.Timeout exceeded" → Docker Desktop networking is stuck; quit and relaunch it

## Done

### 2026-10-14
- AI triage per article (sentiment, risk, "why it matters") via Perplexity, batches of 15, VADER fallback; `AI_TRIAGE=0` disables (`c4098d2`)
- AI summary rendered once per group, in the UI language (`a81f3e0`)

### 2026-10-13
- Deps modernised: FastAPI 0.143, SQLAlchemy 2.1 + psycopg 3, Pydantic 2.14, React 19, Vite 8, Node 24
- Auth: bootstrap admin on empty DB, hooks crash on login, bcrypt >72-byte passwords
- Web scans: Google web search with `tbs=qdr:*` returns nothing → time-filtered queries use the News vertical

## Decisions

- Mock LinkedIn/YouTube data stays until a client asks (cost); tag mock rows as demo before any client-facing report
- Never build scrapers for LinkedIn or Reddit (ToS)
- Azure DevOps pipelines: leave for now, convert or delete later

## Open questions

- Positioning: lead with "what AI answer engines say about your clients"? Waiting on two prospect calls.

## Next

1. Scheduler + alerts: Postgres-backed job runner → cheap rule triage → agent only on escalations → human approval → email. `alert_evaluator.py` exists but is never invoked
2. Per-project quotas on SerpAPI/Perplexity calls
3. Fix the process-global LinkedIn/YouTube mock-mode race (flipped per request)
4. Share of voice vs competitors using the triage scores
