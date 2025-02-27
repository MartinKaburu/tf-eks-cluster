#!/bin/bash

main() {
    echo "Destroying k8s module..."

    # Refresh credentials
    cd ./modules/eks
    terraform plan && terraform apply -auto-approve -refresh-only
    
    cd ../k8s

    terraform destroy -auto-approve

    echo "Destroying EKS module..."

    cd ../eks

    terraform destroy -auto-approve

    if [ $? -ne 0 ]; then
        terraform destroy -auto-approve
    fi

    echo "Completed successfully!"
}

main
