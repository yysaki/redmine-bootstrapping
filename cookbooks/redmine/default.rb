package "git"
package "openssh-server"
package "language-pack-ja"
package "sqlite"
package "libsqlite3-dev"

execute "mysql-server root_password" do
  command "echo 'mysql-server mysql-server/root_password password root' | debconf-set-selections"
end

execute "mysql-server root_password_again" do
  command "echo 'mysql-server mysql-server/root_password_again password root' | sudo debconf-set-selections"
end

package "mysql-server"
package "libmysqld-dev"

execute "mysqladmin パスワードリセット" do
  only_if "mysql -p'root' -u root -e 'show databases' | grep information_schema"
  command "mysqladmin -p'root' password '' -u root"
end

package "ruby"
package "ruby-dev"

package "libmagickwand-dev"
package "imagemagick"

execute "apt-key adv" do
  command "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7"
end

package "apt-transport-https"
package "ca-certificates"

package "nginx"

execute "gem install bundler" do
  command "gem install bundler"
end

user "create unicorn user" do
  username "unicorn"
  password ""
  home "/home/unicorn"
  shell	"/bin/bash"
end

directory "/home/unicorn" do
  owner "unicorn"
  group "unicorn"
end

git "clone redmine" do
  user "unicorn"
  destination "/home/unicorn/redmine"
  repository "https://github.com/redmine/redmine.git"
  revision "3.2.3"
end

remote_file "/home/unicorn/redmine/config/database.yml" do
  owner "unicorn"
  group "unicorn"
end

remote_file "/home/unicorn/redmine/Gemfile.local" do
  owner "unicorn"
  group "unicorn"
end

remote_file "/home/unicorn/redmine/config/unicorn.rb" do
  owner "unicorn"
  group "unicorn"
end

execute "bundle install" do
  user "unicorn"
  cwd "/home/unicorn/redmine"
  command "bundle install --path .bundle --without development test"
end

execute "bundle update" do
  user "unicorn"
  cwd "/home/unicorn/redmine"
  command "bundle update"
end

execute "redmine rake generate_secret_token" do
  user "unicorn"
  cwd "/home/unicorn/redmine"
  command "bundle exec rake generate_secret_token"
end

execute "redmina db migration" do
  cwd "/home/unicorn/redmine"
  command "RAILS_ENV=production bundle exec rake db:migrate"
end

execute "redmine load_default_data" do
  cwd "/home/unicorn/redmine"
  command "RAILS_ENV=production REDMINE_LANG=ja bundle exec rake redmine:load_default_data"
end

execute "chmod tmp/" do
  command "chmod 777 /home/unicorn/redmine/tmp"
end

execute "chmod db/" do
  command "chmod 777 /home/unicorn/redmine/db"
end

execute "chmod redmine.db" do
  command "chmod 777 /home/unicorn/redmine/db/redmine.db"
end

remote_file "/lib/systemd/system/redmine-unicorn.service"

service "redmine-unicorn" do
  action :restart
end

service "redmine-unicorn" do
  action :enable
end

remote_file "/etc/nginx/sites-available/redmine"

link "/etc/nginx/sites-enabled/redmine" do
  to "/etc/nginx/sites-available/redmine"
end

file "delete nginx site-enabled/default" do
  action :delete
  path "/etc/nginx/sites-enabled/default"
end

service "nginx" do
  action :restart
end

service "nginx" do
  action :enable
end
