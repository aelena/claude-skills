# Copy every skill in this repo into ~\.claude\skills\.
#
# Copies rather than symlinks: creating a symlink on Windows needs either
# Developer Mode or an elevated shell, and this should just work. Re-run after
# a `git pull` to refresh.
#
# Pass skill names to install a subset:  .\install.ps1 llms-txt repo-badges

param([string[]]$Skills)

$ErrorActionPreference = 'Stop'

$RepoDir = $PSScriptRoot
$TargetDir = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $HOME '.claude\skills' }

if (-not $Skills) {
    $Skills = Get-ChildItem -Directory $RepoDir |
        Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
        Select-Object -ExpandProperty Name |
        Sort-Object
}

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

foreach ($skill in $Skills) {
    $src = Join-Path $RepoDir $skill
    $dest = Join-Path $TargetDir $skill

    if (-not (Test-Path (Join-Path $src 'SKILL.md'))) {
        Write-Warning "skip   $skill (no SKILL.md at $src)"
        continue
    }

    if (Test-Path $dest) {
        Remove-Item -Recurse -Force $dest
    }

    # Exclude the local permission files; they are machine-specific.
    Copy-Item -Recurse -Path $src -Destination $dest
    $localClaude = Join-Path $dest '.claude'
    if (Test-Path $localClaude) { Remove-Item -Recurse -Force $localClaude }

    Write-Output "copy   $skill"
}

Write-Output ""
Write-Output "Installed into $TargetDir. Restart Claude Code to pick them up."
