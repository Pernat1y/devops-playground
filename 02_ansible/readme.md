# About
Ansible script to configure 3 pre-provisioned servers:
* Frontend web server: nginx
* Backend API server: see 'app' folder for example application
* Backend DB server: MariaDB

# Usage
* 1. Place valid certificates to 'web' directory
* 2. ```ansible-galaxy collection install community.mysql
ansible-playbook --syntax-check --inventory inventory playbook.yml
ansible-playbook --inventory inventory playbook.yml```

