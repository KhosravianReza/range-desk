# Shared helpers for New-FeatIssues.ps1 and New-SubIssues.ps1. Dot-sourced by them; not run on its own.

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8   # read gh's UTF-8 output correctly in Windows PowerShell
$SpecRoot = Join-Path $PSScriptRoot '..\..\docs\specs'

function Invoke-Gh {
    # Runs gh; returns stdout as one string; throws if gh fails (gh prints its own error).
    $out = & gh @args
    if ($LASTEXITCODE -ne 0) { throw "gh $($args -join ' ') failed (exit $LASTEXITCODE)." }
    return ($out -join "`n")
}

function Get-Repo {
    return Invoke-Gh repo view --json nameWithOwner --jq .nameWithOwner
}

function Read-Feat([int] $Block, [int] $Feat) {
    # Parses docs/specs/Block_<n>/Feat<y>.md into title, labels, goal, sub-issues and dependencies.
    $name = "Block_$Block/Feat$Feat.md"
    $path = Join-Path $SpecRoot "Block_$Block\Feat$Feat.md"
    if (-not (Test-Path $path)) { throw "Spec not found: $name" }
    $text = Get-Content $path -Raw -Encoding UTF8

    $title = [regex]::Match($text, '(?m)^# Feat\d+\s+\S\s+(.+?)\s*$').Groups[1].Value
    $labelLine = [regex]::Match($text, '(?m)^.*\*\*Labels:\*\*.*$').Value
    $labels = @([regex]::Matches($labelLine, '`([^`]+)`') | ForEach-Object { $_.Groups[1].Value })
    if (-not $title -or $labels.Count -eq 0) { throw "${name}: H1 or Labels line not found." }

    $goal = [regex]::Match($text, '(?s)## Goal\s+(.*?)\s+## ').Groups[1].Value

    $section = [regex]::Match($text, '(?s)## Sub-issues\s+(.*?)(\s+## |\s*$)').Groups[1].Value
    $subIssues = @([regex]::Matches($section, '(?m)^\d+\.\s+(.+?)\.?\s*$') | ForEach-Object {
        [pscustomobject]@{ Title = $_.Groups[1].Value; Core = ($_.Groups[1].Value -match '\(core\b') }
    })

    # Depends on: links to Feat files in this block (FeatN.md) or another (../Block_N/FeatN.md).
    $dependsSection = [regex]::Match($text, '(?s)## Depends on\s+(.*?)(\s+## |\s*$)').Groups[1].Value
    $dependsOn = @([regex]::Matches($dependsSection, '\]\((?:\.\./Block_(\d+)/)?Feat(\d+)\.md\)') | ForEach-Object {
        $depBlock = if ($_.Groups[1].Success) { [int]$_.Groups[1].Value } else { $Block }
        [pscustomobject]@{ Block = $depBlock; Feat = [int]$_.Groups[2].Value }
    })

    # Quote guard: Windows PowerShell passes arguments containing double quotes to gh incorrectly.
    foreach ($t in @($title) + @($subIssues | ForEach-Object { $_.Title })) {
        if ($t.Contains('"')) { throw "${name}: titles can't contain double quotes: $t" }
    }

    return [pscustomobject]@{
        Block = $Block; Feat = $Feat; Name = $name; Title = $title; Labels = $labels
        Goal = $goal; SubIssues = $subIssues; DependsOn = $dependsOn
    }
}

function Assert-Prerequisites([string] $Repo, [string] $Milestone, [string[]] $Labels, [string] $Project, [bool] $Apply) {
    # Preflight: milestone, labels and project must exist. Reports every problem; stops only with -Apply.
    $ErrorActionPreference = 'Continue'   # gh's stderr is redirected below; 'Stop' would turn it into an exception
    $problems = @()

    $milestones = (Invoke-Gh api "repos/$Repo/milestones?state=all&per_page=100" --jq '.[].title') -split "`n"
    if ($milestones -notcontains $Milestone) { $problems += "Milestone '$Milestone' is missing." }

    $existingLabels = (Invoke-Gh label list --repo $Repo --limit 500 --json name --jq '.[].name') -split "`n"
    foreach ($label in ($Labels | Sort-Object -Unique)) {
        if ($existingLabels -notcontains $label) { $problems += "Label '$label' is missing." }
    }

    $projects = & gh project list --owner ($Repo -split '/')[0] --limit 100 --format json --jq '.projects[].title' 2>$null
    if ($LASTEXITCODE -ne 0) { $problems += "Can't read projects: run 'gh auth refresh -s project'." }
    elseif (@($projects) -notcontains $Project) { $problems += "Project '$Project' is missing." }

    if ($problems.Count -eq 0) { Write-Host 'Preflight OK.' -ForegroundColor Green; return }
    $problems | ForEach-Object { Write-Host "Preflight: $_" -ForegroundColor Red }
    if ($Apply) { throw 'Preflight failed: nothing was created.' }
    Write-Host 'Dry run continues despite the preflight problems.' -ForegroundColor Yellow
}

function Get-TopLevelIssues([string] $Repo) {
    # Title -> number of every issue (open or closed) that isn't a sub-issue.
    $map = @{}
    $issues = Invoke-Gh issue list --repo $Repo --state all --limit 1000 --json 'number,title,parent' | ConvertFrom-Json
    foreach ($issue in $issues) {
        if (-not $issue.parent -and -not $map.ContainsKey($issue.title)) { $map[$issue.title] = $issue.number }
    }
    return $map
}
