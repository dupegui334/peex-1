# 2. Cloud compute:
## Provision virtual machine with predefined types and images

* a dedicated VPC is created with a public subnet
* a security group restricting access to the created Amazon EC2 instance from your local workstation over SSH protocol
* a key pair is generated for accessing your Amazon EC2 instance with SSH
* an EC2 instance should be provisioned of type t2.micro
* the latest Ubuntu AMI used to instantiate the instance
* established SSH connection from your local workstation to the created Amazon EC2 instance
---
## Content
### compute module:
* **main.tf:** Terraform file dedicated to define compute resources in AWS for the exercise such as: EC2, security groups and key pair.
* **variables.tf:** Terraform file to declare variables.
### networking module:
* **main.tf:** Terraform file dedicated to define network resources in AWS for the exercise such as: VPC, subnets, internet gateway and routing tables with their association.
* **outputs.tf:** Terraform file dedicated to define the outputs of the module, this is important since the compute module will need to provision some of its resources based on resources of this module. *Example: EC2 (compute module) need a public subnet from networking module.*
## parent directory:
* **main.tf:** Terraform file dedicated to the 2 modules are called with their variables.
* **provider.tf:** Terraform file dedicated to the providers we are going to need, in our case only AWS.
* **backend.tf:** Terraform file dedicated to define where the backend of terraform will be, in this case in an S3 previously created.
