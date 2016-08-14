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
