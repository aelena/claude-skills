# Functional C# patterns to introduce

The construct table tells you *what* maps to what. This file tells you *which patterns to apply* on top of the literal translation, so the result feels native to functional C# rather than VBA wearing a costume.

## 1. Records over classes for data

Anything that is "a piece of data" should be a `record`, not a class. Records get value equality, deconstruction, `with` expressions, and immutability for free.

```csharp
// data
record InvoiceRow(string Customer, decimal Amount, DateOnly Date);

// behavior on data — as static methods, not instance methods
static class InvoiceRowOps
{
    public static InvoiceRow ApplyTax(this InvoiceRow row, decimal rate) =>
        row with { Amount = row.Amount * (1 + rate) };
}
```

`record` types are the right default. Reach for `class` only when you need reference identity (rare) or inheritance with state (rarer).

## 2. Pure functions on static classes

The functional core lives in `static` methods on `static` classes. No constructors, no `this`, no instance state. Inputs in, outputs out.

```csharp
public static class Pricing
{
    public static decimal LineTotal(decimal unit, int qty, decimal taxRate) =>
        unit * qty * (1 + taxRate);

    public static decimal OrderTotal(IEnumerable<(decimal unit, int qty)> lines, decimal taxRate) =>
        lines.Sum(l => LineTotal(l.unit, l.qty, taxRate));
}
```

Pure functions are testable without mocks. They are the **payoff** of the migration.

## 3. LINQ over loops

Almost every VBA `For` / `For Each` is one of these LINQ shapes:

| Loop intent | LINQ |
|---|---|
| Transform every element | `.Select(x => ...)` |
| Keep some elements | `.Where(x => ...)` |
| Reduce to a single value | `.Sum()`, `.Max()`, `.Aggregate(seed, (acc, x) => ...)` |
| Group | `.GroupBy(x => x.Key)` |
| Find first | `.First(x => ...)` / `.FirstOrDefault(x => ...)` |
| Check existence | `.Any(x => ...)` |
| Build a lookup | `.ToDictionary(x => x.Key, x => x.Value)` |

When in doubt, **if you wrote a `for` loop, you missed a LINQ method.** The exception is performance-critical hot paths over millions of items, where a `foreach` over `Span<T>` may be measurably faster. In a former-VBA codebase, this exception is rare.

## 4. Pattern matching over Select Case

Switch *expressions* (not statements) are how functional C# does case analysis. Every branch produces a value; the compiler checks exhaustiveness when matching on enums or sealed hierarchies.

```csharp
var category = amount switch
{
    < 100      => "small",
    < 1_000    => "medium",
    < 10_000   => "large",
    _          => "huge"
};

var label = invoice switch
{
    { IsPaid: true }                       => "settled",
    { Date: var d } when d < today.AddDays(-30) => "overdue",
    _                                      => "open"
};
```

Pattern matching also handles records elegantly:

```csharp
var summary = result switch
{
    Success(var value)        => $"OK: {value}",
    Failure(var err)          => $"FAIL: {err.Message}",
};
```

## 5. Result\<T, Error\> over On Error

Replace VBA error handling with explicit `Result` types. Several libraries provide this; you can also hand-roll one in 20 lines.

```csharp
// hand-rolled, no dependencies
public abstract record Result<T>
{
    public sealed record Ok(T Value)        : Result<T>;
    public sealed record Err(string Reason) : Result<T>;
}

public static Result<decimal> Parse(string s) =>
    decimal.TryParse(s, out var d)
        ? new Result<decimal>.Ok(d)
        : new Result<decimal>.Err($"not a number: {s}");
```

Then chain with pattern matching, or use a small helper:

```csharp
public static Result<U> Map<T, U>(this Result<T> r, Func<T, U> f) =>
    r switch
    {
        Result<T>.Ok(var v)  => new Result<U>.Ok(f(v)),
        Result<T>.Err(var e) => new Result<U>.Err(e),
        _                    => throw new InvalidOperationException()
    };
```

For a richer experience, use `FluentResults`, `LanguageExt`, or `OneOf`. They are all good. Pick one and be consistent.

## 6. Pipelines over nesting

VBA tends to nest: `Trim(UCase(Left(s, 5)))`. Functional C# prefers to read top-to-bottom.

```csharp
var result = source
    .Where(x => x.IsValid)
    .Select(x => x.ToCanonical())
    .GroupBy(x => x.Category)
    .Select(g => new Summary(g.Key, g.Sum(x => x.Amount)))
    .OrderByDescending(s => s.Amount)
    .ToList();
```

