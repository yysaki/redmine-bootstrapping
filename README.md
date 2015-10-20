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

```
sh bootstrap.sh
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

