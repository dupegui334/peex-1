## 2. Cloud compute:Provision virtual machine with predefined types and images

* a dedicated VPC is created with a public subnet
* a security group restricting access to the created Amazon EC2 instance from your local workstation over SSH protocol
* a key pair is generated for accessing your Amazon EC2 instance with SSH
* an EC2 instance should be provisioned of type t2.micro
* the latest Ubuntu AMI used to instantiate the instance
* established SSH connection from your local workstation to the created Amazon EC2 instance