Each line is one transformation. The shape of the data flows downward. Refactoring is local: change one line, the rest still works.

## 7. Immutable updates with `with`

Records have a `with` expression that returns a new record with some fields changed. Use it everywhere instead of mutation.

```csharp
var updated = invoice with { Amount = invoice.Amount + adjustment };
```

This is the C# equivalent of "set this field" — but the original `invoice` is untouched, which means no caller is surprised.

## 8. Higher-order functions

Pass functions as parameters when behavior varies. Don't write three near-identical methods.

```csharp
public static decimal SumWhere(IEnumerable<InvoiceRow> rows, Func<InvoiceRow, bool> predicate) =>
    rows.Where(predicate).Sum(r => r.Amount);

// usage
var paid    = SumWhere(rows, r => r.IsPaid);
var overdue = SumWhere(rows, r => r.Date < today.AddDays(-30));
```

VBA didn't really have first-class functions. C# does. Use them.

## 9. Composition root pattern

The **only** place where I/O, COM, and other side effects happen is at the top of `Main` (or the request handler, or the test runner). Everything below it is pure.

```csharp
static void Main()
{
    // boundary: read
    var rows = ExcelReader.LoadInvoices("input.xlsx");

    // pure: transform
    var summary = InvoiceSummary.From(rows);

    // boundary: write
    ConsoleWriter.Print(summary);
    ExcelWriter.WriteSummary("output.xlsx", summary);
}
```

This is the single most valuable pattern to bring into a former-VBA codebase. It makes the pure core testable, the side effects auditable, and the logic readable.

## 10. Async at the boundary, sync in the core

If the original VBA had network or disk I/O, the C# version should make those calls `async`. But **only at the boundary** — the pure functions should stay synchronous. Mixing `async` into pure functions complicates them for no benefit.

```csharp
async Task Main()
{
    var rows    = await SqlReader.LoadInvoicesAsync(connectionString);  // boundary, async
    var summary = InvoiceSummary.From(rows);                            // pure, sync
    await SqlWriter.SaveSummaryAsync(connectionString, summary);        // boundary, async
}
```

## 11. Version-gated idioms: .NET 8 vs .NET 10

Everything above compiles on both targets. A few VBA shapes have a shorter, clearer form on .NET 10 (C# 14), and the translation must use the form its target supports. Each pair below was compiled against both. The .NET 10 column does not build on `net8.0`.

| VBA shape | .NET 8 (C# 12) | .NET 10 (C# 14) |
|---|---|---|
| `dict(k) = dict(k) + 1` (count per key) | `.GroupBy(r => r.Customer).ToDictionary(g => g.Key, g => g.Count())` | `.CountBy(r => r.Customer)` |
| `dict(k) = dict(k) + amt` (sum per key) | `.GroupBy(r => r.Customer).ToDictionary(g => g.Key, g => g.Sum(r => r.Amount))` | `.AggregateBy(r => r.Customer, 0m, (total, r) => total + r.Amount)` |
| `For i = 1 To n` that needs the position | `.Select((r, i) => ...)` | `.Index().Select(x => ... x.Index ... x.Item ...)` |
| `VLOOKUP(..., FALSE)` / `Match` that tolerates a miss | `.GroupJoin(...).SelectMany(x => x.cs.DefaultIfEmpty(), ...)` | `.LeftJoin(customers, r => r.Customer, c => c.Name, (r, c) => (r, c?.Region ?? "#N/A"))` |
| Helper property on a type you don't own | an extension *method*: `static bool IsLarge(this InvoiceRow row)` | an extension *property* in an `extension(InvoiceRow row) { public bool IsLarge => ...; }` block |
| `Property Let` with validation | an explicit backing field | the `field` keyword: `public decimal Value { get; init => field = value >= 0 ? value : throw new ArgumentOutOfRangeException(nameof(value)); }` |
| `If Not obj Is Nothing Then obj.X = v` (boundary code only) | `if (obj is not null) obj.X = v;` | `obj?.X = v;` |

`CountBy`, `AggregateBy` and `Index` arrived in .NET 9, so they are absent on .NET 8. `CountBy` and `AggregateBy` return `KeyValuePair` sequences; add `.ToDictionary()` when the caller needs a lookup. `LeftJoin` passes `null` for a missing inner element, and that `null` is the `#N/A` the VBA was checking for: map it to a value or a `Result` error explicitly, never let it leak.

Collection expressions (`[45, 90, 120]` for `Array(45, 90, 120)`), primary constructors and `DateOnly` work on both targets.
