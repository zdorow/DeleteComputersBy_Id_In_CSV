#!/bin/sh
####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE 
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE 
# MAINTAIN THIS SCRIPT 
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	deleteComputersAPI.sh - Deletes Computers from the JSS based on ID
#
# DESCRIPTION
#
#	This script reads in a CSV file containing Computer IDs, then deletes each Computer ID from the JSS. Yikes.
#
# REQUIREMENTS
#
#   A CSV file containing the IDs to delete. Each ID should be on a new line.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.2
#
#   Release Notes:
#   	- Style Guide Compatibility
#	- Error handling for bad credentials, bad url and bad filepath
#
#	- Created by Matthew Mitchell on June 12, 2017
#   	- Updated by Matthew Mitchell on July 10, 2017 v1.1
#	- Updated by Zach Dorow on March 3, 2018 v1.2
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

echo ""
echo "--------------------------"
echo "WARNING: This is a dangerous script to run, as it will try and delete whatever you pass it."
echo "Please make sure you have a MySQL database backup you're OK rolling back to if something goes wrong."
echo "-------------------------"

#Username Entry
echo ""
echo "Please enter the Jamf Pro API username: "
read apiUser
echo ""
#Password Entry 
echo "Please enter the password: "
read -s apiPass
echo ""

#URL of Jamf Pro server entry
echo "Please enter the Jamf Pro URL including the port ex. https://jamfit.jamfsw.com:8443 if we are locally hosted"
echo "No port needed for cloud hosted instances ex. https://jamfit.jamfsw.com" 
echo "A / added at the end will result in an error"
read url
echo ""

####################################################################################################
# 
# The error handling portion of the script
#
####################################################################################################
#Testing supplied url and credentials seperate error messages for both
echo "Trying a test call to the Jamf Pro API"

test=$(curl --fail -ksu "$apiUser":"$apiPass" "$url/JSSResource/computers" -X GET)
status=$?

if [ $status -eq 6 ]; then
	echo ""
	echo "The Jamf Pro URL is incorrect. Do we have a trailing forward slash? Please try again." 
	echo "If the error persists please check permissions and internet connection" 
	echo ""
	exit 99
elif [ $status -eq 22 ]; then
	echo ""
	echo "Username and/or password is incorrect."
	echo "If the error persists please check permissions and internet connection" 
	echo ""
	exit 99
else
echo ""
echo "Connection test successful"
echo "Please enter the filepath to the .csv"
read csv

#Testing supplied file path for .csv if the file is not found script exits
if [ ! -f $csv ]; then 
echo ""
echo "$csv file not found. Please try again." 
echo ""
exit 99
fi
####################################################################################################
# 
# The heart of this script actually doing what it was desigend to do. 
#
####################################################################################################
IFS=$'\n' read -d '' -r -a deviceIDs < $csv

length=${#deviceIDs[@]}

for ((i=0; i<$length;i++));

do
	id=$(echo ${deviceIDs[i]} | sed 's/,//g' | sed 's/ //g'| tr -d '\r\n')
	echo ""
	curl -ksu "$apiUser":"$apiPass" "$url/JSSResource/computers/id/$id" -X DELETE
	echo "Computer -- ID: $id -- has been called to be Deleted"
	echo ""
done 

fi	
exit 0
