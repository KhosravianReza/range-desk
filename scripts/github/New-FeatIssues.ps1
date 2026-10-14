<#
.SYNOPSIS
Creates one GitHub issue per Feat file of a block.

.DESCRIPTION
Reads docs/specs/Block_<n>/Feat*.md. Per file: title = the H1 without "Feat<y> . ",
labels = the Labels line, milestone "Block <n>", the project, body = spec link + Goal,
"blocked by" = the Feats linked under "Depends on" (also in earlier blocks) that have an issue.
Checks the milestone, labels and project first. Skips Feats whose issue already exists.
Dry run by default; -Apply creates the issues. Stops at the first error.

.EXAMPLE
.\scripts\github\New-FeatIssues.ps1 -Block 1
.\scripts\github\New-FeatIssues.ps1 -Block 1 -Apply
#>
param(
    [Parameter(Mandatory)] [int] $Block,
    [switch] $Apply,
    [string] $Project = 'RangeDesk'
)
. (Join-Path $PSScriptRoot 'Common.ps1')

$repo = Get-Repo
$milestone = "Block $Block"
$specBase = "https://github.com/$repo/blob/main/docs/specs"
$feats = @(Get-ChildItem (Join-Path $SpecRoot "Block_$Block") -Filter 'Feat*.md' |
    ForEach-Object { [int]($_.BaseName -replace '\D', '') } | Sort-Object | ForEach-Object { Read-Feat $Block $_ })
foreach ($feat in $feats) { if (-not $feat.Goal) { throw "$($feat.Name): Goal not found." } }

Assert-Prerequisites $repo $milestone @($feats | ForEach-Object { $_.Labels }) $Project $Apply.IsPresent
$existing = Get-TopLevelIssues $repo

foreach ($feat in $feats) {
    $next = ".\scripts\github\New-SubIssues.ps1 -Block $Block -Feat $($feat.Feat) -Issue"

    # Duplicate detection: an issue with the same title exists already.
    if ($existing.ContainsKey($feat.Title)) {
        $number = $existing[$feat.Title]
        Write-Host "Feat$($feat.Feat): exists as #$number  $($feat.Title)" -ForegroundColor DarkGray
        Write-Host "  next: $next $number"
        continue
    }

    # Dependency links: Feats under "Depends on", in this block or an earlier one.
    $blockedBy = @()
    $depNotes = @()
    foreach ($dep in $feat.DependsOn) {
        $depTitle = (Read-Feat $dep.Block $dep.Feat).Title
        if ($existing.ContainsKey($depTitle)) { $blockedBy += $existing[$depTitle]; $depNotes += "#$($existing[$depTitle])" }
        elseif ($dep.Block -eq $Block) { $depNotes += "Feat$($dep.Feat) (created earlier in this run)" }
        else { $depNotes += "Block $($dep.Block) Feat$($dep.Feat) (no issue: skipped)" }
    }

    Write-Host "Feat$($feat.Feat): create  $($feat.Title)  [$($feat.Labels -join ', ')]" -ForegroundColor Cyan
    if ($depNotes) { Write-Host "  blocked by: $($depNotes -join ', ')" }
    if (-not $Apply) { continue }

    # Relative links don't work in issues: make them absolute.
    $goal = $feat.Goal -replace '\]\(\.\./Block_(\d+)/(Feat\d+\.md)\)', "]($specBase/Block_`$1/`$2)"
    $goal = $goal -replace '\]\((Feat\d+\.md)\)', "]($specBase/Block_$Block/`$1)"
    $bodyFile = New-TemporaryFile
    [IO.File]::WriteAllText($bodyFile.FullName, "**Spec:** $specBase/$($feat.Name)`n`n$goal`n")   # UTF-8, no BOM

    $ghArgs = @('issue', 'create', '--repo', $repo, '--title', $feat.Title, '--body-file', $bodyFile.FullName,
        '--milestone', $milestone, '--project', $Project)
    $feat.Labels | ForEach-Object { $ghArgs += @('--label', $_) }
    if ($blockedBy) { $ghArgs += @('--blocked-by', ($blockedBy -join ',')) }
    try { $url = Invoke-Gh @ghArgs }
    catch { throw "Creating the issue for Feat$($feat.Feat) failed (gh error above). The Feats listed before it were created." }
    finally { Remove-Item $bodyFile.FullName }

    $number = [int]($url -split '/')[-1]
    $existing[$feat.Title] = $number
    Write-Host "  -> #$number   next: $next $number" -ForegroundColor Green
}
if (-not $Apply) { Write-Host 'Dry run: nothing was created. Add -Apply to create.' }
