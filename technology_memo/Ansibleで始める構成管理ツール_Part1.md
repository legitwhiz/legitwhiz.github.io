# Ansibleで始める構成管理ツール_Part1

##  Ansibleとは

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Ansible/Ansible.png" width="420">

**【Ansible】**とは、『構成管理ツール』です。

何を構成管理するかというと、サーバのインフラをコードで管理する**【Infrastructure as a Code】**ツールで、**【Chef】**や**【Puppet】**などと同様なツールです。

**【Chef】**や**【Puppet】**では、高度な管理を行うとするとRubyが前提となっているので、インフラ開発者では学習コストが高く、エージェントが必要となるため導入のハードルが高い。

それに対して**【Ansible】**は、以下の特徴を持っている。

- **エージェントレスな構成管理ツール**

- **クライアントは、SSH接続(要鍵認証)でき、Pythonが導入されていること**

- **設定がシンプル(そのため、複雑なことは苦手)**

- **ツールにより、冪等性(べきとうせい)を担保**

  ただし、AnsibleはOSにIPアドレスが設定されており、接続条件を満たしている必要があります。

  したがって、OSインストールを自動化するには、**【Kickstart】**や**【Cobbler】**等が必要です。

## なぜAnsibleが必要なのか？

**【現状】**

サーバ構築作業の現状は、
設計書をもとにパラメータシートや構築手順書を作成し、
構築手順書をもとに構築作業を実施し、設定値はパラメータシートを設定作業を実施している。
試験にてパラメータシート通りに設定されているか確認し、設計書通りの動作をするか確認する。

**【問題点、リスク】**

大量にサーバ構築する場合は、時間的に無駄が多い。(バックアップリストアで問題は一部解消されるが、部分的に設定を修正する必要性がある)
同じことの繰り返しとなることから、オペミス、設定値の取り違えが発生するリスクがある。(試験で問題は解消されるが、確認する側も同じことの繰り返しになることから、間違いをスルーしてしまうリスクがあり時間的な無駄が発生する)
設計書を修正した場合、実機反映漏れが発生するリスクがある。(構築時点でconfigファイルもバージョン管理、CIも実施していれば回避可能)

**【結論】**

以上より、**【構成管理ツール】**で機械的に構築されたサーバであれば、リスクを軽減でき時間的な工数削減が望める。ただし、プロジェクトメンバーが運用ルールを絶対としているのが条件です。
ただし、現状ベンダーやSIerでは、機械的に構成をしても継続的に単体試験というパラメータの設定確認は実施すると思われる時間的な工数削減は僅かなのかもしれません。

**【メリット】**

構成管理ツールを導入することで、リスク削減と工数削減はもちろんですが、OS、MWのパラメータシートを構成管理ツールの設定ファイルとして代用することができ、その設定ファイルをバージョン管理することでITインフラもコード**【Infrastructure as a Code】**で管理することができる。

**【デメリット】**
ツールが多様化することで、実作業は軽減されると思われるが、運用ルールが増加するためルールの管理、運用フローの展開、運用文書化と管理内容の複雑になってしまう。

## 参考

- Webサイト

