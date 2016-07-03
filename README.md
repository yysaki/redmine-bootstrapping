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
git clone https://github.com/yysaki/redmine-bootstrapping.git
cd redmine-bootstrapping
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

TODO
----

* OP25B絡みか本設定ではメール送信が行えない。
    * bootstrap.sh のコメントにこれを回避するためリレー先をgmailにするworkaroundを記載している。
