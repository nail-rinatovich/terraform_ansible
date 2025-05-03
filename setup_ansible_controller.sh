#!/bin/bash

# Update package list
sudo apt update

# Install Ansible and Git
sudo apt install -y ansible git

# Create SSH key if not exists
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
fi

# Clone repository
git clone https://github.com/nail-rinatovich/terraform_ansible.git ~/mediawiki-ansible

# Create ansible.cfg
cat > ~/mediawiki-ansible/ansible.cfg << EOF
[defaults]
inventory = inventory.yml
remote_user = ubuntu
private_key_file = ~/.ssh/id_rsa
host_key_checking = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF

# Display public key
echo "Add this public key to all servers:"
cat ~/.ssh/id_rsa.pub

echo "Setup complete. Now add the public key to all servers and run:"
echo "cd ~/mediawiki-ansible && ansible-playbook site.yml" 