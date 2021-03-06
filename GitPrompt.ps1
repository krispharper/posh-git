# Inspired by Mark Embling
# http://www.markembling.info/view/my-ideal-powershell-prompt-with-git-integration

$global:GitPromptSettings = New-Object PSObject -Property @{
    DefaultForegroundColor    = $Host.UI.RawUI.ForegroundColor

    BeforeText                = "`b$([char]0xE0B0) "
    BeforeForegroundColor     = [ConsoleColor]::DarkCyan
    BeforeBackgroundColor     = [ConsoleColor]::Cyan
    DelimText                 = " $([char]0xE0B1)"
    DelimForegroundColor      = [ConsoleColor]::DarkCyan
    DelimBackgroundColor      = [ConsoleColor]::Cyan

    AfterText                 = "$([char]0xE0B0)"
    AfterForegroundColor      = [ConsoleColor]::Cyan
    AfterBackgroundColor      = $Host.UI.RawUI.BackgroundColor

    BranchForegroundColor       = [ConsoleColor]::DarkCyan
    BranchBackgroundColor       = [ConsoleColor]::Cyan
    BranchAheadForegroundColor  = [ConsoleColor]::DarkGreen
    BranchAheadBackgroundColor  = [ConsoleColor]::Cyan
    BranchBehindForegroundColor = [ConsoleColor]::DarkRed
    BranchBehindBackgroundColor = [ConsoleColor]::Cyan
    BranchBehindAndAheadForegroundColor = [ConsoleColor]::DarkYellow
    BranchBehindAndAheadBackgroundColor = [ConsoleColor]::Cyan

    BeforeIndexText           = ""
    BeforeIndexForegroundColor= [ConsoleColor]::DarkGreen
    BeforeIndexBackgroundColor= [ConsoleColor]::Cyan

    IndexForegroundColor      = [ConsoleColor]::DarkGreen
    IndexBackgroundColor      = [ConsoleColor]::Cyan

    WorkingForegroundColor    = [ConsoleColor]::DarkRed
    WorkingBackgroundColor    = [ConsoleColor]::Cyan

    UntrackedText             = ' !'
    UntrackedForegroundColor  = [ConsoleColor]::DarkRed
    UntrackedBackgroundColor  = [ConsoleColor]::Cyan

    ShowStatusWhenZero        = $true

    AutoRefreshIndex          = $true

    EnablePromptStatus        = !$Global:GitMissing
    EnableFileStatus          = $true
    RepositoriesInWhichToDisableFileStatus = @( ) # Array of repository paths
    DescribeStyle             = ''

    EnableWindowTitle         = 'posh~git ~ '

    Debug                     = $false
}

$WindowTitleSupported = $true
if (Get-Module NuGet) {
    $WindowTitleSupported = $false
}

function Write-Prompt($Object, $ForegroundColor, $BackgroundColor = -1) {
    if ($BackgroundColor -lt 0) {
        Write-Host $Object -NoNewLine -ForegroundColor $ForegroundColor
    } else {
        Write-Host $Object -NoNewLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }
}

