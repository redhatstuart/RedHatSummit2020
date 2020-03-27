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
AZUREDC="$(az group list |grep 01 | awk '{print $2}')"
RG="01"

# Inputs
echo "Welcome to the Red Hat Summit 2020 lab Deploy and scale Microsoft Azure Cloud Native infrastructures and applications with Red Hat Ansible Automation"
echo "Please answer the following questions so that we can get your lab environment set up and you can begin working on your lab exercises."
echo " "
echo -n "What is your first name:  >"
read first
echo -n "What is your last name:  >"
read last
echo -n "What year were you born:  >"
read year
echo -n "What is your GitHub ID:  >"
read githubid
echo -n "What is your GitHub Personal Access Token:  >"
read gitpat

echo " "

# Validation
echo "To Recap:"
echo "Your first name is: $first"
echo "Your last name is: $last"
echo "You were born in: $year"
echo "Your GitHub ID is: $githubid"
echo "Your GitHub PAT is: $gitpat"

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

# Operations
cp vars.yml vars-myvars.yml
sed -i "s/MYRANDOM/$RANDNUM/g" vars-myvars.yml
sed -i "s/MY_RESOURCE_GROUP/$RG/g" vars-myvars.yml
sed -i "s/MYGITHUBID/$githubid/g" vars-myvars.yml
sed -i "s/MYGITHUBPERSONALACCESSTOKEN/$gitpat/g" vars-myvars.yml
sed -i "s/MYVM/$VMNAME/g" vars-myvars.yml
sed -i "s/MYAZUREDATACENTER/$AZUREDC/g" vars-myvars.yml

# Finish
echo "Your custom variables file, vars-myvars.yml, has been created.  Go forth and conquer!"
exit 0


