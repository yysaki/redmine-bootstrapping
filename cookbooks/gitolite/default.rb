package "git"

user "create git user" do
  username "git"
  password ""
  home "/srv/git"
  shell	"/bin/bash"
end

directory "/srv/git" do
  owner "git"
  group "git"
end

execute "Generate vagrant user key" do
  user "vagrant"
  command "ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa  -N ''"
  not_if "test -e /home/vagrant/.ssh/id_rsa"
end

execute "Copy id_rsa.pub key" do
  command "cp /home/vagrant/.ssh/id_rsa.pub /srv/git/admin.pub"
end

execute "chown admin.pub" do
  command "chown git:git /srv/git/admin.pub"
end

execute "Generate git user key" do
  user "git"
  command "ssh-keygen -t rsa -b 4096 -f /srv/git/.ssh/id_rsa -N ''"
  not_if "test -e /srv/git/.ssh/id_rsa"
end

execute "touch authorized_keys" do
  user "git"
  command "touch /srv/git/.ssh/id_rsa"
end

git "clone gitolite" do
  user "git"
  destination "/srv/git/gitolite"
  repository "http://github.com/sitaramc/gitolite.git"
end

directory "/srv/git/bin" do
  owner "git"
  group "git"
end

remote_file "/srv/git/.bashrc" do
  owner "git"
  group "git"
end

execute "gitolite/install" do
  user "git"
  command "/srv/git/gitolite/install -ln /srv/git/bin"
end

execute "gitolite setup" do
  user "git"
  command "/srv/git/bin/gitolite setup -pk admin.pub"
end
