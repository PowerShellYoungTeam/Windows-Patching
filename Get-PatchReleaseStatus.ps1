Function Get-PatchReleaseStatus{
    <#
    .SYNOPSIS
    Function to check if a Patch/Hotfix has went to machines
    by Steven Wight

    .DESCRIPTION
    Get-PatchReleaseStatus -Hotfix <KB Number> -InputFilename <name of csv. file with hostnames [NO HEADERS]> Default is hostnames.csv -Folderpath <path to input output files> Default -s c:\temp

    .EXAMPLE
    Get-PatchReleaseStatus -Hotfix KB4538461
    #>   
    [CmdletBinding()]
    Param(  
    [Parameter()] [String] [ValidateNotNullOrEmpty()] $Hotfix = "", 
    [Parameter()] [String] [ValidateNotNullOrEmpty()] $InputFilename = ("Hostnames.csv"),
    [Parameter()] [String] [ValidateNotNullOrEmpty()] $FolderPath =("c:\temp\"))
 
    #Input, Output and Error Log Files
    $inputFile = $FolderPath+$InputFilename
    $Outfile = $FolderPath+$Hotfix+"_$(get-date -f yyyy-MM-dd-HH).csv"
    $ErrorLog = $FolderPath+$Hotfix+"_$(get-date -f yyyy-MM-dd-HH)_Errorlog.log" 
 
    #initialise main loop progress counter
    $i = 0
 
    #get computer count for progress counter
    $MachineCount = Import-CSV $InputFile -Header Hostname

    #initialise error counter 
    $ErrorCount=0

    #import hostnames and start loop
        Import-CSV $InputFile -Header Hostname | Foreach-Object{      

        #Clear Variables from last loop
        $PathTest = $hotfixInfo = $hostname = $ProgressActivity = $Null

        #increment progress counter
        $i++

        #Put Hostname into Variable (easier to play with)
        $hostname = $_.Hostname

        #Set progress counter activity string
        $ProgressActivity = "Checking "+$hostname+" for "+$Hotfix+" Number: "+$i+" of "+$MachineCount.count
     
        #update progress counter
        Write-host -ForegroundColor Yellow $ProgressActivity

        #Test Machine is online
        $PathTest = Test-Connection -Computername $hostname -BufferSize 16 -Count 1 -Quiet

        if($PathTest -eq $True) {
            Try {
            $hotfixInfo = (Get-HotFix -ComputerName $hostname -Id $Hotfix -ErrorAction SilentlyContinue)
            }Catch {
            #increase error counter if something not right
            $ErrorCount += 1
            #print error message
            $ErrorMessage = $_.Exception.Message
            $hostname+" "+$ErrorMessage | Out-File $ErrorLog -Force -Append} 
            IF($Null -eq $hotfixInfo  ){
                #build object to use to fill CSV with data
                [pscustomobject][ordered] @{
                    ComputerName =  $hostname
                    Description = "HotFix Not installed"
                    HotfixID = "HotFix Not installed"
                    InstalledBy = "HotFix Not installed"
                    InstallOn = "HotFix Not installed"
                    } | Export-csv -Path $outfile -NoTypeInformation  -Append -Force
            }ELSE{
            #build object to use to fill CSV with data
            [pscustomobject][ordered] @{
            ComputerName =  $hostname
            Description = $hotfixInfo.Description
            HotfixID = $hotfixInfo.HotfixID
            InstalledBy = $hotfixInfo.InstalledBy
            InstallOn = $hotfixInfo.InstallOn
            } | Export-csv -Path $outfile -NoTypeInformation  -Append -Force}
        }ELSE{
         [pscustomobject][ordered] @{
            ComputerName =  $hostname
            Description = "Offline"
            HotfixID = "Offline"
            InstalledBy = "Offline"
            InstallOn = "Offline"
            } | Export-csv -Path $outfile -NoTypeInformation  -Append -Force
        } # end of if Else loop
    }# End of forEach-obeject Loop

    If ($ErrorCount -ge1) {

        Write-host "-----------------"
        Write-Host -ForegroundColor Red "The script execution completed, but with errors."
        Write-host "-----------------"
    }Else{
        Write-host "-----------------"
        Write-Host -ForegroundColor Green "Script execution completed without error. "
        Write-host "-----------------"
    }

} # end of function