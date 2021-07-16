# Windows-Patching
 Scripts (or Functions/cmdlets and modules) for use with to assist with patching in Windows boxes

## Get-PatchReleaseStatus
### SYNOPSIS:
    Function to check if a Patch/Hotfix has went to machines listed in a CSV
### DESCRIPTION:
    Get-PatchReleaseStatus -Hotfix <KB Number> -InputFilename <name of csv. file with hostnames [NO HEADERS]> Default is hostnames.csv -Folderpath <path to input output files> Default -s c:\temp

### EXAMPLE:
    Get-PatchReleaseStatus -Hotfix KB4538461
