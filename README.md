# Suspiciuous_Extension_Finder
This script can be used to do a quick search for files that should receive additional review against a list of provided extensions. 

## DESCRIPTION
Certain file types in the environment should receive addional review to help ensure security. This script will take a specified path and scan folders/subfolders and compare the file extension of each file found against a list of extensions. If the item is found the full path to the file will be displayed. 
The complete list will also be written to a txt file in the directory where the script is run, titled SusExtensionSearcher-Results-yyyy-MM-dd.HH.mm.txt. 
The script will also create a runlog file that contains a summary of who ran the script and when, how many files were found, how long the scan took etc. 
Note that this is just a simple check for extensions and isn't advanced enough to be able to tell if a file is hiding behind a different extension or multiple extensions. 
This script can be helpful for a basic check but should NOT be used as your only check. 

## PARAMETER path
-Path:  Used to specify what path you want to scan. please be aware of the size of directory and subdirectories you are trying to scan

## PARAMETER extensions
-Extensions: This designates a path to the extensions list you are wanting to check. The file should be a list of extensions with each type on a new line. 

## EXAMPLE
SusExtensionSearcher.ps1 -path C:\Users\Hydrophobia\Downloads -extensions C:\Users\Hydrophobia\Downloads\extensions.txt
