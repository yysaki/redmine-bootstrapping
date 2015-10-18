実行手順
--------

後々Ansibleなどにまとめたい。

vagrant sshまで
===============

``` sh
brew install virtualbox
brew install vagrant
mkdir ~/vagrant
mkdir ~/vagrant/scratch/
vagrant init ubuntu/trusty64
vagrant up
vagrant ssh
```

環境構築系
==========

``` sh
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y git
sudo apt-get install -y mysql-server libmysqld-dev
sudo apt-get install -y build-essential libssl-dev libreadline6-dev zlib1g-dev libcurl4-openssl-dev curl libyaml-dev ruby ruby-dev
sudo apt-get install -y libmagickwand-dev imagemagick
sudo gem install passenger
sudo passenger-install-nginx-module --auto
git clone https://github.com/redmine/redmine.git
cp /vagrant/files/database.yml /home/vagrant/redmine/config/
sudo gem install bundler
bundle install --without development test
bundle exec rake generate_secret_token
sudo RAILS_ENV=production bundle exec rake db:migrate
sudo RAILS_ENV=production bundle exec rake redmine:load_default_data
sudo cp /vagrant/files/nginx.conf /opt/nginx/conf/
```

nginx起動
=========

``` sh
sudo /opt/nginx/sbin/nginx
sudo /opt/nginx/sbin/nginx -s stop
```

redmine 動作確認
================

``` sh
cd /home/vagrant/redmine
sudo bundle exec ruby bin/rails server webrick -e production
```

