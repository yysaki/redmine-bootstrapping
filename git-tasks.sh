#!/bin/bash

HOME=/srv/git
cd $HOME

expect -c '
set timeout 10
spawn ssh-keygen -t rsa
expect -re "Enter file in which to save the key\ (.\*\):"
send "\n"
expect "Enter passphrase \(empty for no passphrase\):"
send "\n"
expect "Enter same passphrase again:"
send "\n"
interact
'
touch .ssh/authorized_keys

git clone http://github.com/sitaramc/gitolite.git
mkdir bin
echo "export PATH=/srv/git/bin:$PATH" >> .bashrc
gitolite/install -ln /srv/git/bin
bin/gitolite setup -pk admin.pub
