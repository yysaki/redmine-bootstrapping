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
sudo apt-get install -y build-essential libssl-dev libreadline6-dev zlib1g-dev libcurl4-openssl-dev curl libyaml-dev ruby ruby-dev
sudo apt-get install -y libmagickwand-dev imagemagick
sudo gem install passenger
sudo passenger-install-nginx-module --auto
git clone https://github.com/redmine/redmine.git
cp /vagrant/files/database.yml /home/vagrant/redmine/config/
sudo gem install bundler

cd /home/vagrant/redmine/
bundle install --without development test
bundle exec rake generate_secret_token
sudo RAILS_ENV=production bundle exec rake db:migrate
sudo RAILS_ENV=production bundle exec rake redmine:load_default_data
sudo chmod 666 db/redmine.db

sudo cp /vagrant/files/nginx.conf /opt/nginx/conf/