function Write-GitStatus($status) {
    $s = $global:GitPromptSettings
    if ($status -and $s) {
        Write-Prompt $s.BeforeText -BackgroundColor $s.BeforeBackgroundColor -ForegroundColor $s.BeforeForegroundColor

        $branchBackgroundColor = $s.BranchBackgroundColor
        $branchForegroundColor = $s.BranchForegroundColor
        if ($status.BehindBy -gt 0 -and $status.AheadBy -gt 0) {
            # We are behind and ahead of remote
            $branchBackgroundColor = $s.BranchBehindAndAheadBackgroundColor
            $branchForegroundColor = $s.BranchBehindAndAheadForegroundColor
        } elseif ($status.BehindBy -gt 0) {
            # We are behind remote
            $branchBackgroundColor = $s.BranchBehindBackgroundColor
            $branchForegroundColor = $s.BranchBehindForegroundColor
        } elseif ($status.AheadBy -gt 0) {
            # We are ahead of remote
            $branchBackgroundColor = $s.BranchAheadBackgroundColor
            $branchForegroundColor = $s.BranchAheadForegroundColor
        }

        Write-Prompt ("$([char]0xE0A0) " + $status.Branch) -BackgroundColor $branchBackgroundColor -ForegroundColor $branchForegroundColor


        if($s.EnableFileStatus -and $status.HasIndex) {
            Write-Prompt " $([char]0xE0B1)" -BackgroundColor $branchBackgroundColor -ForegroundColor $s.DelimForegroundColor

            Write-Prompt $s.BeforeIndexText -BackgroundColor $s.BeforeIndexBackgroundColor -ForegroundColor $s.BeforeIndexForegroundColor

            if($s.ShowStatusWhenZero -or $status.Index.Added) {
              Write-Prompt " +$($status.Index.Added.Count)" -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Index.Modified) {
              Write-Prompt " ~$($status.Index.Modified.Count)" -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Index.Deleted) {
              Write-Prompt " -$($status.Index.Deleted.Count)" -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }

            if ($status.Index.Unmerged) {
                Write-Prompt " !$($status.Index.Unmerged.Count)" -BackgroundColor $s.IndexBackgroundColor -ForegroundColor $s.IndexForegroundColor
            }

            if($status.HasWorking) {
                Write-Prompt $s.DelimText -BackgroundColor $s.DelimBackgroundColor -ForegroundColor $s.DelimForegroundColor
            }
        }

        if($s.EnableFileStatus -and $status.HasWorking) {
            Write-Prompt " $([char]0xE0B1)" -BackgroundColor $branchBackgroundColor -ForegroundColor $s.DelimForegroundColor

            if($s.ShowStatusWhenZero -or $status.Working.Added) {
              Write-Prompt " +$($status.Working.Added.Count)" -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Working.Modified) {
              Write-Prompt " ~$($status.Working.Modified.Count)" -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.Working.Deleted) {
              Write-Prompt " -$($status.Working.Deleted.Count)" -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }

            if ($status.Working.Unmerged) {
                Write-Prompt " !$($status.Working.Unmerged.Count)" -BackgroundColor $s.WorkingBackgroundColor -ForegroundColor $s.WorkingForegroundColor
            }
        }

        if ($status.HasUntracked) {
            Write-Prompt " $([char]0xE0B1)" -BackgroundColor $branchBackgroundColor -ForegroundColor $s.DelimForegroundColor
            Write-Prompt $s.UntrackedText -BackgroundColor $s.UntrackedBackgroundColor -ForegroundColor $s.UntrackedForegroundColor
        }

        Write-Prompt " " -BackgroundColor $s.UntrackedBackgroundColor -ForegroundColor $s.UntrackedBackgroundColor
        Write-Prompt $s.AfterText -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor

        if ($WindowTitleSupported -and $s.EnableWindowTitle) {
            if( -not $Global:PreviousWindowTitle ) {
                $Global:PreviousWindowTitle = $Host.UI.RawUI.WindowTitle
            }
            $repoName = Split-Path -Leaf (Split-Path $status.GitDir)
            $prefix = if ($s.EnableWindowTitle -is [string]) { $s.EnableWindowTitle } else { '' }
            $Host.UI.RawUI.WindowTitle = "$prefix$repoName [$($status.Branch)]"
        }
    } elseif ( $Global:PreviousWindowTitle ) {
        $Host.UI.RawUI.WindowTitle = $Global:PreviousWindowTitle
    }
}

if(!(Test-Path Variable:Global:VcsPromptStatuses)) {
    $Global:VcsPromptStatuses = @()
}
function Global:Write-VcsStatus { $Global:VcsPromptStatuses | foreach { & $_ } }

# Add scriptblock that will execute for Write-VcsStatus
$Global:VcsPromptStatuses += {
    $Global:GitStatus = Get-GitStatus
    Write-GitStatus $GitStatus
}
