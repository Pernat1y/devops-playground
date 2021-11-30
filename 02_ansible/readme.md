# About
Ansible script to configure 3 pre-provisioned servers:
* Frontend web server: nginx
* Backend API server: see 'app' folder for example application
* Backend DB server: MariaDB

# Usage
* Place valid certificates to 'web' directory
* Run playbook:
```ansible-galaxy collection install community.mysql
ansible-playbook --syntax-check --inventory inventory playbook.yml
ansible-playbook --inventory inventory playbook.yml```

To run on single host, use:

```ansible-playbook --limit web --inventory inventory playbook.yml
ansible-playbook --limit db --inventory inventory playbook.yml
ansible-playbook --limit app --inventory inventory playbook.yml```
