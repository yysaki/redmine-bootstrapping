redmine-bootstrapping
=====================

Vagrantにてredmine、gitoliteのサーバーを立てるためのスクリプト。

* 母艦の想定: HomeBrewインストール済みのmac
* ゲストOS: Ubuntu 16.04 LTS
* [itamae](https://github.com/itamae-kitchen/itamae/) を利用

実行手順
--------

### vagrant sshまで

``` sh
brew cask install virtualbox
brew cask install vagrant
git clone https://github.com/yysaki/redmine-bootstrapping.git
cd redmine-bootstrapping
vagrant up
vagrant ssh
```

### ゲストサーバーのセットアップ

``` sh
gem install bundler
bundle install --path vendor/bundler
bundle exec itamae ssh --vagrant sabaku.rb
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
