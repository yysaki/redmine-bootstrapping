#!/bin/bash

HOME=/srv/git
cd $HOME

ssh-keygen -t rsa -b 4096 -f $HOME/.ssh/id_rsa  -N ""
touch .ssh/authorized_keys

git clone http://github.com/sitaramc/gitolite.git
mkdir bin
echo "export PATH=/srv/git/bin:$PATH" >> .bashrc
gitolite/install -ln /srv/git/bin
bin/gitolite setup -pk admin.pub
