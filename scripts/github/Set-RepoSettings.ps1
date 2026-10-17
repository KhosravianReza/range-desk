<#
.SYNOPSIS
Applies the `main` ruleset and the merge settings to the GitHub repo.

.DESCRIPTION
Creates or updates the ruleset in .github/rulesets/main.json (matched by name) and sets the merge
settings: squash merge only (title and body from the pull request), merged branches deleted.
The JSON is the source of truth: edit it and re-run; changes made in the GitHub UI are overwritten.
Dry run by default; -Apply changes the repo and prints the rules now in effect on main.

.EXAMPLE
.\scripts\github\Set-RepoSettings.ps1
.\scripts\github\Set-RepoSettings.ps1 -Apply
#>
param(
    [switch] $Apply
)
. (Join-Path $PSScriptRoot 'Common.ps1')

$repo = Get-Repo
$rulesetPath = Join-Path $PSScriptRoot '..\..\.github\rulesets\main.json'
$ruleset = Get-Content $rulesetPath -Raw -Encoding UTF8 | ConvertFrom-Json

# Upsert by name: GitHub identifies a ruleset by its ID, the JSON only by its name.
$existing = @(Invoke-Gh api "repos/$repo/rulesets" | ConvertFrom-Json) | Where-Object { $_.name -eq $ruleset.name }
$ruleTypes = ($ruleset.rules | ForEach-Object { $_.type }) -join ', '
if ($existing) { Write-Host "update: ruleset '$($ruleset.name)' (#$($existing.id))  [$ruleTypes]" -ForegroundColor Cyan }
else { Write-Host "create: ruleset '$($ruleset.name)'  [$ruleTypes]" -ForegroundColor Cyan }

$mergeSettings = [ordered]@{
    allow_squash_merge = 'true'; allow_merge_commit = 'false'; allow_rebase_merge = 'false'
    delete_branch_on_merge = 'true'; squash_merge_commit_title = 'PR_TITLE'; squash_merge_commit_message = 'PR_BODY'
}
Write-Host "set:    $(($mergeSettings.Keys | ForEach-Object { "$_=$($mergeSettings[$_])" }) -join ', ')" -ForegroundColor Cyan

if (-not $Apply) { Write-Host 'Dry run: nothing was changed. Add -Apply to change the repo.'; return }

if ($existing) { $null = Invoke-Gh api --method PUT "repos/$repo/rulesets/$($existing.id)" --input $rulesetPath }
else { $null = Invoke-Gh api --method POST "repos/$repo/rulesets" --input $rulesetPath }

$fields = @($mergeSettings.Keys | ForEach-Object { @('-F', "$_=$($mergeSettings[$_])") })
$null = Invoke-Gh api --method PATCH "repos/$repo" @fields

$effective = (Invoke-Gh api "repos/$repo/rules/branches/main" --jq '.[].type') -split "`n"
Write-Host "Rules in effect on main: $($effective -join ', ')" -ForegroundColor Green
