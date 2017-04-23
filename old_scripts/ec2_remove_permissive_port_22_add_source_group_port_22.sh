#!/bin/bash
# This script removes rules specified by the user (within the script)  and may add a user specified rule.

# Bash colors:
NORMALCOL="\033[0m"
BOLD="\033[1m"
REDCOL="\033[1;31m"
YELLOWCOL="\033[1;33m"
GREENCOL="\033[1;32m"

# Script vars:
# Get ALL security groups IDs
#SG_GROUPS=$(aws ec2 describe-security-groups | grep 'SECURITYGROUPS' | awk -F'sg-' '{ print $2 }' | awk '{ print $1}' | sed s/^/sg-/g)
# Specific security group IDs of security groups that I have created:
SG_GROUPS="sg-4cd52b3a sg-7bcf310d sg-27ce3051 sg-41c93637 sg-d83cc2ae"
RULETOREMOVE="IPPERMISSIONS 22 tcp 22 IPRANGES 0.0.0.0/0"
# Set source group ID to allow tcp port 22 ingress access
ALLOWEDGROUP="sg-47381e30" # In this example, this ID refers to: stage-ender"
# Set a filter to skip all groups with filter pattern anywhere in their name
FILTEROUT="stage"

# Begin
echo There are $(echo ${SG_GROUPS} | wc -w) groups

# Display your currenly configured region in aws ec2 cli
echo -e "$REDCOL You are now working on $(grep region  ~/.aws/config) $NORMALCOL"
# check all SG Groups
echo -e "$REDCOL Script will assess the following groups: $NORMALCOL"
echo "$SG_GROUPS"

echo "Press Enter to Continue"
read x

for group in ${SG_GROUPS}
  do
		echo "========================================================================="
    echo -e "$REDCOL Processing group ID: $group $NORMALCOL"
		OUTPUT=$(aws ec2 describe-security-groups --group-ids "$group")
		groupname=$(echo $OUTPUT | awk '{print $4}')
		if [[ "$groupname" == *"+"* ]] 
			then
				groupname=$(echo $OUTPUT | awk '{print $5}') # Some security groups are displayed differntly and GroupName is in the next cell
		fi
    echo -e "$BOLD Group Name: ${groupname} $NORMALCOL"

		echo "${groupname}" | grep -q "${FILTEROUT}"
    if [ $? -eq 0 ]
      then
        echo -e "$YELLOWCOL Filter pattern '$FILTEROUT' was found, skipping '${group}' '${groupname}' $NORMALCOL"
        continue;
    fi

    echo -e "$BOLD Group ID: ${group} with Group Name: ${groupname} was NOT filtered and will be processed $NORMALCOL"
		echo -e "$BOLD Looking for the relevant rule..."

    # Check if permissive port 22 rule exists
    echo ${OUTPUT} | grep "$RULETOREMOVE"
    if [ $? -eq 0 ]
      then
				echo -e "$GREENCOL Found the rule to delete! $NORMALCOL"
				# command to remove rule
				echo "Removing old rule with : aws ec2 revoke-security-group-ingress --group-id ${group} --protocol tcp --port 22 --cidr 0.0.0.0/0"
				# command to add specific rule
				echo "Adding new rule with : aws ec2 authorize-security-group-ingress --group-id ${group} --protocol tcp --port 22 --source-group ${ALLOWEDGROUP}"
				echo "========================================================================="
      else
				echo -e "$YELLOWCOL group ${group} ${groupname} DOES NOT have a permissive port 22 rule $NORMALCOL"
				echo "========================================================================="
    fi
  done
