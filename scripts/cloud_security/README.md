# 4. Cloud security:
---
## 1. Configuration and usage of secure shell access to systems and services.

### 1. Generate private and public keys using any available tools with an algorithm that is stronger than RSA 1024.
### 2. Create a new or use an existing account from any SCM provider.
### 3. Import to the new account the key that was generated on the previous activity.
### 4. Validate whether it is possible to interact with SCM from the local environment using the key.
For steps 1-4 check this runbook from github on how to setup ssh keys for repository [ssh-keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
![ssh-image](./images/SSH_and_GPG_keys.png)
### 5. Create a new Linux instance.
* Setup SSM connection:
    * Create IAM role for SSM full access:
    ![IAM](./images/IAM.png)
    * Attach role to ec2 instance.
    * Create security group to access ssh (inbound rules: TCP 443 and 22) or left the default one.
    ![ec2](./images/ec2.png)
    ![SSM](./images/SSM.png)
### 6. Create non-admin users for connecting to the hosts:
```
sudo useradd <new user>
```
![user](./images/user.png)
login into the new user and put the public key (.pub):
```
su <new user>
mkdir ~/.ssh
mkdir ~/.ssh/authorized_keys
vim authorized_keys # Paste public key
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys 
```
Then, you should be able to connect the host via ssh with this user.
### 7. Disable root login to this instance.
```
sudo -i
vim /etc/ssh/sshd_config
```
Set the value of PermitRootLogin to **no**
![root-disable](./images/root_disable.png)

### 8. Create a non-root user with sudo permission.
In this step you need to add a user to wheel group, in this case the user will be peex:
```
$ sudo usermod -aG wheel peex
$ cat /etc/group | grep wheel
wheel:x:4:ec2-user,peex
```
Another way is selecting group adm and edit sudoers file to let it have sudo permissions:
```
sudo visudo
```
![sudoers](./images/sudoers.png)
### 9. Sign in to the instance as a non-root user via ssh.
```
ssh -i "key.pem" peex@<public_ip>
```                                   
### 10. Escalate permissions using sudo.
Now, thanks to step 8, this user has sudo permissions, to test it:
``` 
sudo -i
``` 
