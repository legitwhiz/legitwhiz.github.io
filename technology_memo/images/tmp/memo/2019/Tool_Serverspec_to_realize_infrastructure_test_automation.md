---
layout: default
title: インフラのテスト自動化を実現するツール「Serverspec」
---

# インフラのテスト自動化を実現するツール「Serverspec」



![login001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Serverspec_logo.png)

## 1.自動テストツール

### 1.1. 目的

【自動テストツール】を導入する目的は、DevOpsの一環として、テスト工程の自動化も視野に入れ自動化により運用の効率化を図る目的と考えて調査・検証した結果を以下の記事を記載します。


### 1.2. 自動テストツールとは？

度重なるCIによって都度同じテストを人手でするのは、あまりにも非効率ですよね？
決まり切ったテストなら自動化し【効率性】を上げ生産性を向上すると共に、テストの人為的なミスを削減し【品質向上】が可能な【テスト自動化ツール】を導入するべきでしょう。


[テスト自動化研究会【テスト自動化の8原則】](https://sites.google.com/site/testautomationresearch/)

以上を読んでいただけると分かると思いますが、自動化したテストに関しては人手が必要なくなるだけで、結果を確認する工程やテスト内容を考えるのは人手は必要です。

また、手動テストもなくならないことを踏まえたうえで自動テストツールを導入する必要があります。

既に自動テストツールを導入しているプロジェクトの殆どが、事の大小はあっても問題を抱えていることを認識したうえで導入の検討をして下さい。



### 1.3. 自動化すべきテスト項目の条件

まず、全てのテストが自動化すればいいのではありません。

自動化したことにより、テスト結果が望む結果であったとしても他要因でNGとなるケースを見落とすことになります。(例えばWebサービスで画面遷移に関わるテストを自動実行し、画面遷移自体は想定通りになったとしてもレイアウトや画像が間違って変わっていてもツールでは気付けない等)

自動化したほうが品質の良いテストを実施でき効率化するためにツールであることを認識したうえでテスト項目を選定することを考える。

また、文字列や数字などのテキストデータの判別は自動テストツールで容易にチェックできますが、画像やランダム性があるものの確認は自動テストツールでは実現は難しく、できたとしても品質担保を説得力のある証拠で提示するのが難しいため、手動でのテストとするべきです。



以上より自動化すべきテスト項目の条件を以下とします。

- CIの度に実施すべきテスト。(同じテストを何度も繰り返し実行する内容)

- 既にテストコードがあり、そのテストコードで品質担保が可能であること。

- テストの確認内容が自動化ツールで全て網羅できる範疇であること。

- CIの度にテストコードを改修しなくてもよいこと。改修したとしても僅かであり影響範囲が小さいこと。

  

### 1.4. テスト自動化ツール選定

テスト自動化ツールも用途により多種多様です。そのため、プロジェクトに合ったツールを選定することから始める必要があります。

**[Webアプリケーションテスト自動化ツール「Selenium」](http://www.seleniumhq.org/)**

対象：Webアプリケーション
動作環境：ブラウザ拡張、クライアントサーバーモデル
特徴：ブラウザ上で動作するWebアプリのテストを自動化するツールです。キャプチャー・リプレイ機能では、実際に行ったテストを再現することも可能です。

「Selenium IDE」により、プログラミング言語の知識が少ない人でも、簡単にテストをできるようにブラウザ操作を記録してテストスクリプトを作成する機能も備わっています。

**[Webアプリケーションテスト自動化ツール「Jenkins」](https://jenkins.io/index.html)**

対象：Webアプリケーション
動作環境：Windows、UNIX、Linux、MacOS等
特徴：継続的インテグレーション（CI）ツールとして有名ですが、Jenkinsにテストを自動的に行うプラグインを紐づけることにより、スケジューラー機能による定期的なテスト実行が可能になります。

**[Javaアプリケーション単体テスト自動化ツール「JUnit」](http://daikoku.ebis.ne.jp/tr_set.php?argument=YdgXyNfQ&ai=a59a912713367b)**

対象：Javaモジュール
動作環境：Linux
特徴：Javaのテストを小さな単位でテスト可能。

**[ITインフラテスト自動化ツール「Serverspec」](https://serverspec.org/)**

対象:サーバの設定値やパッケージがインストール確認、特定サービスの状態確認、指定ポートでの通信のテストを自動化できる。
動作環境：
特徴:サーバの設定、状態が想定通りになっているかチェックできる。
サーバにエージェントを導入する必要性がない。

他にも

**[スマートフォンアプリテスト自動化ツール「Appium」](http://appium.io/)**

**[Windowsアプリケーションテスト自動化ツール「QCWing」](https://www.jnovel.co.jp/service/qcwing/)**

**[負荷テスト自動化ツール「Apache Jmeter」](http://jmeter.apache.org/)**

と試験内容に応じて色々な製品が存在します。



### 1.5. 自動テストツール選定

私はITインフラ開発者なので【Serverspec】を
今までのExcelで書かれたパラメータシートを実機をにらめっこして、ITインフラの単体試験としていた現場が多いと思われます。それを自動化することで他の作業に工数を割くことができればより開発を促進し信頼性の高いものを提供することが可能となります。

### 1.6. Serverspecとは？

Serverspec(サーバスペック)とは、サーバ状態のテスト自動化フレームワークです。UNIX/LinuxサーバとWindowsサーバに対応します。
構築したサーバ環境が意図した通り構成されているか自動的に確認作業を実施できるツールです。
Serverspecは、Rubyで実装されています。
構成管理ツール(Ansibleなど)で自動築したサーバを想定通りの設定及びあるべき姿であることの確認までを繰り返しテストを行い、【常にあるべき姿を維持しているか】をチェックできます。

Serverspecが導入されたサーバからテストを実施するためは、エージェントは必要なく、LinuxであればSSH接続、WindowsサーバはWinRM接続可能な環境であれば実現可能となっているため、手軽に組み込むことも可能となっている。



## 2. Serverspecインストール

参考にしたサイト

[Serverspecでテスト自動化 - IDCF テックブログ](http://blog.idcf.jp/entry/serverspec-auto-test)

[「Serverspec」を使ってサーバー環境を自動テストしよう | さくらのナレッジ](https://knowledge.sakura.ad.jp/2596/)

[大規模サーバ更改でServerspecを使ってみました - Taste of Tech Topics](http://acro-engineer.hatenablog.com/entry/2016/11/22/120000)

### 2.1. 検証環境

OS:CentOS 7.5
ミドルウェア:serverspec(2.41.3),rake(12.3.2),bundler(2.0.1),winrm(2.3.1)
前提ミドルウェア:ruby(2.3.8)、openssl-devel(1.0.2k-16)、readline-devel(l-6.2-10)、zlib-devel(1.2.7-18)

### 2.2. Ruby2.3.8インストール

```
# yum install -y openssl-devel readline-devel zlib-devel
# cd /root
# git clone git://github.com/sstephenson/rbenv.git .rbenv
# cd .rbenv
# mkdir shims versions plugins
# cd plugins/
# git clone https://github.com/sstephenson/ruby-build.git ruby-build
# git clone git://github.com/sstephenson/rbenv-default-gems.git rbenv-default-gems
# vi ~/.rbenv/default-gems
bundler
rbenv-rehash

# vi ~/.bashrc
export RBENV_ROOT="/root/.rbenv"
export PATH="$PATH:$RBENV_ROOT/bin"
eval "$(rbenv init -)"

# source ~/.bashrc
# cd /root
# rbenv install -l   #※1

# rbenv install 2.3.8
# rbenv global 2.3.8
# ruby -v
```



※1:`rbenv install -l`で`rbenv: no such command install`とメッセージが出力される場合は既に古いrubyを導入してため、以下コマンドで回避することができます。

```
# .rbenv/plugins/ruby-build/install.sh
```



### 2.2. Serverspecインストール

```
# gem install bundler※1
# bundle init       # GemfileとGemfile.lockが作成されます。
# vi Gemfile
# 以下を追記
gem "serverspec"
gem "rake"
gem "winrm"     #windowsへのテストを実施する場合にインストール
# bundle install --path ./   # bundlerによりGemfileに書かれたgemをインストールする

```

※1:bundlerに関しては、[bundler、bundle execについて](https://qiita.com/dawn_628/items/1821d4eef22b9f45eea8)を参照。

### 2.3. Serverspec初期設定

Serverspecの初期設定をするため`serverspec-init`コマンドを実行し、質問に応答します。

```
# bundle exec serverspec-init
Select OS type:

  1) UN*X
  2) Windows

Select number: 1  # serverspecのクライアントのOSタイプの選択でUNIXである"1"を選択

Select a backend type:

  1) SSH
  2) Exec (local)

Select number: 1  # serverspecのクライアントの接続方式の選択でSSHである"1"を選択

Vagrant instance y/n: n # Vagrantは、私の環境では未使用のため"n"を選択
Input target host name: web01 # クライアントのホスト名を入力 ※1
 + spec/
 + spec/web01/
 + spec/web01/sample_spec.rb
 + spec/spec_helper.rb
 + Rakefile
 + .rspec
```

※1:クライアントを入力するとサンプルのテストコードが作成されます。

### 2.4. 標準的な構成

テスト実行コマンド`rake`は、Rakefileを最初に読み込み、対象となるspecディレクトリ配下のテストコードファイル(*_spec.rd)を実行します。

テスト対象のサーバを複数台とする場合は、標準的な構成すると以下のような構成となります。

```txt

 ├─ Rakefile
 ├─ Gemfile
 ├─ Gemfile.lock
 ├─ .rspec
 ├─ ruby
 │  └─ 2.3.8
 │
 └─ spec/
    ├─ web01/
    │  ├ base_spec.rb
    │  └ httpd_spec.rb
    ├─ web02/
    │  ├ base_spec.rb
    │  └ httpd_spec.rb
    ├─ app01/
    │  ├ base_spec.rb
    │  └ tomcat_spec.rb
    ├─ spec/db01/
    │  ├ base_spec.rb
    │  └ mysql_spec.rb
    └─ spec_helper.rb
 
```

テストを個々に実行する場合は、rakeコマンドの引数に`spec:<サーバアドレス>`を指定する。

```
# bundle exec rake spec:web01
```

だが、この構成だとサーバが増える度にサーバ毎のフォルダを作成し、同じ種別のサーバのテストコードファイルをコピーしなければならない。また、テスト実行も全てもしくはサーバ単位となることに留意すること。



## 3. role

Serverspecを運用するにあたり、標準構成では、上記理由によりサーバ台数規模が膨大になると管理が大変になるため、roleによるサーバ種別毎のテスト内容を分けたいと思います。

role構成については、[Serverspec用のspec_helperとRakefileのサンプルをひとつ](https://qiita.com/sawanoboly/items/98854fbb4b49e66f6c3c)を参考にさせていただきました。

### 3.1. role構成

role構成するにあたり、以下のようなディレクトリ、ファイル構成とします。

```
├── Gemfile
├── Gemfile.lock
├── Rakefile
├── common_spec/        # 他プロジェクトと共通するspecのサブモジュール
│   ├── common/
│   ├── group/
│   ├── user/
│   ├── kernel/
│   ├── firewall/
│   ├── rpm/
│   └── zabbix-agent/
├── ferture_spec/       # プロジェクト特有のspecのサブモジュール
│   ├── group/
│   ├── user/
│   ├── kernel/
│   ├── firewall/
│   ├── rpm/
│   ├── service/
│   ├── cron/
│   ├── logrotate/
│   ├── zabbix-agent/
│   ├── httpd/
│   ├── tomcat/
│   └── mysql/
├── host_vars/          # ホスト特有の値をテストしたい場合に使用
│   ├── dbsvr01.yml
│   └── win-manage01.yml
├── audit
│   └── json/               # テスト証跡
├── hosts_production.yml    # 本番環境のホストとrole一覧
├── hosts_staging.yml       # 開発環境のホストとrole一覧
└── spec/               # helper他。
    └── spec_helper.rb
```



role構成に対応するため、ディレクトリを作っていきます。

```
mkdir -m 755 ./common_spec
mkdir -m 755 ./common_spec/common/
mkdir -m 755 ./common_spec/group/
mkdir -m 755 ./common_spec/group/system
mkdir -m 755 ./common_spec/user/
mkdir -m 755 ./common_spec/user/system
mkdir -m 755 ./common_spec/kernel/
mkdir -m 755 ./common_spec/kernel/system
mkdir -m 755 ./ferture_spec/user/web
mkdir -m 755 ./ferture_spec/user/db
mkdir -m 755 ./ferture_spec/user/ap
mkdir -m 755 ./ferture_spec/kernel/
mkdir -m 755 ./ferture_spec/kernel/web
mkdir -m 755 ./ferture_spec/kernel/db
mkdir -m 755 ./ferture_spec/kernel/ap
mkdir -m 755 ./ferture_spec/firewall/
mkdir -m 755 ./ferture_spec/firewall/web
mkdir -m 755 ./ferture_spec/firewall/db
mkdir -m 755 ./ferture_spec/firewall/ap
mkdir -m 755 ./ferture_spec/rpm/
mkdir -m 755 ./ferture_spec/rpm/web
mkdir -m 755 ./ferture_spec/rpm/db
mkdir -m 755 ./ferture_spec/rpm/ap
mkdir -m 755 ./ferture_spec/service/
mkdir -m 755 ./ferture_spec/service/web
mkdir -m 755 ./ferture_spec/service/db
mkdir -m 755 ./ferture_spec/service/ap
mkdir -m 755 ./ferture_spec/cron/
mkdir -m 755 ./ferture_spec/cron/web
mkdir -m 755 ./ferture_spec/cron/db
mkdir -m 755 ./ferture_spec/cron/ap
mkdir -m 755 ./ferture_spec/logrotate/
mkdir -m 755 ./ferture_spec/logrotate/web
mkdir -m 755 ./ferture_spec/logrotate/db
mkdir -m 755 ./ferture_spec/logrotate/ap
mkdir -m 755 ./ferture_spec/zabbix-agent/
mkdir -m 755 ./ferture_spec/zabbix-agent/staging
mkdir -m 755 ./ferture_spec/zabbix-agent/production
mkdir -m 755 ./ferture_spec/httpd/
mkdir -m 755 ./ferture_spec/httpd/staging
mkdir -m 755 ./ferture_spec/httpd/production
mkdir -m 755 ./host_vars
mkdir -m 755 ./audit
mkdir -m 755 ./audit/json
```



#### 3.1.1 アドレス、roleファイル

まずは、環境毎(hosts_production、hosts_staging)にアドレス及びroleを記載するファイルをyamlファイルを分ける方針としています。

また、hosts配下にターゲットとなるアドレス(IPアドレス、名前解決できる環境であればホスト名)を設定し、roles配下で実行するtaskのディレクトリを設定します。

各タスクのディレクトリ配下に実施にテストを実施する内容を[*_spec.rb]に設定する。

例えばuserテスト定義ファイルの場合、[common_spec/user/system/user_spec.rb]、[ferture_spec/user/web/user_spec.rb]、[ferture_spec/user/db/user_spec.rb]、[ferture_spec/user/ap/user_spec.rb]と４つ保持しているが、テスト実行コマンドの引数でwebと指定した場合は、roleの設定で[common_spec/user/system/user_spec.rb]、[ferture_spec/user/web/user_spec.rb]だけをテストする仕組みとなっています。

また、環境毎(hosts_production、hosts_staging)に設定内容に差異が存在するようなテストをroleで吸収するため、[zabbix-agent/staging/zabbix-agent_spec.rb]、[zabbix-agent/production/zabbix-agent_spec.rb]と分けroleで指定環境のテストのみを実施する仕組みとなっています。



hosts_staging.yml

```yaml
---
shared_settings:
  :ssh_opts:
    :user: operator
    :keys: /home/operator/.ssh/id_rsa
    :port: 22
web:
  :hosts:
    - web01.sdomain.com
    - web02.sdomain.com
  :roles:
    - common
    - group/system
    - user/system
    - user/web
    - kernel/system
    - kernel/web
    - firewall/web
    - rpm/web
    - service/web
    - cron/web
    - logrotate/web
    - zabbix-agent/staging
    - httpd/staging
db:
  :hosts:
    - db01.sdomain.com
  :roles:
    - common
    - group/system
    - user/system
    - user/db
    - kernel/system
    - kernel/db
    - firewall/db
    - rpm/db
    - service/db
    - cron/db
    - logrotate/db
    - zabbix-agent/staging
    - mysql/staging
app:
  :hosts:
    - ap01.sdomain.com
  :roles:
    - common
    - group/system
    - user/system
    - user/ap
    - kernel/system
    - kernel/ap
    - firewall/ap
    - rpm/ap
    - service/ap
    - cron/ap
    - logrotate/ap
    - zabbix-agent/staging
    - tomcat/staging
```

hosts_production.yml

```yaml
---
shared_settings:
  :ssh_opts:
    :user: operator
    :keys: /home/operator/.ssh/id_rsa
    :port: 22
web:
  :hosts:
    - web01.domain.com
    - web02.domain.com
    - web03.domain.com
    - web04.domain.com
  :roles:
    - common
    - group/system
    - user/system
    - user/web
    - kernel/system
    - kernel/web
    - firewall/web
    - rpm/web
    - service/web
    - cron/web
    - logrotate/web
    - zabbix-agent/production
    - httpd/production
db:
  :hosts:
    - db01.domain.com
    - db02.domain.com
  :roles:
    - common
    - group/system
    - user/system
    - user/db
    - kernel/system
    - kernel/db
    - firewall/db
    - rpm/db
    - service/db
    - cron/db
    - logrotate/db
    - zabbix-agent/production
    - mysql/production
app:
  :hosts:
    - ap01.domain.com
    - ap02.domain.com
  :roles:
    - common
    - group/system
    - user/system
    - user/ap
    - kernel/system
    - kernel/ap
    - firewall/ap
    - rpm/ap
    - service/ap
    - cron/ap
    - logrotate/ap
    - zabbix-agent/production
    - tomcat/production
```




#### 3.1.2. Rakefile

【標準Rakefile】

```
require 'rake'
require 'rspec/core/rake_task'

task :spec    => 'spec:all'
task :default => :spec

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == "default"
    targets << target
  end

  task :all     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == "_default" ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = original_target
      t.pattern = "spec/#{original_target}/*_spec.rb"
    end
  end
end
```

標準Rakefileでは、引数によって対象サーバや実行内容を分ける構成となるrole対応できないためrole対応できるように書き換えます。

【role対応Rakefile】

```
require 'rake'
require 'yaml'
require 'rspec/core/rake_task'

## 環境変数 SPEC_ENV で環境名を指定。
spec_env = ENV['SPEC_ENV']
if spec_env
  path_candidate = File.expand_path("../hosts_#{spec_env}.yml", __FILE__)
  if File.exists?(path_candidate)
    hosts_defined = path_candidate
  else
    raise RuntimeError, "\n======\nERROR: No hosts defined for #{spec_env}.\n======"
  end
else
  ## SPEC_ENV が省略されたら終了
  
  end
end


## 環境名に対応する定義ファイルを読む
properties = YAML.load_file(hosts_defined)

task :spec    => 'spec:all'
task :default => :spec

namespace :spec do
  ## 定義ファイルから spec:大分類:ホスト名を全部作成する。spec:all 用
  all_tasks = properties.each_pair.map { |key, values|
    ## 共通設定はホスト扱いしない。
    next if key == 'shared_settings'
    values[:hosts].map {|host| 'spec:' + key + ':' + host }
  }.flatten.compact

  ## 全部実行するタスク (spec:all)
  desc "all target for #{spec_env}"
  task :all => all_tasks

  ## ホスト定義をまわす、大分類はmaster_rollって名前で扱う
  properties.each_pair do |master_roll, entries|
    ## 共通設定は大分類扱いしない(spec_helperで使う)
    next if master_roll == 'shared_settings'

    ## 大分類に割り当てられているroleを抽出する
    role_pattern = entries[:roles].join(',')

    namespace master_roll.to_sym do
      hosts = entries[:hosts]

      ## 大分類別に全ホスト実行するタスク (spec:大分類:all)
      desc "all target of #{master_roll} for #{role_pattern}"
      task :all => hosts.map {|h| 'spec:' + master_roll + ':' + h }

      ## 大分類別に個別ホスト実行するタスクを定義する (spec:大分類:ホスト名)
      hosts.each do |host|
        desc "Run serverspec tests to #{master_roll}: #{host} for #{role_pattern}"
        RSpec::Core::RakeTask.new(host.to_sym) do |t|
          ## どれかがこけても途中でやめない。
          t.fail_on_error = false
          ENV['TARGET_HOST'] = host
          ENV['SPEC_ENV'] = spec_env

          ## specとcommon_specとferture_specをざっくり取って、定義ファイル上のロールに対応するspecを読み込ませる。
          t.pattern = "{spec,common_spec,ferture_spec}/{#{role_pattern}}/**/*_spec.rb"
          t.rspec_opts = "--format json -o audit/json/#{host}.json" #jsonでログ出力
        end
      end
    end
  end
end
```



#### 3.1.3. helperファイル

各クライアントの接続方式やsshの環境別オプション、dockerにも対応など環境などに合わせるため、spec_helperを修正します。

```
require 'serverspec'
require "docker"
require 'net/ssh'
require 'yaml'

case ENV['SPEC_BACKEND']
## 環境変数 SPEC_BACKEND がdocker|DOCKERだったらSSHじゃなくてDockerバックエンドを使う。
when "DOCKER", 'docker'
  set :backend, :docker
  set :docker_url, ENV['DOCKER_HOST'] || 'unix:///var/run/docker.sock'
  ## Dockerでためす場合、DOCKER_IMAGEを指定する。
  set :docker_image, ENV['DOCKER_IMAGE']
  set :docker_container_create_options, {'Cmd' => ['/bin/sh']}
  Excon.defaults[:ssl_verify_peer] = false
else
  ## デフォルトのバックエンドはSSH
  set :backend, :ssh
  set :request_pty, true

  ## このへんはRakeと一緒、定義ファイルを決定
  spec_env = ENV['SPEC_ENV']
  if spec_env
    path_candidate = File.expand_path("../../hosts_#{spec_env}", __FILE__)
    puts path_candidate
    if File.exists?(path_candidate)
      hosts_defined = path_candidate
    else
      raise RuntimeError, "\n======\nERROR: No hosts defined for #{spec_env}.\n======"
    end
  else
    hosts_defined = File.expand_path("../../hosts_staging", __FILE__)
  end


  ## spec_helperでもRakefile同様にホスト定義を読み込む
  properties = YAML.load_file(hosts_defined)

  host = ENV['TARGET_HOST']
  mainrole = properties.select {|k,v| v[:hosts].include?(host) if v[:hosts] }.keys.first

  ## ホスト固有の値を書いたファイルがあればつかう。
  host_vars = YAML.load_file(
    File.expand_path("../../host_vars/#{host}.yml", __FILE__)
  ) if File.exists?(File.expand_path("../../host_vars/#{host}.yml", __FILE__))

  spec_property =  properties[mainrole]
  spec_property[:host_vars] =  host_vars ||= {}

  ## 環境変数DEBUGがあったらset_propertyに渡される値を表示する
  puts spec_property.to_yaml if ENV['DEBUG']

  set_property spec_property

  ## specの中で大分類を使うかもしれないと思ってとりあえず環境変数に突っ込んである。
  ENV['SPEC_MAINROLE'] = mainrole

  ## 環境別SSH接続設定をマージしていく
  options = Net::SSH::Config.for(host).merge(properties['shared_settings'][:ssh_opts])

  ### 大分類の下にもssh_optsがあったらそっちを優先で上書き
  options.merge!(properties[mainrole][:ssh_opts]) if properties[mainrole][:ssh_opts]
  options[:user] ||= 'root'
  options[:keys] ||= File.expand_path("#{ENV['HOME']}/.ssh/my_staging_key" ,__FILE__)

  set :host,        options[:host_name] || host
  set :ssh_options, options

  # Disable sudo
  # set :disable_sudo, true

  RSpec.configure do |config|
    config.color = true
    config.tty = true
  end

  # Set environment variables
  set :env, :LANG => 'C', :LC_MESSAGES => 'C'
end

```





### 3.2. テスト実行コマンド



#### 3.2.1. role対象サーバの確認

roleはRakefileの構成により環境変数(SPEC_ENV)により、本番環境(SPEC_ENV=production)と検証環境(SPEC_ENV=staging)を分けることが出来ように実装しています。また、さらにサーバ種別毎(spec:web:all)やサーバ単体(spec:web:web03.domain.com)、全て(spec:all)とそれぞれ実行できるようにしています。

環境毎のyamlが正常に設定されているか確認します。環境変数(SPEC_ENV)を指定しない場合は、defaultでhosts_staging.yamlを読み込みます。

```
# bundle exec rake -vT
rake spec:all                    # all target for staging
rake spec:app:all                # all target of app for common,group/system,user/system,user/ap,ke...
rake spec:app:ap01.sdomain.com   # Run serverspec tests to app: ap01.sdomain.com for common,group/s...
rake spec:db:all                 # all target of db for common,group/system,user/system,user/db,ker...
rake spec:db:db01.sdomain.com    # Run serverspec tests to db: db01.sdomain.com for common,group/sy...
rake spec:web:all                # all target of web for common,group/system,user/system,user/web,k...
rake spec:web:web01.sdomain.com  # Run serverspec tests to web: web01.sdomain.com for common,group/...
rake spec:web:web02.sdomain.com  # Run serverspec tests to web: web02.sdomain.com for common,group/...
```



`SPEC_ENV=production`を指定し本番環境でのyamlが正常に設定されているか確認。

```
# SPEC_ENV=production bundle exec rake -vT
rake spec:all                   # all target for production
rake spec:app:all               # all target of app for common,group/system,user/system,user/ap,kernel/system,kernel/ap,firewall/ap,rpm/ap,service/ap,cro...
rake spec:app:ap01.domain.com   # Run serverspec tests to app: ap01.domain.com for common,group/system,user/system,user/ap,kernel/system,kernel/ap,firewa...
rake spec:app:ap02.domain.com   # Run serverspec tests to app: ap02.domain.com for common,group/system,user/system,user/ap,kernel/system,kernel/ap,firewa...
rake spec:db:all                # all target of db for common,group/system,user/system,user/db,kernel/system,kernel/db,firewall/db,rpm/db,service/db,cron...
rake spec:db:db01.domain.com    # Run serverspec tests to db: db01.domain.com for common,group/system,user/system,user/db,kernel/system,kernel/db,firewal...
rake spec:db:db02.domain.com    # Run serverspec tests to db: db02.domain.com for common,group/system,user/system,user/db,kernel/system,kernel/db,firewal...
rake spec:web:all               # all target of web for common,group/system,user/system,user/web,kernel/system,kernel/web,firewall/web,rpm/web,service/we...
rake spec:web:web01.domain.com  # Run serverspec tests to web: web01.domain.com for common,group/system,user/system,user/web,kernel/system,kernel/web,fir...
rake spec:web:web02.domain.com  # Run serverspec tests to web: web02.domain.com for common,group/system,user/system,user/web,kernel/system,kernel/web,fir...
rake spec:web:web03.domain.com  # Run serverspec tests to web: web03.domain.com for common,group/system,user/system,user/web,kernel/system,kernel/web,fir...
rake spec:web:web04.domain.com  # Run serverspec tests to web: web04.domain.com for common,group/system,user/system,user/web,kernel/system,kernel/web,fir...
[root@sakamoto_test ~]#
```



#### 3.2.2. role対象サーバのテスト実行

```
# SPEC_ENV=production bundle exec rake spec:all  #本番環境の全てのサーバ
# SPEC_ENV=production bundle exec rake spec:db:all  #本番環境のdbサーバ全て
# SPEC_ENV=production bundle exec rake spec:web:web01.domain.com  #本番環境のweb01.domain.comサーバのみ
```

#### 3.2.3 実行結果確認


```
# cat audit/json/#{host}.json | jq '.'
```



## 4. テストスクリプト記述方法

テストスクリプトのフォーマットは以下のようになっています。

各リソースタイプの詳細は、[公式HP リソースタイプ](https://serverspec.org/resource_types.html)を参照。

```
describe ＜リソースタイプ＞(＜テスト対象＞) do
  ＜テスト条件＞
  ：
  ：
end
```

#### インストールパッケージ

```
describe package('httpd') do  ←「httpd」パッケージに関するテスト
  it { should be_installed.with_version('2.4.6-80') }  ←パッケージがインストールされているか？
end
```

#### サービス設定及び状態

```
describe service('httpd') do  ←「httpd」サービスに関するテスト
  it { should be_enabled   }  ←サービスが有効になっているか？
  it { should be_running   }  ←サービスが実行されているか？
end
```

#### ポート状態

```
describe port(80) do  ←80番ポートに関するテスト
  it { should be_listening }  ←ポートが待ち受け状態になっているか？
end
```

#### ファイル

```
describe file('/etc/httpd/conf/httpd.conf') do ←「/etc/httpd/conf/httpd.conf」ファイルに関するテスト
  it { should be_file }  ←ファイルが存在するか？
  its(:content) { should match /ServerName localhost/ }  ←ファイル内に「/ServerName localhost/」にマッチするテキストが存在するか？
    it { should be_owned_by('root') }
    it { should be_grouped_into('root') }
    it { should be_mode 755}
end
```

#### ディレクトリ

```
describe file("/var/path/directory/") do
  it { should be_directory }           # directoryかどうか
  it { should be_owned_by 'root'}      # オーナーがrootか
  it { should be_grouped_into 'root'}  # グループがrootか

  # 中でif文を書くことも出来ます
  if dir1 == 'conf'
    it { should be_mode 700}
  else
    it { should be_mode 755}
  end
end
```

#### cron エントリー

```
describe cron do
  it { should have_entry '* * * * * /usr/local/bin/foo' }
end
```

#### cron エントリー(特定ユーザ)

```
describe cron do
  it { should have_entry('* * * * * /usr/local/bin/foo').with_user('foo') }
end
```

#### group

```
describe group('foo_group') do
  it { should exist }
  it { should have_gid 100 }
end
```

#### User

```
describe user('foo') do
  it { should exist }
  it { should belong_to_group 'foo_group' }
  it { should have_uid 100 }
  it { should have_home_directory '/home/foo' }
  it { should have_login_shell '/bin/bash' }
  it { should have_authorized_key 'ssh-rsa <SSH公開鍵> foo@bar.local' }
end
```

#### ネットワークインターフェース設定

```
describe interface('eth0') do
  its(:speed) { should eq 1000 }
  it { should have_ipv4_address("192.168.10.10") }
  it { should have_ipv4_address("192.168.10.10/24") }
end
```

#### ネットワーク疎通

```
describe host('web01.domain.com') do
  # ping
  it { should be_reachable }
  # tcp port 22
  it { should be_reachable.with( :port => 22 ) }
  # set protocol explicitly
  it { should be_reachable.with( :port => 22, :proto => 'tcp' ) }
  # udp port 53
  it { should be_reachable.with( :port => 53, :proto => 'udp' ) }
  # timeout setting (default is 5 seconds)
  it { should be_reachable.with( :port => 22, :proto => 'tcp', :timeout => 1 ) }
end
```

#### デフォルトゲートウェイ

```
describe default_gateway do
  its(:ipaddress) { should eq '192.168.1.1' }
  its(:interface) { should eq 'eth0'          }
end
```

#### 静的ルーティング

```
describe routing_table do
  it do
    should have_entry(
      :destination => '192.168.100.0/24',
      :interface   => 'eth1',
      :gateway     => '192.168.10.1',
    )
  end
end
```

#### firewalld

```
describe firewalld do
    its(:default_zone) { should contain 'public' }
    it { should have_port('161/udp') }
    it { should have_service('ssh') }
    it { should have_source('192.160.0.100/32') }
    it { should have_interface('eth0') }
  end
```

#### カーネルパラメータ

```
describe 'Linux kernel parameters' do
  context linux_kernel_parameter('net.ipv4.tcp_syncookies') do 
    its(:value) { should eq 1 }
  end

  context linux_kernel_parameter('kernel.shmall') do
    its(:value) { should be >= 4294967296 }
  end

  context linux_kernel_parameter('kernel.shmmax') do
    its(:value) { should be <= 68719476736 }
  end

  context linux_kernel_parameter('kernel.osrelease') do
    its(:value) { should eq '2.6.32-131.0.15.el6.x86_64' }
  end

  context linux_kernel_parameter('net.ipv4.tcp_wmem') do
    its(:value) { should match /4096\t16384\t4194304/ }
  end
end
```

#### 確認コマンド(LDAP search)

```
ldapsearch_command = "ldapsearch -x -h 127.0.0.1 -b "認証に必要な情報" -w #{password}"

describe command("#{ldapsearch_command} \"uid=idname\"  |grep 'ftpUID:'|awk '{print $抜き取る場所}'") do
  its(:exit_status) {should match eq 0} 
  its(:stdout) {should match 検証する文字列}
end
```

#### 確認コマンド(Webサイトへのアクセス確認)

```
hostname=host_inventory['hostname']
# httpd port open check
describe command("curl http://#{hostname}/wp-admin/install.php") do
  its(:stdout) { should contain('WordPress') }
end
```



## 最後に

こんなにも簡単にテストできるなんて、驚きの一言です。それも早い。
繰り返しテストを実施しなければならない状況なら尚更ですね。

テストスクリプトもバージョン管理できるし、工夫すれば実行結果をCSV化することも可能なのでヘッダーを付けExcelすればテスト結果報告書の作成もあっと言う間にできちゃいます。

もちろん、全てをserverspecで自動化することは不可能でしょうが、部分的に自動化することができるだけでも工数削減はいとも簡単に実現できることは確実でしょう。

