[CmdletBinding()] 
Param (
[Parameter(Position=0, Mandatory=$True)]
[string] $M3UHttpUrl,

[Parameter(Mandatory=$False)]
[string] $TargetDirectoryPathRoot = [Environment]::GetFolderPath("MyMusic")
)

Set-Location $PSScriptRoot

# Directory path name from M3u M3UHttpUrl
# Example: 
# https://archive.org/download/gd73-06-10.sbd.hollister.174.sbeok.shnf/gd73-06-10.sbd.hollister.174.sbeok.shnf_vbr.m3u
$M3uFileName = [System.IO.Path]::GetFileName($M3UHttpUrl)

# Create the target directory path
$TargetDirectoryPath = [io.path]::Combine($TargetDirectoryPathRoot, $M3uFileName)
New-Item -ItemType Directory -Path $TargetDirectoryPath

# Download the m3u file to the target directory path
# Via: https://stackoverflow.com/a/22448954/182742
$TargetM3UFilePath = [io.path]::Combine($TargetDirectoryPath, $M3uFileName)
Invoke-WebRequest $M3UHttpUrl -OutFile $TargetM3UFilePath

# Playlist path
$PlaylistFilePath = [io.path]::Combine($TargetDirectoryPath, "Playlist.m3u")

# Download mp3 files listed in the m3u file
foreach($M3ULine in Get-Content $TargetM3UFilePath) {
  # Example:
  # http://archive.org/download/gd70-05-15.early-late.sbd.97.sbeok.shnf/gd70-5-15D2T03.mp3
  $TargetMP3FileName = [System.IO.Path]::GetFileName($M3ULine)
  $TargetMP3FilePath = [io.path]::Combine($TargetDirectoryPath, $TargetMP3FileName)
  Invoke-WebRequest $M3ULine -OutFile $TargetMP3FilePath -Verbose

  # Playlist update
  Add-Content -Path $PlaylistFilePath -Value $TargetMP3FilePath
}

# All done
Read-Host -Prompt "Press Enter to continue"
