#!/bin/bash

main() {
    # Read AWS region
    read -p "Enter AWS region: " AWS_REGION
    echo "Installing EKS module..."

    # eks module
    cd ./modules/eks

    terraform init

    terraform plan
    terraform apply -auto-approve
    
    if [ $? -ne 0 ]; then # Probably failed because OIDC provider is not ready yet, re-running should fix
        terraform apply -auto-approve
    fi

    echo "Installing K8s module..."
    # get securityGroup for EC2NodeClass
    export NodeGroup=$(aws eks list-nodegroups --cluster-name test-cluster --query 'nodegroups[0]' --region $AWS_REGION --output text)
    export SecurityGroupId=$(aws ec2 describe-instances \
        --instance-ids $(aws eks describe-nodegroup --cluster-name test-cluster --nodegroup-name $NodeGroup --query 'nodegroup.instances[0].instanceId' --output text) \
        --query 'Reservations[].Instances[].SecurityGroups[].GroupId' \
        --output text
    )


    # get instanceProfileName for EC2NodeClass
    export InstanceProfileName=$(aws iam list-instance-profiles --region $AWS_REGION --output json | jq -r '.InstanceProfiles[].InstanceProfileName' | grep eks)

    # get region specific AMI
    export AMD64_AMI=$(aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2/recommended" --region $AWS_REGION --query 'Parameter.Value' --output text --no-cli-pager | jq -r '.image_id')
    export ARM64_AMI=$(aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2-arm64/recommended" --region $AWS_REGION --query 'Parameter.Value' --output text --no-cli-pager | jq -r '.image_id')

    echo "AMD64_AMI: $AMD64_AMI"
    echo "ARM64_AMI: $ARM64_AMI"
    echo "InstanceProfileName: $InstanceProfileName"
    echo "SecurityGroupId: $SecurityGroupId"

    read -p "Update k8s variables if necessary. Press Enter to continue..."

    cd ../k8s
    terraform init

    terraform plan -target=helm_release.karpenter_crd
    terraform apply -target=helm_release.karpenter_crd -auto-approve

    terraform plan
    terraform apply -auto-approve

    echo "Completed successfully!"
}

main
