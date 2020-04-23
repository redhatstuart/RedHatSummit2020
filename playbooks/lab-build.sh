#!/bin/bash
#
# Build Script
# Deploy and scale Microsoft Azure Cloud Native infrastructures and applications with Red Hat Ansible Automation
# Written by Stuart Kirk <stuart.kirk@microsoft.com>

# Init
if [ -f "vars-myvars.yml" ]; then
    echo "This script has already been run and your vars-myvars.yml file already exists."
    exit 1
fi

# Variables
RANDNUM="$(shuf -i 20000-50000 -n 1)"
AZUREDC="$(az group list -o table |grep 01 | awk '{print $2}')"
RG="01"

# Inputs
echo "Welcome to the Red Hat Summit 2020 lab Deploy and scale Microsoft Azure Cloud Native infrastructures and applications with Red Hat Ansible Automation"
echo "Please answer the following questions so that we can get your lab environment set up and you can begin working on your lab exercises."
echo " "
echo -n "What is your first name:  > "
read first
echo -n "What is your last name:  > "
read last
echo -n "What year were you born:  > "
read year
echo -n "What is your GitHub ID:  > "
read githubid
echo -n "What is your GitHub Personal Access Token:  > "
read gitpat
echo -n "What is the Azure Red Hat OpenShift (ARO) API URL:  > "
read aroapi

echo " "

# Validation
echo "To Recap:"
echo "Your first name is: $first"
echo "Your last name is: $last"
echo "You were born in: $year"
echo "Your GitHub ID is: $githubid"
echo "Your GitHub PAT is: $gitpat"
echo "The ARO API URL is: $aroapi"

echo " "

echo "Is this correct?"
PS3="Select a numbered option >> "
options=("Yes" "No")
select yn in "${options[@]}"
do
case $yn in
    Yes ) break ;;
    No ) echo "Please re-run the script and provide the correct values."; exit ;;
esac
done

# Massage variables
FIRSTLAST="${first}${last}${year}"
VMNAME="$(echo $FIRSTLAST | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c 1-15)"
AROFIRST="$(echo $first |cut -c 1)"
ARONAME="${AROFIRST}${last}${RANDNUM}"
USERNAME="$(echo $ARONAME | tr '[:upper:]' '[:lower:]')"

# Operations
cp vars.yml vars-myvars.yml
sed -i "s/MYRANDOM/$RANDNUM/g" vars-myvars.yml
sed -i "s/MY_RESOURCE_GROUP/$RG/g" vars-myvars.yml
sed -i "s/MYGITHUBID/$githubid/g" vars-myvars.yml
sed -i "s/MYGITHUBPERSONALACCESSTOKEN/$gitpat/g" vars-myvars.yml
sed -i "s/MYVM/$VMNAME/g" vars-myvars.yml
sed -i "s/MYAZUREDATACENTER/$AZUREDC/g" vars-myvars.yml
sed -i "s/MYUSERNAME/$USERNAME/g" vars-myvars.yml
sed -i "s+AROAPIURL+$aroapi+g" vars-myvars.yml

# ARO Credentials

echo " "
echo -e "\e[1;41m ***********************************************************************************\e[0m"
echo -e "\e[1;41m ***********************************************************************************\e[0m"
echo -e "\e[1;41m ***********************************************************************************\e[0m"
echo -e "\e[1;31m For the Azure Red Hat OpenShift (ARO) lab: \e[0m"
echo -e "\e[1;31m Your username to log in to ARO is: $USERNAME \e[0m"
echo -e "\e[1;31m Your password to log in to ARO is: Microsoft \e[0m"
echo -e "\e[1;41m ***********************************************************************************\e[0m"
echo -e "\e[1;41m ***********************************************************************************\e[0m"
echo -e "\e[1;41m ***********************************************************************************\e[0m"
curl --data "username=$USERNAME&password=Microsoft" https://wolverine.itscloudy.af/arolab.php

# Finish
echo " "
echo "Your custom variables file, vars-myvars.yml, has been created.  Go forth and conquer!"
exit 0


