#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0);pwd)

#general #{{{1
echo "set grub-pc/install_devices /dev/sda" | sudo debconf-communicate
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
sudo RAILS_ENV=production REDMINE_LANG=ja bundle exec rake redmine:load_default_data

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
sudo systemctl restart nginx.service
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
ssh-keygen -t rsa -b 4096 -f $HOME/.ssh/id_rsa  -N ""

# gitolite #{{{1
sudo useradd -m -U -r -s /bin/bash -d /srv/git git
sudo cp ~/.ssh/id_rsa.pub /srv/git/admin.pub
sudo chown git:git /srv/git/admin.pub

sudo -u git sh -c $SCRIPT_DIR/git-tasks.sh

sudo rm /srv/git/admin.pub

# __END__  #{{{1
# vim: foldmethod=marker
