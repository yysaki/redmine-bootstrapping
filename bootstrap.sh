#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0);pwd)

#general #{{{1

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git openssh-server language-pack-ja
sudo apt-get install -y sqlite libsqlite3-dev
echo 'mysql-server mysql-server/root_password password root' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password root' | sudo debconf-set-selections
sudo apt-get install -y mysql-server libmysqld-dev
mysqladmin -p'root' password '' -u root
sudo apt-get install -y ruby ruby-dev
sudo apt-get install -y libmagickwand-dev imagemagick
sudo apt-get install -y expect
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-get install -y nginx
sudo gem install bundler

# redmine #{{{1

sudo useradd -m -U -r -s /bin/bash -d /home/unicorn unicorn

sudo cp $SCRIPT_DIR/files/database.yml /home/unicorn/
sudo cp $SCRIPT_DIR/files/Gemfile.local /home/unicorn/
sudo cp $SCRIPT_DIR/files/unicorn.rb /home/unicorn/
sudo chown unicorn:unicorn /home/unicorn/database.yml
sudo chown unicorn:unicorn /home/unicorn/Gemfile.local
sudo chown unicorn:unicorn /home/unicorn/unicorn.rb

sudo -u unicorn sh -c $SCRIPT_DIR/unicorn-tasks.sh

cd /home/unicorn/redmine/
sudo RAILS_ENV=production bundle exec rake db:migrate
expect -c '
spawn sudo RAILS_ENV=production bundle exec rake redmine:load_default_data

set timeout 30
expect "Select language:*"
send "ja\n"
interact
'

sudo chmod 777 tmp
sudo chmod 777 db
sudo chmod 666 db/redmine.db

sudo rm /home/unicorn/database.yml
sudo rm /home/unicorn/Gemfile.local
sudo rm /home/unicorn/unicorn.rb

sudo cp $SCRIPT_DIR/files/redmine-unicorn.service /lib/systemd/system/

sudo systemctl restart redmine-unicorn.service
sudo systemctl enable redmine-unicorn.service

sudo cp $SCRIPT_DIR/files/redmine /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/redmine /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

cd $SCRIPT_DIR

# nginx #{{{1
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

# postfix #{{{1
sudo apt-get install -y mailutils
sudo mv /etc/postfix/main.cf /etc/postfix/main.cf.bak
sudo cp $SCRIPT_DIR/files/main.cf /etc/postfix/
sudo systemctl restart postfix

# リレー先をgmailにするworkaround
# sudo cp $SCRIPT_DIR/files/main-relay.cf /etc/postfix/main.cf
# sudo cp $SCRIPT_DIR/files/relay_password /etc/postfix/
# sudo vi /etc/postfix/relay_password
# sudo postmap hash:/etc/postfix/relay_password
# sudo systemctl restart postfix

# ssh-keygen #{{{1
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

# gitolite #{{{1
sudo useradd -m -U -r -s /bin/bash -d /srv/git git
sudo cp ~/.ssh/id_rsa.pub /srv/git/admin.pub
sudo chown git:git /srv/git/admin.pub

sudo -u git sh -c $SCRIPT_DIR/git-tasks.sh

sudo rm /srv/git/admin.pub

# __END__  #{{{1
# vim: foldmethod=marker
