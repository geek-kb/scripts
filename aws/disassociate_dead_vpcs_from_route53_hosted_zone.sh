#!/bin/bash
if [[ -z "$1" ]]; then
	echo "Please supply AWS region!"
	exit 1
fi
region=$1
hostedzoneid="Z1ZOGSXD2823ZV"
for currentvpc in $(aws ec2 describe-vpcs | grep VpcId | awk '{print $2}' | tr -d '\"|,'); do crvpc_arr+=($currentvpc); done
for asvpc in $(aws route53 get-hosted-zone --id $hostedzoneid | grep VPCId | awk '{print $2}' | tr -d '\"|,'); do asvpc_arr+=($asvpc); done
deadvpcs_arr=()
for i in "${asvpc_arr[@]}"; do
    skip=
    for j in "${crvpc_arr[@]}"; do
        [[ $i == $j ]] && { skip=1; break; }
    done
    [[ -n $skip ]] || deadvpcs_arr+=("$i")
done
for deadvpc in ${!deadvpcs_arr[@]}; do
	echo "Vpc ${deadvpcs_arr} is associated to the zone but does not exist! Deleting!"
	echo aws route53 disassociate-vpc-from-hosted-zone --hosted-zone-id $hostedzoneid --vpc VPCRegion=$region,VPCId=${deadvpcs_arr[$deadvpc]}
done
