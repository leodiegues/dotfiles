# ~/.dotfiles

leodiegues' dotfiles

## Installation

Install [Ansible](https://www.ansible.com/)
```bash
sudo apt install ansible
```
Clone this repository
```bash
git clone https://github.com/leodiegues/dotfiles.git ~/.dotfiles
```
Run the playbook
```bash
cd ~/.dotfiles
ansible-playbook -i hosts playbook.yml --ask-become-pass
```