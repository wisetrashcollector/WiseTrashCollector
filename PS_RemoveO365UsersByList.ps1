#######################################################################################
#    RUN AT YOUR OWN RISK! AUTHOR ACCEPTS NO RESPONSIBILITY FOR YOUR IMPROPER USE.    #
# This script reads an external .csv file and deletes Office 365 based on that file.  #
# File format details will be added to the bottom of this document. Modifications are #
# needed on line 45 to match your target filename and path.                           #                                
#######################################################################################

$host.runspace.threadoptions = "reusethread"

########
# Connect to MS O365 instance...
$msolcred = get-credential
connect-msolservice -credential $msolcred

########
# Main function...
function removeo365usersbylist
{

########
# Verify file path...
	write-host "Checking for input source file..." -foregroundcolor yellow
    $listfileexists = (test-path $myinputfile -pathtype leaf) 
    if ($listfileexists) { 
    "Source file path: " + $myinputfile 
	$mylistdata = import-csv $myinputfile            
    } else { 
	write-host $myinputfile " file not found. Canceling operation." -foregroundcolor red
	exit
	} 

########
# Begin delete process...
	write-host "Starting delete operations..." -foregroundcolor yellow
    foreach ($userobj in $mylistdata) 
    {
    "Removed user " + $userobj.$upndata.tostring()         
    get-msoluser -userprincipalname $userobj.$upndata | remove-msoluser -force
    }
	write-host "Operation completed." -foregroundcolor yellow
	}

########
# Modify the filename in this line to match your needs...
$myinputfile=$scriptdir+ ".\ListofO365userstodelete.csv"

$scriptdir = split-path -parent $myinvocation.mycommand.path
$upndata="userprincipalname"
removeo365usersbylist

########################################################################################
# A word about .csv file needed to run this script...                                  #
# The header 'userprincipalname' - sans single quote - needs to be the first line of   #
# your file. Email addresses (UPNs) should form a single column underneath. Additional #
# spaces, returns, etc. might cause the script to fail. If you have wrong/previously   #
# deleted items in your list, PoSH will notify you and continue to process to the end  #
# of the file.                                                                         #
#                  PROTIP: Try this with a test file first, ok? GLHF.                  #
########################################################################################