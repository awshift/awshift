#!/bin/bash

## Step 1
# Set Users & Groups
# Update the system
sudo yum update -y || sudo apt-get update -y && sudo apt-get upgrade -y

# Disabling Firewalld
systemctl stop firewalld
systemctl disable firewalld

# Install the necessary packages
yum install -y tree wget curl git unzip httpd vim dos2unix
dos2unix /home/ec2-user/prepare.sh

# Create the necessary directories
mkdir -p /opt/okd/
mkdir -p /opt/okd/manifests_bak
mkdir -p /opt/okd/install_config_bak
mkdir -p /opt/okd/install_dir


# Get openshift-install and oc
# Openshift Install
wget https://github.com/okd-project/okd/releases/download/4.14.0-0.okd-2024-01-26-175629/openshift-install-linux-4.14.0-0.okd-2024-01-26-175629.tar.gz && tar -xvf openshift-install-linux-4.14.0-0.okd-2024-01-26-175629.tar.gz
cp openshift-install /usr/bin/
mv openshift-install /opt/okd/


# Openshift Client
wget https://github.com/okd-project/okd/releases/download/4.14.0-0.okd-2024-01-26-175629/openshift-client-linux-4.14.0-0.okd-2024-01-26-175629.tar.gz && tar -xvf openshift-client-linux-4.14.0-0.okd-2024-01-26-175629.tar.gz
mv oc /usr/bin/
mv kubectl /usr/bin/

oc version || echo "oc ain't working"
kubectl version || echo "kubectl ain't working"

# Set the Web server
echo "you're on our Management machine" > /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd


# Tear down 
rm -rf openshift-install-linux-4.14.0-0.okd-2024-01-26-175629.tar.gz
rm -rf openshift-client-linux-4.14.0-0.okd-2024-01-26-175629.tar.gz

# Copy SSH key
sudo cp /home/ec2-user/.ssh/awshift.pem /root/.ssh/awshift.pem
sudo chmod 400 /root/.ssh/awshift.pem
sudo cat /home/ec2-user/.ssh/authorized_keys > /root/.ssh/awshift.pub


