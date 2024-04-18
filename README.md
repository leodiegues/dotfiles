# ~/.dotfiles

leodiegues' dotfiles

## Installation

Clone this repository
```bash
git clone https://github.com/leodiegues/dotfiles.git ~/.dotfiles
```
Run the playbook
```bash
cd ~/.dotfiles
./bin/dot-bootstrap.sh
```
If you want to run only a specific tag
```bash
ansible-playbook -i hosts playbook.yml --ask-become-pass --tags "tag1,tag2"
```
