#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0);pwd)

cd /home/yysaki/
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

git clone https://github.com/redmine/redmine.git
cd /home/yysaki/redmine/
git checkout 3.2.3
mv /home/yysaki/redmine/config/database.yml
cp $SCRIPT_DIR/files/database.yml /home/yysaki/redmine/config/
bundle install --path .bundle --without development test
bundle exec rake generate_secret_token
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

mv /home/yysaki/redmine/Gemfile.local{,.bak}
cp $SCRIPT_DIR/files/Gemfile.local /home/yysaki/redmine/
sudo bundle update
cp $SCRIPT_DIR/files/unicorn.rb /home/yysaki/redmine/config/
sudo cp $SCRIPT_DIR/files/redmine-unicorn.service /lib/systemd/system/

sudo systemctl start redmine-unicorn.service
sudo systemctl enable redmine-unicorn.service

sudo cp $SCRIPT_DIR/files/redmine /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/redmine /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

sudo systemctl start nginx.service
sudo systemctl enable nginx.service

sudo apt-get install -y mailutils
sudo mv /etc/postfix/main.cf{,.bak}
sudo cp $SCRIPT_DIR/files/main.cf /etc/postfix/
sudo systemctl restart postfix

# sudo cp $SCRIPT_DIR/files/main-relay.cf /etc/postfix/main.cf
# sudo cp $SCRIPT_DIR/files/relay_password /etc/postfix/
# sudo vi /etc/postfix/relay_password
# sudo postmap hash:/etc/postfix/relay_password
# sudo systemctl restart postfix

# ssh-keygen
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

# gitolite
sudo useradd -m -U -r -s /bin/bash -d /srv/git git
sudo cp /home/yysaki/.ssh/id_rsa.pub /srv/git/admin.pub
sudo chown git:git /srv/git/admin.pub
sudo su - git
cd /srv/git/
git clone http://github.com/sitaramc/gitolite.git
mkdir bin
echo "export PATH=/srv/git/bin:$PATH" >> /srv/git/.bashrc
source /srv/git/.bashrc
gitolite/install -ln
gitolite setup -pk admin.pub
rm admin.pub
exit
# git clone git@{hostname}:gitolite-admin.git
# ssh git@{hostname} help
