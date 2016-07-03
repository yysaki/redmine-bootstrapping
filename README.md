redmine-bootstrapping
=====================

Vagrantにてredmine、gitoliteのサーバーを立てるためのスクリプト。

* 母艦の想定: HomeBrewインストール済みのmac
* ゲストOS: Ubuntu 16.04 LTS

後々Ansibleなどにまとめたい。

実行手順
--------

### vagrant sshまで

``` sh
brew install virtualbox
brew install vagrant
mkdir ~/vagrant
cd ~/vagrant
vagrant init ubuntu/xenial64
vagrant up
vagrant ssh
```

### ゲストサーバーのセットアップ

``` sh
vagrant ssh
sh /vagrant/bootstrap.sh
```

動作確認
--------

### redmine

`http://localhost:8080/` にアクセス

### gitolite

``` sh
vagrant ssh
git clone git@localhost:testing.git
```
