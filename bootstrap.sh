#!/bin/sh

cd /home/vagrant/
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git
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
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y nginx-extras passenger
sudo apt-get update
sudo apt-get upgrade -y
sudo gem install bundler

git clone https://github.com/redmine/redmine.git
cd /home/vagrant/redmine/
git checkout 3.1.1
cp /vagrant/files/database.yml /home/vagrant/redmine/config/
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

sudo cp /vagrant/files/nginx.conf /etc/nginx/
sudo cp /vagrant/files/redmine /etc/nginx/sites-available/
sudo rm /etc/nginx/sites-enable/default
sudo ln -s /etc/nginx/sites-available/redmine /etc/nginx/sites-enable/redmine

sudo service nginx restart
