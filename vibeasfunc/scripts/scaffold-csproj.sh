#!/usr/bin/env bash
# vibeasfunc: scaffold a minimal .NET console project for translated VBA.
#
# Usage: scripts/scaffold-csproj.sh <project-name> [target-dir] [--framework net10.0|net8.0]
#
# Targets .NET 10 (LTS) by default when a 10.x SDK is installed, else .NET 8.
# Pass --framework net8.0 when the deployment is pinned to .NET 8; its
# support ends on 10 November 2026.
#
# Creates a clean directory layout with:
#   - a console project (the composition root / boundary)
#   - a class-library project (the pure functional core)
#   - an xunit test project pointing at the core
# Requires `dotnet` on PATH.

set -uo pipefail

USAGE="usage: scaffold-csproj.sh <project-name> [target-dir] [--framework net10.0|net8.0]"

TF=""
args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --framework|-f) TF="${2:?$USAGE}"; shift 2 ;;
    --framework=*)  TF="${1#*=}"; shift ;;
    *)              args+=("$1"); shift ;;
  esac
done

NAME="${args[0]:?$USAGE}"
DIR="${args[1]:-./$NAME}"

if ! command -v dotnet >/dev/null 2>&1; then
  echo "scaffold: 'dotnet' not on PATH. Install the .NET 10 SDK first: https://dotnet.microsoft.com/download" >&2
  exit 2
fi

# Highest installed SDK major version. An SDK can target its own major and
# anything older, so a 10.x SDK builds net8.0 projects too.
SDK_MAJOR="$(dotnet --list-sdks 2>/dev/null | cut -d. -f1 | sort -n | tail -n1)"
SDK_MAJOR="${SDK_MAJOR:-0}"

if [[ -z "$TF" ]]; then
  if (( SDK_MAJOR >= 10 )); then TF=net10.0; else TF=net8.0; fi
fi

case "$TF" in
  net10.0) NEED=10 ;;
  net8.0)  NEED=8 ;;
  *) echo "scaffold: unsupported framework '$TF' (use net10.0 or net8.0)" >&2; exit 2 ;;
esac

if (( SDK_MAJOR < NEED )); then
  echo "scaffold: $TF needs a .NET $NEED SDK or newer; the newest installed is ${SDK_MAJOR}.x" >&2
  exit 2
fi

if [[ -e "$DIR" ]]; then
  echo "scaffold: $DIR already exists, refusing to overwrite" >&2
  exit 3
fi

mkdir -p "$DIR"
cd "$DIR"

dotnet new sln -n "$NAME"

# Pure core
dotnet new classlib -n "${NAME}.Core" -o src/Core -f "$TF"
# Boundary / composition root
dotnet new console -n "${NAME}.App"  -o src/App -f "$TF"
# Tests
dotnet new xunit  -n "${NAME}.Tests" -o tests/Core.Tests -f "$TF"

# Wire references
dotnet sln add src/Core/${NAME}.Core.csproj
dotnet sln add src/App/${NAME}.App.csproj
dotnet sln add tests/Core.Tests/${NAME}.Tests.csproj

dotnet add src/App/${NAME}.App.csproj reference src/Core/${NAME}.Core.csproj
dotnet add tests/Core.Tests/${NAME}.Tests.csproj reference src/Core/${NAME}.Core.csproj

# Add ClosedXML to the App project (boundary I/O for Excel)
dotnet add src/App/${NAME}.App.csproj package ClosedXML

# Optional: add FluentResults to the Core project for Result<T>
# dotnet add src/Core/${NAME}.Core.csproj package FluentResults

# A .NET 10 SDK writes .slnx, older SDKs write .sln.
SLN="$(ls "$NAME".sln* 2>/dev/null | head -n1)"

cat <<EOF

scaffold: created $DIR targeting $TF with structure:

  $NAME/
  ├── ${SLN:-$NAME.sln}
  ├── src/
  │   ├── Core/   ← pure functional core (records, pure functions, no I/O)
  │   └── App/    ← composition root + boundary (ClosedXML, Console)
  └── tests/
      └── Core.Tests/

Next steps:
  - cd $DIR
  - put your input/output records and pure functions in src/Core
  - put ExcelReader/ExcelWriter and Main in src/App
  - put unit tests in tests/Core.Tests (no Excel needed)
  - dotnet build && dotnet test
EOF
