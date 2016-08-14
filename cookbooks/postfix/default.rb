package "mailutils"

remote_file "/etc/postfix/main.cf"

service "postfix" do
  action :restart
end
