#!/bin/bash

# check if the user is root or have rights of root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi


# Check if /opt/okd/ directory exists
if [ ! -d /opt/okd/ ]; then
    mkdir -p /opt/okd/
    mkdir -p /opt/okd/manifests_bak
    mkdir -p /opt/okd/install_config_bak
    mkdir -p /opt/okd/install_dir
fi

# Check OC version
oc version 

# Check if httpd is installed
if ! command -v httpd &> /dev/null; then
    echo "httpd is not installed. Please install it and try again."
    exit 1
fi

# Check if httpd service is running
if ! systemctl is-active --quiet httpd; then
    echo "httpd service is not running. Starting httpd service..."
    systemctl start httpd
fi

echo "httpd is installed and running."
# Curl localhost to check
curl localhost

# Check if firewalld is stopped
if systemctl is-active --quiet firewalld; then
    echo "firewalld is running. Stopping firewalld..."
    systemctl stop firewalld
fi


# Step2
sudo mv /home/ec2-user/install-config.yaml /root/
sudo mv /home/ec2-user/awshift.pem /root/.ssh/
sudo chmod 600 /root/.ssh/awshift.pem && sudo chown root:root /root/.ssh/awshift.pem 
sudo cp /home/ec2-user/prepare.sh /root/


# Set an agent
sudo eval "$(ssh-agent -s)"
sudo ssh-add /root/.ssh/awshift.pem

# Place install-config.yaml from /root to /opt/okd/install_dir
ls -al /opt/okd/install_dir | grep install-config.yaml || cp /root/install-config.yaml /opt/okd/install_dir && ls -al /opt/okd/install_dir

# backup install-config.yaml to /opt/okd/install_config_bak
ls -al /opt/okd/install_dir | grep install-config.yaml && cp /opt/okd/install_dir/install-config.yaml /opt/okd/install_config_bak && ls -al /opt/okd/install_config_bak

# Generate manifests
/opt/okd/openshift-install create manifests --dir /opt/okd/install_dir

# Make master unshcedulable
# Get the key:
cat /opt/okd/install_dir/manifests/cluster-scheduler-02-config.yml | grep mastersSchedulable
if [ $? -eq 0 ]; then
    echo "mastersSchedulable key exists"
    sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' /opt/okd/install_dir/manifests/cluster-scheduler-02-config.yml
else
    echo "mastersSchedulable key does not exist"
fi


# backup manifests to /opt/okd/manifests_bak    
ls -al /opt/okd/manifests_bak && sudo cp -r /opt/okd/install_dir/* /opt/okd/manifests_bak && ls -al /opt/okd/manifests_bak

# Generate ignition files
/opt/okd/openshift-install create ignition-configs --dir /opt/okd/install_dir

# Place the ignition files in /var/www/html
cp /opt/okd/install_dir/* /var/www/html/

# Generate CheckSums
# cd /var/www/html/ 
# for each file .ign make a checksum [bootstrap,master,worker]
# for file in "bootstrap.ign master.ign worker.ign"; 
# do
#     if [ -f "$file" ]; then
#         sha512sum "$file" > "$file.sha512"
#     else
#         echo "$file not found!"
#     fi
# done
sha512sum /var/www/html/bootstrap.ign > "bootstrap.sha512"
sha512sum /var/www/html/master.ign > "master.sha512"
sha512sum /var/www/html/worker.ign > "worker.sha512"

# rm index.html /var/www/html/index.html
rm -rf /var/www/html/index.html