[公式サイト](https://www.ansible.com/)
[ドキュメント](http://docs.ansible.com/ansible/)
[Ansible 入門](https://qiita.com/ArimaRyunosuke/items/1f9d840311584d8160bc)
[Ansibleをはじめる人に。](https://qiita.com/t_nakayama0714/items/fe55ee56d6446f67113c)
[超ansible入門](https://qiita.com/Seisan0044/items/e8e9815a02d611b2e5b0)
[日本Ansibleユーザ会](http://ansible-users.connpass.com/)

- 書籍

[入門Ansible Kindle版](https://www.amazon.co.jp/%E5%85%A5%E9%96%80Ansible-%E8%8B%A5%E5%B1%B1%E5%8F%B2%E9%83%8E-ebook/dp/B00MALTGDY/ref=la_B077XBV4WZ_1_1?s=books&ie=UTF8&qid=1548747559&sr=1-1)
[Ansible実践ガイド第2版 ](https://www.amazon.co.jp/Ansible%E5%AE%9F%E8%B7%B5%E3%82%AC%E3%82%A4%E3%83%89%E7%AC%AC2%E7%89%88-impress-top-gear%E3%82%B7%E3%83%AA%E3%83%BC%E3%82%BA-%E5%8C%97%E5%B1%B1-ebook/dp/B07B2T24V4/ref=pd_sim_351_2?_encoding=UTF8&pd_rd_i=B07B2T24V4&pd_rd_r=038ecf23-2399-11e9-8c1e-89b882a97dba&pd_rd_w=mUYNJ&pd_rd_wg=IqRS2&pf_rd_p=b79503b3-46ea-4244-8b06-2f14c40a97b1&pf_rd_r=HWP582KTP2BY6ZKQYHXA&psc=1&refRID=HWP582KTP2BY6ZKQYHXA)

## 0.検証環境

OS:CentOS 7.5
ミドルウェア:ansible 2.7.5
前提ミドルウェア:EPEL

## 1. Ansibleインストール

### 1.1 Ansibleインストール

```
# yum install -y epel-release     ※1
# yum install -y ansible
# yum -y install python-pip       ※2
# pip install --upgrade pip       ※2
# pip install pywinrm             ※2
# ansible --version               ※3
```

インストールは、以上で完了で。後は運用設定のみで、構築自体はあっけない程簡単です。
Ansibleの設定は、`/etc/ansible/ansible.cfg`でされていますが、このファイルを変更することはあまりなさそうです。(Ansible用hostsファイル、playbookで制御可能なため)

※1:ansibleは標準リポジトリに存在しないためエンタープライズ Linux 用の拡張パッケージ(EPEL)を追加。
※2:構成管理するクライアントがWindowsServerを含む場合は、【pywinrm】を導入する必要がある。
※3:インストール確認のため、バージョンを表示するコマンドを実行しています。

## 2. Ansibleの構成

### 2.1. Ansibleの構成要素

- Ansible用hostsファイル(/etc/ansible/hosts)

  構成対象となるクライアントを記述。

- playbook

  モジュールを複数組み合わせて、実行させる【JOB】です。
  対象サーバの接続条件(対象サーバ、ユーザ、sudo実行有無、変数)を記載します。
  playbookは【YAML形式】で記述します。
  【YAML形式】については、[プログラマーのための YAML 入門 (初級編)](https://magazine.rubyist.net/articles/0009/0009-YAML.html)を参照。

- モジュール

  実際の対象サーバで、パッケージをインストールしたり、ファイルコピーしたり、実行する内容を記述します。
  playbook中の【task】に【YAML形式】で記述します。

### 2.2. Ansible用hostsファイル

Ansible用hostsファイル(/etc/ansible/hosts)は、AnsibleおけるDefaltのInventoryとして使用され、以下のように同一の設定をする[WebServerGroup]等のグループに分けて記述すると、【playbook】で実行する内容が簡素化することが可能となる。

もちろん、各サーバ毎に違う設定がある場合は、サーバ毎に記載する必要もあるので**<u>きちんと運用ルールを設け</u>**設定する必要があります。

Ansibleを実行するサーバは、ローカルなので`ansible_connection=local`と設定する必要があります。ちなみに`dafault`は`ssh`となっている。

ホスト名は、以下の[DBServerGroup]や [APServerGrroup]のように正規表現でも記述することができます。

接続するポートに関しても、ホスト名の後に`:`で繋げ指定することが可能。その他に`ansible_port`で指定することも可能となっている。ちなみに`default`の`ansible_port`はSSH接続が前提となっているため`22`となっている。

また、以下の[GatewayServerGroup]のようにansible用の仮のホスト名を指定し、【ansible_host】で実際のIPを指定することも可能です。



```yaml
  [localhost]
  127.0.0.1 ansible_connection=local
  
  [WebServerGroup]
  192.168.1.100
  192.168.1.101
  192.168.1.102
  
  [DBServerGroup]
  DB-[a:f].example.com:5501
  [APServerGrroup]
  www[01:10].example.com
  [GatewayServerGroup]
  Gateway01 ansible_port=1022 ansible_host=192.168.101.92
  
```



DefaltのInventory(/etc/ansible/hosts)以外のファイルを使用する場合は、ansibleコマンドのオプションとして`-i`(`--inventory`)を指定するか、`ANSIBLE_HOSTS`環境変数でパスを指定する必要がある。DefaltのInventory以外の指定したファイルであれば、YAML形式で記述することも可能です。

詳細は、公式Documents[【Working with Inventory】](http://docs.ansible.com/intro_inventory.html)を参照。

なお、Windowsとの接続する場合は、クライアント側の前提としてWindows Remote Management(WinRM)が起動している必要がある。

```yaml
[windows]
192.168.99.3
ansible_ssh_user=<Windows側のユーザ名>
ansible_ssh_pass=<Windows側ユーザのパスワード>
ansible_ssh_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
```



### 2.3. playbook設定

#### hosts
Ansible用hostsファイルで指定したグループ名を指定する。
allを指定することでAnsible用hostsファイルに記述された全てのサーバ対象で同じ内容を実行します。

#### remote_user
リモート側の実行ユーザを指定する。
Ansibleは、SSH接続なので実行ユーザに鍵認証を設定している必要がある。

#### sudo(become※1)
`sudo`実行する場合は、`yes`を指定する。
`sudo_user`でsudoで実行するユーザを指定する必要がある。
また、`ansible`コマンド実行時に`-s(--sudo)`を指定することも可能。
sudo実行するモジュール(task)毎に指定することが可能です。
※1:Ansible1.9以降は`become`を使用すること。

#### sudo_user(become_user※2)
sudo実行する際の実行ユーザを指定。
※2:Ansible1.9以降は`become_user`を使用すること。

#### become_method
sudo実行ではなく、suを使って権限を変更したい場合は、`become_method`で`su`を指定する。
ちなみに、Defaultの`become_method`は、`sudo`となっている。

[公式ドキュメント（become)](http://docs.ansible.com/become.html)

#### vars

モジュール(task)を実行する際に設定して変数をここで宣言する。
以下のように宣言しておくと `${HOME}`、`${INI_File}`、`${TmpDir}` などで参照することが出来ます。

```yaml
  vars:
    HOME: "/home/hogeuser"
    INI_File: "/etc/local/ansible_local.ini"
    TmpDir:/tmp
```

#### handlers

`task`で状態が変更された場合(changed のイベントが起こった場合)に1回だけ最後に実行されるジョブです。
`task`側では `notify` を設定し、 `handler`側では `listen` でそれを待ち受け、紐づけている。



```yaml
- hosts: localhost

handlers:
  - name: TEST handlers JOB
      msg:execute handler
      listen:Start handler A

tasks:
  - name: TEST JOB
      msg: message
      changed_when: true
      dest: /foo/bar/
      notify: Start handler A
```

#### tasks

playbook のキモとなる項目です。実行するモジュールを列挙していきます。
name 指定すると実行時に出力が為されます。また、name は必須ではないようです。書かなかった場合、モジュール部分の文字列がそのまま出力されるようです。

各taskの詳細モジュールは、[【2.5.モジュール(task)】](#モジュール(task))を参照。

#### when

指定した条件が成り立つときのみタスクを実行する。

以下の場合は、ファイルコピーの結果を`register`に格納しで成功と失敗で処理を分けている。

```yaml
- copy: src=/etc/hosts dest=/etc/hosts.old
  register: result
  ignore_errors: True

- debug: msg='File copy succeeded(succedded)'
  when: result|succeeded

- debug: msg='File copy failed(failed)'
  when: result|failed
```

#### with_items

ループ処理。

以下の場合は、記述した配列を変数に代入して[/tmp/test1]、[/tmp/test2]、[/tmp/test3]というディレクトリを作成する。

```yaml
- name: ディレクトリの作成
  file: path=/tmp/{{ item }} state=directory
  with_items:
    - test1
    - test2
    - test3
```

コマンド実行結果を `with_items` でループするには、コマンド実行した結果を登録(register)し`with_items`の変数に代入する。

```yaml
- name: retrieve the list of home directories
  command: ls /home
  register: home_dirs

- name: add home dirs to the backup spooler
  file: path=/mnt/bkspool/{{ item }} src=/home/{{ item }} state=link
  with_items: home_dirs.stdout_lines
  # same as with_items: home_dirs.stdout.split()
```

#### until

ループ処理。

`until`がloopから抜ける条件(以下の場合は標準出力に”OK"が出力されるまでループ)

`retries`がリトライ回数

`delay`がスリープの秒数

```yaml
- shell: /u
sr/bin/foo
  register: result
  until: result.stdout.find("OK") != -1
  retries: 5
  delay: 10
```

#### include

指定したファイルを部品化して呼び出す。
タスク毎に小分けしたplaybookを作成してincludeするのが各playbookを修正した場合影響度が小さくて済む。

```yaml
- include: include_1.yml
```

#### name

各項目のコメントに使用。playbookの概要などを簡潔に記載しておくと後で見た時に分かり易い。

```yaml
- name: install via yum
  yum: name={{ item }} state=installed
  with_items:
    - bash
    - git
    - ntp
```

#### msg

標準出力にメッセージを出力する。

デバッグする際のポインターとして利用すると便利。

サンプルは、`debug`を参照。

#### debug

デバックする際に付与すると内容確認できる。

以下の例は、`register`に変数が代入されているか確認しています。

ansible-playbookコマンド実行時に`-v`もしくは`-vv`、`-vvv`を付与しても同様にデバック可能。

```yaml

  - name: check file exists
    stat:
      path: /etc/hosts
    register: res_exists
 
  - name: debug var res_exists
    debug:
      msg: "{{ res_exists }}"
```



### 2.4.モジュール(task)

<a name="モジュール(task)"></a>

#### shell

シェル上でコマンドを実行。

```yaml
shell: sample_script.sh arg1 arg1 >> sample_log.log
```

#### command

リモートノードでコマンドを実行する。

`[/path/to/database]`が存在すれば、シェルを実行する。

```yaml
- command: /usr/bin/make_database.sh arg1 arg2 creates=/path/to/database
```

#### file

ファイルやディレクトリの作成、パーミッション設定
ただし、以下は`state`が`link`となっているため、シンボリックリンクとなる。

```yaml
- file:
    src=/usr/local/foo.txt    
    dest=/opt/foo.txt
    owner=root
    group=root
    mode=0755
    state=link
```

#### lineinfile

ファイルの行単位の書き換え。

以下の場合は、先頭`SELINUX=`の行を`SELINUX=enforcing`に書き換える。

```yaml
- lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
```

#### template

テンプレートを利用したファイルのコピー。テンプレートファイルは、`/etc/ansible/templates/`に配置する必要がある。

```yaml
- template:
    src=template.j2 
    dest=/opt/file.conf 
    owner=root 
    group=root 
    mode=0644
```

#### synchronize

「rsync起動ホスト(Ansibleサーバ)」から「操作対象ホスト(Inventoryで指定したホスト)」へのファイルやディレクトリのコピーを行う。

```yaml
- synchronize:
    src=source_dir
    dest=/tmp/target_dir
    recursive=yes
```

#### copy

```yaml
- copy:
    src=foo.txt    
    dest=/tmp/foo.txt
    owner=root
    group=root
    mode=0755
```

#### yum

yumパッケージマネージャによるパッケージのインストール、アップグレード、削除

```yaml
yum: name=httpd state=latest
```

#### その他

その他のモジュールは、[Ansible モジュール一覧](http://docs.ansible.com/ansible/modules_by_category.html)を参照。



### 2.5. Best Practices

Ansible公式サイトで更改しているベストプラクティスは、以下の構成としている。
この辺は、実際の現場の環境や運用ルールに合わせて、作っていくしかないだろう。

/etc/ansible/
  ├inventories/
  │  ├production/
  │  │  ├hosts                             # 本番環境サーバ用のインベントリファイル
  │  │  ├group_vars/
  │  │  │  ├group1.yml              # 特定のグループに変数を割り当て
  │  │  │  └group2.yml
  │  │  └host_vars/
  │  │      ├hostname1.yml       # 特定のシステムに変数を割り当てます
  │  │      └hostname2.yml
  │  │
  │  └staging/
  │      ├hosts                            # 開発環境サーバ用のインベントリファイル
  │      ├group_vars/
  │      │  ├group1.yml             # 特定のグループに変数を割り当て
  │      │  └group2.yml
  │      └host_vars/
  │          ├stagehost1.yml       # 特定のシステムに変数を割り当てます
  │          └stagehost2.yml
  │ 
  ├library/                                  # カスタムモジュールを置きます（オプション）。
  ├module_utils/                      # module_utilsを置きます（オプション）。
  ├filter_plugins/                      # カスタムフィルタプラグインを配置します（オプション）。
  │
  ├site.yml                                # master playbook
  ├webservers.yml                  # playbook for webserver tier
  ├dbservers.yml                     # playbook for dbserver tier
  │
  └roles/
      ├common/                 # この階層は「役割」を表します
      │  ├tasks/
      │  │  └main.yml
      │  ├handlers/
      │  │  └main.yml
      │  ├templates/
      │  │  └ntp.conf.j2
      │  ├files/
      │  │  └source files       # コピーリソースで使用するファイル
      │  │  └script files         # スクリプトリソースで使用するスクリプトファイル
      │  ├vars/
      │  │  └main.yml           # このロールに関連する変数
      │  ├defaults/
      │  │  └main.yml           # このロールのデフォルトの優先順位の低い変数
      │  ├meta/
      │  │  └main.yml           # ロール依存関係
      │  ├library/                   # カスタムモジュールも含めることができます
      │  ├module_utils/       # カスタムmodule_utilsも含めることができます
      │  └lookup_plugins/   # 検索のように、または他の種類のプラグイン
      ├webtier/                     # 「common」と同じ構造
      ├monitoring/
      └fooapp/



## 3. 実行コマンド

### 3.1. ansibleコマンド

Ansibleで何か一時的な処理をおこなう時のコマンド。

- 「(インベントリファイルに書かれた)対象のホスト」 ( コマンド引数 )

- 「インベントリファイル」 ( `-i` )

- 「使うモジュール」 ( `-m` )

- 「モジュールに与える引数」 ( `-a` )

  リモートホストで`echo`コマンドを実行

  `ansible target_host -i inventory_file -m shell -a 'echo "Hello World"'`

  リモートホストでrootユーザで`ping`コマンドを実行
  `ansible target_host -m ping -i inventory_file -u root`

  リモートホストで`httpd`を起動。

  `ansible target_host -m service -a "name=httpd state=started"`

  リモートホストでユーザを追加

  `ansible target_host -m user -a "name=username password=<crypted password here>"`

  


### 3.2.ansible-playbookコマンド

一連の処理の流れを YAML で記述しておいて、それを実行するコマンド。

- 通常実行
  `ansible-playbook -i inventory_file playbook.yml`

- 構文チェック
  `ansible-playbook -i inventory_file playbook.yml --syntax-check`

- 実行されるタスクの一覧を表示
  `ansible-playbook -i inventory_file playbook.yml --list-tasks`

- verboseオプション（-vvv）で詳細情報の表示する。
  `ansible-playbook -i inventory_file -u root -k playbook.yml -vvv`

- 実行時にパラメータを付与する。

  `ansible-playbook --extra-vars "xxx=yes" -i inventory_file playbook.yml`

  `ansible-playbook -e "xxx=yes" -i inventory_file playbook.yml`

- 実行するときのユーザの秘密鍵を指定して実行する
  `ansible-playbook -i inventory_file playbook.yml --private-key=/path/key.pem`

### 3.3.ansible-docコマンド

- モジュール確認
  `ansible-doc -l`


## 実際のところ
**実際のところ、運用してみないとAnsibleどころかサーバー構成自動化ツールの必要性は、確かにサーバが数百台ともなれば、何かしらのツールは必要だとは思います。それこそ仮想マシンの作成やOSインストールし、OS設定、MWインストール、MW設定までを一括して出来ればいいのですが、OSインストールはAnsibleではできないことから、現状私には必要性を強く感じられません。**

