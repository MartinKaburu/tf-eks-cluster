#!/bin/bash

main() {
    # eks module
    cd ./modules/eks

    terraform init

    terraform plan
    terraform apply -auto-approve
    
    if [ $? -ne 0 ]; then # Probably failed because OIDC did not exist
        terraform apply -auto-approve
    fi

    # k8s module
    cd ../../k8s
    terraform init

    terraform plan -target=helm_release.karpenter_crd
    terraform apply -target=helm_release.karpenter_crd -auto-approve

    terraform plan
    terraform apply -auto-approve

    echo "Completed successfully!"
}

main
