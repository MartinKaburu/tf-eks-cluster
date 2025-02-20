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

    # get instanceProfileName for EC2NodeClass
    export InstanceProfileName=$(aws iam list-instance-profiles --region $AWS_REGION --output json | jq -r '.InstanceProfiles[].InstanceProfileName' | grep eks)

    # get region specific AMI
    export AMD64_IMAGE=$(aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2/recommended" --region $AWS_REGION --query 'Parameter.Value' --output text --no-cli-pager | jq -r '.image_id')
    export ARM64_IMAGE=$(aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2-arm64/recommended" --region $AWS_REGION --query 'Parameter.Value' --output text --no-cli-pager | jq -r '.image_id')

    echo "AMD64_IMAGE: $AMD64_IMAGE"
    echo "ARM64_IMAGE: $ARM64_IMAGE"
    echo "InstanceProfileName: $InstanceProfileName"

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
