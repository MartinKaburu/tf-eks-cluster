# GPU Slicing on EKS

GPU slicing in EKS clusters is a feasible idea and can be implemented with Karpenter. The idea is made possible by **Nvidia Multi-Instance GPU(MIG)** technology which is available in some of Nvidia’s instances such as (`p4d.24xlarge` and `p4de.24xlarge`). With MIG you can dispatch multiple diverse workloads(which do not require the whole memory of a single GPU) on the same GPU without performance interference. We can configure this with karpenter by following the following steps: (_I’ll be assuming that we are using the `p4d.24xlarge` instance and that karpenter is already installed in the cluster_)

1. Configure a karpenter `karpenter.sh/v1/NodePool` resource setting the requirement `node.kubernetes.io/instance-type=p4d.24xlarge`

2. Once the instance is up and running, explicitly enable MIG on the nodes since it’s not enabled by default. Deploy a k8s daemonset that deploys an Nvidia container like `nvidia/cuda:latest` and executes the lines below. The daemonset must have the nodeSelector `node.kubernetes.io/instance-type=p4d.24xlarge`.
```bash
# Enable MIG
nvidia-smi -mig 1 

# You can view different available MIG profiles and their IDs with, 19 below is the ID for profile "MIG 1g.5gb" with 7 total instances
nvidia-smi mig -lgip

# Create and configure MIG instances, ID 19 means each partition gets 1gpu and 5gb ram. Meaning we'd have 7 partitions per GPU. With 8 GPUs/Node we'd have 56 partitions per instance. The partition configured can be varied and different allocations used.
nvidia-smi mig -cgi 19,19,19,19,19,19,19 

# Commit changes to gpu
nvidia-smi mig --cci
```

3. Install the Nvidia MIG-k8s plugin.
```bash
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo add nvgfd https://nvidia.github.io/gpu-feature-discovery

# migStrategy="MIXED" means we can configure each GPUs partitions separately and we don't have to use the same partititon config everywhere
helm install --generate-name --set migStrategy="MIXED" nvdp/nvidia-device-plugin
helm install --generate-name --set migStrategy="MIXED" nvgfd/gpu-feature-discovery
```
After a few minutes kubectl describe nodes should show the `nvidia.com/mig-1g.5gb: 56` meaning we have 56 available partitions.

4. When configuring workloads we can set the resources to use the GPU partitions with
```yaml
resources:
    requests:
        nvidia.com/mig-1g.5gb: 5 # Gives 5 of the 56 partitions to workload
```

This setup can be tweaked to vary the number of partitions and their size and would be very effective for utilizing GPU slicing with Nvidia MIG architecture. 
Some great advantages of this are:
- Cost saving by sharing a GPU across multiple workloads
- Utilizing scalability and elasticity
- Enabling GPU intense wrokdloads to use microservice design paradigms
- Allows for more granular control of GPU demand on applications


# References
[Nvidia MIG](https://www.nvidia.com/en-us/technologies/multi-instance-gpu/?ncid=afm-chs-44270&ranMID=44270&ranEAID=msYS1Nvjv4c&ranSiteID=msYS1Nvjv4c-N12KmVqKMdurYTNTKIKfCw)

[Utilizing Nvidia MultiInstance GPU](https://aws.amazon.com/blogs/containers/utilizing-nvidia-multi-instance-gpu-mig-in-amazon-ec2-p4d-instances-on-amazon-elastic-kubernetes-service-eks/?utm_source=chatgpt.com)

[EC2 P4 Instances](https://aws.amazon.com/ec2/instance-types/#Accelerated_Computing)
