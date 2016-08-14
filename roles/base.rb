execute "GUI選択の抑制" do
 command "echo 'set grub-pc/install_devices /dev/sda' | debconf-communicate"
end

execute 'apt-get update' do
  command 'apt-get update'
end

execute 'apt-get-upgrade' do
  command 'apt-get upgrade -y'
end
