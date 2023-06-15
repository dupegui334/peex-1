# 6. Cloud storage
---
## 1. CLOUD: Provision of storage services.
It is required to build a parent image, which is a base layer of your image that refers to the contents of the FROM directive in the Dockerfile.

* Created S3 Bucket
* Enabled Blocking Public Access to S3 bucket 
* Applied security measures:
    * Enabled Encryption on previously created bucket
    * Created Two Custom IAM Roles and assigned them to Two Users (you have to create them)
    * Role1 : Allowing only for Read-Only access to Previously Created S3 Bucket
    * Role2 : Allowing For Read-Write access to previously Created S3
        * Using Role2 Upload Dummy file (can be any file) to verify that you are capable of uploading the files
        * Using Role1 - Verify that you are able to download the file available on S3 but you are unable to upload your own file
    * Enabled Object Locking on S3 Bucket
    * Enabled Object Versioning Enabled on S3
    * Configured Object Deletion protection on S3 Bucket using MFA Delete
Configured S3 Replication across the region
Created S3 Gateway Endpoint. 

## Content
### compute module:
* **main.tf:** Terraform file dedicated to define compute resources in AWS for the exercise such as:  2 EC2, 2 security groups and their key pair, the 2 IAM user, roles, policies and the s3 bucket.
* **variables.tf:** Terraform file to declare variables.
### networking module:
* **main.tf:** Terraform file dedicated to define network resources in AWS for the exercise such as: VPC, subnets, internet gateway, NAT gateway (In case private EC2 needs access to internet to install some package) and routing tables with their association.
* **outputs.tf:** Terraform file dedicated to define the outputs of the module, this is important since the compute module will need to provision some of its resources based on resources of this module. *Example: EC2 (compute module) need a public subnet from networking module.*
### parent directory:
* **main.tf:** Terraform file dedicated to the 2 modules are called with their variables.
* **provider.tf:** Terraform file dedicated to the providers we are going to need, in our case only AWS.
* **backend.tf:** Terraform file dedicated to define where the backend of terraform will be, in this case in an S3 previously created.


```
cd networking
terraform init
cd ../compute
terraform init
cd ..
terraform init
terraform apply
```
* After creating all the resources go to AWS console, login as user1 or user2 and check the S3 bucket:
![bucket](./images/bucket.png)
![perm1](./images/permission1.png)
![perm2](./images/permission2.png)

* Login as user 1 and try to upload a file:
![user1](./images/user1.png)
* Now login as user 2 and try to delete that same file: You shouldn't have permissions.
![user2](./images/user2.png)