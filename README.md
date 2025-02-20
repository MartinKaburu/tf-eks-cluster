# Overview
This repository contains Terraform configurations for setting up an Amazon EKS (Elastic Kubernetes Service) cluster. It also has an eks module that provisions [Karpenter](https://karpenter.io) in the cluster and configures two karpenter.sh/v1/nodepools with arm64 and amd64 architectures.

# Prerequisites
- Terraform (=1.10.5)
- AWS CLI
- Kubectl

# Provisioning Resources
Before initializing the modules, ensure that the cluster_name, 2 subnets(in different az), vpc_id and aws_region have been configured in the terraform.tfvars file. Once the variables have been configured, run the init script to install the EKS module.
```bash
./init.sh
```
When prompted to updated variables in the EKS module, get the variables echoed out by the script and update them appropriately in `./modules/k8s/provisioners/*-nodeclass.yaml`. Then press Enter to proceed with the script.
On successful completion of the script, you can check that your resources have been created with the following commands.
```bash
# configure cluster access
aws eks --region ap-south-1 update-kubeconfig --name test-cluster

# get karpenter controller pod
kubectl get pods -n karpenter

# get nodepools
kubectl get nodepool

# get nodeclasses
kubectl get EC2NodeClass
```
**NOTE: At this point there are still no nodes provisioned since we don't have any workloads in the cluster.**

# Deploying Workloads on x86(AMD64) and Graviton(ARM64) Nodes
To deploy a workload in the cluster follow the following steps:
1. Get your AWS credentials from the AWS console and export them.
```bash
export AWS_SECRET_ACCESS_KEY=""
export AWS_ACCESS_KEY_ID=""
```
2. Configure kubeconfig cluster access
```bash
aws eks update-kubeconfig --name test-cluster --region ap-south-1
```
3. Deploy an **AMD64(X86)** workload. Ensure the `.spec.template.spec.nodeSelector`  and `.spec.template.spec.tolerations.` are set as shown below.
```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
    name: amd64-deployment
spec:
    replicas: 1
    template:
        spec:
            nodeSelector:
                kubernetes.io/arch: amd64
            tolerations:
            - key: "arch"
                operator: "Equal"
                value: "amd64"
                effect: "NoSchedule"
            containers:
            - name: amd64-container
                image: nginx:latest # Replace with your image
                ports:
                - containerPort: 80 # Replace with your container port
EOF
```
4. To deploy an **ARM64(Graviton)** workload. Ensure the `.spec.template.spec.nodeSelector`  and `.spec.template.spec.tolerations.` are set as shown below.
```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
    name: arm64-deployment
spec:
    replicas: 1
    template:
        spec:
            nodeSelector:
                kubernetes.io/arch: arm64
            tolerations:
            - key: "arch"
                operator: "Equal"
                value: "arm64"
                effect: "NoSchedule"
            containers:
            - name: arm64-container
                image: nginx:latest # Replace with your image
                ports:
                - containerPort: 80 # Replace with your container port
EOF
```

# Cleanup
To cleanup the created resources execute the cleanup.sh file.
```bash
./cleanup.sh
```