#!/bin/sh

cd /home/unicorn/
git clone https://github.com/redmine/redmine.git
cd redmine/
git checkout 3.2.3
mv config/database.yml config/database.yml.bak
cp ../database.yml config/
bundle install --path .bundle --without development test
bundle exec rake generate_secret_token

mv Gemfile.local Gemfile.local.bak
cp ../Gemfile.local ./
bundle update
mv config/unicorn.rb config/unicorn.rb.bak
cp ../unicorn.rb config/
