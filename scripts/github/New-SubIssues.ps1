<#
.SYNOPSIS
Creates the sub-issues of one Feat under its existing GitHub issue.

.DESCRIPTION
Reads the numbered list under "## Sub-issues" in docs/specs/Block_<n>/Feat<y>.md and creates one
sub-issue per item under the given issue: the Feat's labels plus `core` for items marked "(core",
milestone "Block <n>", the project. Checks first that the issue's title matches the Feat's H1 and
that the milestone, labels and project exist. Skips sub-issues that already exist under the issue.
Dry run by default; -Apply creates the sub-issues. Stops at the first error.

.EXAMPLE
.\scripts\github\New-SubIssues.ps1 -Block 1 -Feat 3 -Issue 27
.\scripts\github\New-SubIssues.ps1 -Block 1 -Feat 3 -Issue 27 -Apply
#>
param(
    [Parameter(Mandatory)] [int] $Block,
    [Parameter(Mandatory)] [int] $Feat,
    [Parameter(Mandatory)] [int] $Issue,
    [switch] $Apply,
    [string] $Project = 'RangeDesk'
)
. (Join-Path $PSScriptRoot 'Common.ps1')

$repo = Get-Repo
$milestone = "Block $Block"
$spec = Read-Feat $Block $Feat
if ($spec.SubIssues.Count -eq 0) { throw "$($spec.Name): no numbered items under Sub-issues." }

$parent = Invoke-Gh issue view $Issue --repo $repo --json 'title,subIssues' | ConvertFrom-Json
if ($parent.title -ne $spec.Title) { throw "Issue #$Issue is '$($parent.title)', but Feat$Feat is '$($spec.Title)'. Wrong issue number?" }

$neededLabels = @($spec.Labels) + @(if ($spec.SubIssues | Where-Object { $_.Core }) { 'core' })
Assert-Prerequisites $repo $milestone $neededLabels $Project $Apply.IsPresent
$existingTitles = @($parent.subIssues.nodes | ForEach-Object { $_.title })

Write-Host "#${Issue}: $($spec.Title)"
foreach ($subIssue in $spec.SubIssues) {
    # Duplicate detection: a sub-issue with the same title exists already under this issue.
    if ($existingTitles -contains $subIssue.Title) {
        Write-Host "  exists: $($subIssue.Title)" -ForegroundColor DarkGray
        continue
    }
    $labels = @($spec.Labels) + @(if ($subIssue.Core) { 'core' })
    Write-Host "  create: $($subIssue.Title)  [$($labels -join ', ')]" -ForegroundColor Cyan
    if (-not $Apply) { continue }

    $ghArgs = @('issue', 'create', '--repo', $repo, '--parent', "$Issue", '--title', $subIssue.Title,
        '--body', "Spec: https://github.com/$repo/blob/main/docs/specs/$($spec.Name)#sub-issues",
        '--milestone', $milestone, '--project', $Project)
    $labels | ForEach-Object { $ghArgs += @('--label', $_) }
    try { $url = Invoke-Gh @ghArgs }
    catch { throw "Creating '$($subIssue.Title)' failed (gh error above). The sub-issues listed before it were created." }
    Write-Host "    -> #$(($url -split '/')[-1])" -ForegroundColor Green
}
if (-not $Apply) { Write-Host 'Dry run: nothing was created. Add -Apply to create.' }
