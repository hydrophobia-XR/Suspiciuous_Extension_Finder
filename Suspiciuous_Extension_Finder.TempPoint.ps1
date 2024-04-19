<#
    .DISCLAIMER:
    By using this content you agree to the following: This script may be used for legal purposes only. Users take full responsibility 
    for any actions performed using this script. The author accepts no liability for any damage caused by this script.  

    .SYNOPSIS
    This script can be used to do a quick search for files that should receive additional review against a list of provided extensions. 

    .DESCRIPTION
    Certain file types in the environment should receive addional review to help ensure security. This script will take a specified path and scan folders/subfolders and
    compare the file extension of each file found against a list of extensions. If the item is found the full path to the file will be displayed. 
    The complete list will also be written to a txt file in the directory where the script is run, titled SusExtensionSearcher-Results-yyyy-MM-dd.HH.mm.txt. 
	The script will also create a runlog file that contains a summary of who ran the script and when, how many files were found, how long the scan took etc. 
	Note that this is just a simple check for extensions and isn't advanced enough to be able to tell if a file is hiding behind a different extension or multiple extensions. 
	This script can be helpful for a basic check but should NOT be used as your only check. 

    .PARAMETER path
    -Path:  Used to specify what path you want to scan. please be aware of the size of directory and subdirectories you are trying to scan

    .PARAMETER extensions
    -Extensions: This designates a path to the extensions list you are wanting to check. The file should be a list of extensions with each type on a new line. 

    .EXAMPLE
    SusExtensionSearcher.ps1 -path C:\Users\Hydrophobia\Downloads -extensions C:\Users\Hydrophobia\Downloads\extensions.txt

    .NOTES
    Created by: Hydrophobia
    Created Date: 4.2024
    Last Modified Date: 4.19.2024
    Last Modified By: Hydrophobia
    Last Modification Notes: 

    TO-DO: Add better notes and more error checking
		   Add simple check for files that may be using multiple extensions
			
#>

#################################### PARAMETERS ###################################
param (
    [Parameter(Mandatory=$true)]
    [String]$path,

    [Parameter(Mandatory=$true)]
    [String]$extensions
)
################################# EDITABLE VARIABLES #################################

################################# SET COMMON VARIABLES ################################
$ExtensionsList = Get-Content $extensions
$CurrentDate = Get-Date
$CurrentPath = Split-Path -Parent $PSCommandPath
$GetFiles = Get-ChildItem $path -Recurse
$Computer = $Env:ComputerName
$User = $Env:UserName
$RunLog = "$CurrentPath\SusExtensionSearcher-Runlog-$($CurrentDate.ToString("yyyy-MM-dd.HH.mm")).txt"
$Output = "$CurrentPath\SusExtensionSearcher-Result-$($CurrentDate.ToString("yyyy-MM-dd.HH.mm")).txt"
#$sw is simply to track how long the script has run for. If it's running too long you might want to break the scan into multiple pieces.
$sw = [Diagnostics.Stopwatch]::StartNew()
#Sets Timestamp format for the runlog
$TimeStampFormat = "yyyy-MM-dd HH:mm:ss"
#################################### FUNCTIONS #######################################
#This function is simply used to create a run log for the script. This is useful for troubleshooting and tracking
Function Write-Log{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("Info","WARN","ERROR","FATAL","DEBUG")]
        [string]
        $level = "INFO",

        [Parameter(Mandatory=$true)]
        [string]
        $Message,

        [Parameter(Mandatory=$true)]
        [string]
        $logfile
    )
    $Stamp = (Get-Date).ToString($TimeStampFormat)
    $Line = "$Stamp | $Level | $Message"
    Add-content $logfile -Value $Line
}
#This function gets a list of files and compares them to the extensions list found in the extensions file. 
Function Get-SusFilesTypes{
    #Initialize counting variables for, well, counting
    $SusItemsCount = 0
    $FileCount = 0
    Write-Output "$($GetFiles.Count) total files/folders found" | Out-File $output -Append
    Write-Log -level INFO -message "$($GetFiles.Count) total files/folders found at $Path" -logfile $RunLog     
    #Comapre each item in the designated path to the list in the extensions file.  
    Foreach($File in $GetFiles){
        Write-Progress "Checking File $FileCount of $($GetFiles.Count)"
        $FileCount ++
		If($file.Extension -in $ExtensionsList){
            Write-Output "$($File.Fullname)" 
            $SusItemsCount ++
            #Store results in a variable for making the report at the end `n adds a new line so each item is on a new line. Otherwise the report will be a pain to read
            $SUSList += "$($File.Fullname)`n"
        }
    }
    #After checking each file give the final results and some stats from the scan. 
    Write-Output "$SusItemsCount total suspicious files found" | Out-File $output -Append
    Write-Log -level INFO -message "$SusItemsCount total suspicious files found" -logfile $RunLog     
    $sw.stop()
    Write-Output "Extension check took $($sw.elapsed)"
    Write-Log -level INFO -message "Suspicious Extension check took $($sw.elapsed) to run" -logfile $RunLog
    $SUSList | Out-File $output -Append
}
#################################### EXECUTION #####################################

Write-Log -level INFO -message "Suspicious extension search script ran by $user on $Computer" -logfile $RunLog 
Get-SusFilesTypes