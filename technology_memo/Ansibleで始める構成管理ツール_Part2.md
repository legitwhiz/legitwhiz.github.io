# Ansibleで始める構成管理ツール_Part2


Ansibleで公開しているBest Pricticeの構成を前回、記載しましたが具体的にどのファイルに何を記述していくべきなのか深堀して調査、検証してみました。

## 1.1. Ansibleディレクトリ構成


```
/etc/ansible/
  ├inventories/
  │  ├production/
  │  │  ├hosts                    # 本番環境サーバ用のインベントリファイル
  │  │  ├group_vars/
  │  │  │  ├all.yml
  │  │  │  ├webservers.yml        # 特定のグループに変数を割り当て
  │  │  │  ├dbservers.yml 
  │  │  │  └apservers.yml
  │  │  └host_vars/
  │  │      ├webservers.yml       # 特定のシステムに変数を割り当てます
  │  │      ├dbservers.yml
  │  │      └apservers.yml
  │  ├local/
  │  │  ├hosts                    # ansibleサーバ用のインベントリファイル
  │  │  ├group_vars/
  │  │  │ └local.yml 
  │  │  └host_vars/
  │  │      └local.yml 
  │  └staging/
  │      ├hosts                   # 開発環境サーバ用のインベントリファイル
  │      ├group_vars/
  │      │  ├all.yml
  │      │  ├webservers.yml       # グループに変数を割り当て
  │      │  ├dbservers.yml 
  │      │  └apservers.yml
  │      └host_vars/
  │          ├webservers.yml      # システムに変数を割り当てます
  │          ├dbservers.yml 
  │          └apservers.yml
  ├library/                       # カスタムモジュールを置きます。
  ├module_utils/                  # module_utilsを置きます。
  ├filter_plugins/                # カスタムフィルタプラグインを配置します。
  │
  ├site.yml                       # master playbook
  ├webservers.yml                 # playbook for webserver tier
  ├dbservers.yml                  # playbook for dbserver tier
  ├apservers.yml                  # playbook for apserver tier
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
      │  │  └source files     # コピーリソースで使用するファイル
      │  │  └script files     # スクリプトリソースで使用するスクリプトファイル
      │  ├vars/
      │  │  └main.yml         # このロールに関連する変数
      │  ├defaults/
      │  │  └main.yml         # このロールのデフォルトの優先順位の低い変数
      │  ├meta/
      │  │  └main.yml         # ロール依存関係
      │  ├library/            # カスタムモジュールも含めることができます
      │  ├module_utils/       # カスタムmodule_utilsも含めることができます
      │  └lookup_plugins/     # 検索のように、または他の種類のプラグイン
      ├webtier/               # 「common」と同じ構造
      ├dbtier/                # 「common」と同じ構造
      ├aptier/                # 「common」と同じ構造
      └monitoring/            # 「common」と同じ構造
```

まずは、ディレクトリを作成します。
以下のURLのようにディレクトリ構成をplaybookで作成する方法もありますので参考にして下さい。
[『Ansibleのベストプラクティスなディレクトリ構成の雛形を一撃で作りたい』](https://qiita.com/n-funaki/items/0156fd038df1787cae77)

```
Ansible_Dir=/etc/ansible
mkdir -m 755 $Ansible/inventories
mkdir -m 755 $Ansible/inventories/production/
mkdir -m 755 $Ansible/inventories/production/group_vars/
mkdir -m 755 $Ansible/inventories/production/host_vars/
mkdir -m 755 $Ansible/inventories/staging/
mkdir -m 755 $Ansible/inventories/staging/group_vars/
mkdir -m 755 $Ansible/inventories/staging/host_vars/
mkdir -m 755 $Ansible/library
mkdir -m 755 $Ansible/module_utils
mkdir -m 755 $Ansible/filter_plugins
mkdir -m 755 $Ansible/roles
mkdir -m 755 $Ansible/roles/common
mkdir -m 755 $Ansible/roles/common/tasks
mkdir -m 755 $Ansible/roles/common/handlers
mkdir -m 755 $Ansible/roles/common/templates
mkdir -m 755 $Ansible/roles/common/files
mkdir -m 755 $Ansible/roles/common/vars
mkdir -m 755 $Ansible/roles/common/defaults
mkdir -m 755 $Ansible/roles/common/meta
mkdir -m 755 $Ansible/roles/common/library
mkdir -m 755 $Ansible/roles/common/module_utils
mkdir -m 755 $Ansible/roles/common/lookup_plugins
mkdir -m 755 $Ansible/roles/common/
mkdir -m 755 $Ansible/roles/webtier/tasks
mkdir -m 755 $Ansible/roles/webtier/handlers
mkdir -m 755 $Ansible/roles/webtier/templates
mkdir -m 755 $Ansible/roles/webtier/files
mkdir -m 755 $Ansible/roles/webtier/vars
mkdir -m 755 $Ansible/roles/webtier/defaults
mkdir -m 755 $Ansible/roles/webtier/meta
mkdir -m 755 $Ansible/roles/webtier/library
mkdir -m 755 $Ansible/roles/webtier/module_utils
mkdir -m 755 $Ansible/roles/webtier/lookup_plugins
mkdir -m 755 $Ansible/roles/dbtier/
mkdir -m 755 $Ansible/roles/dbtier/tasks
mkdir -m 755 $Ansible/roles/dbtier/handlers
mkdir -m 755 $Ansible/roles/dbtier/templates
mkdir -m 755 $Ansible/roles/dbtier/files
mkdir -m 755 $Ansible/roles/dbtier/vars
mkdir -m 755 $Ansible/roles/dbtier/defaults
mkdir -m 755 $Ansible/roles/dbtier/meta
mkdir -m 755 $Ansible/roles/dbtier/library
mkdir -m 755 $Ansible/roles/dbtier/module_utils
mkdir -m 755 $Ansible/roles/dbtier/lookup_plugins
mkdir -m 755 $Ansible/roles/apwtier/
mkdir -m 755 $Ansible/roles/aptier/tasks
mkdir -m 755 $Ansible/roles/aptier/handlers
mkdir -m 755 $Ansible/roles/aptier/templates
mkdir -m 755 $Ansible/roles/aptier/files
mkdir -m 755 $Ansible/roles/aptier/vars
mkdir -m 755 $Ansible/roles/aptier/defaults
mkdir -m 755 $Ansible/roles/aptier/meta
mkdir -m 755 $Ansible/roles/aptier/library
mkdir -m 755 $Ansible/roles/aptier/module_utils
mkdir -m 755 $Ansible/roles/aptier/lookup_plugins
```

## 1.2. 最初にInventoryを設定する。

本番環境用のInventoryとステージング環境とでInventoryを分けて記載するのは、`ansible-playbook`コマンドにて`-i`でInventory file指定して実行するため、playbookを実行する対象を環境毎に分けることが可能です。

また、各Inventoryは、サーバの役割毎にグループを分けて記載することで、各役割毎のplaybookを実行するように構成しています。

【$Ansible/inventories/production/hosts】

```yaml
[webservers]
192.168.100.101
192.168.100.102
192.168.100.103
192.168.100.104
[dbservers]
192.168.101.101
192.168.101.102
[apservers]
192.168.102.101
192.168.102.102
```

【$Ansible/inventories/staging/hosts】

```yaml
[webservers]
192.168.200.101
192.168.200.102
192.168.200.103
192.168.200.104
[dbservers]
192.168.201.101
192.168.201.102
[apservers]
192.168.202.101
192.168.202.102
```

## 1.3. マスターplaybook 

`ansible-playbook`コマンドで実行する時に指定する、playbookとなります。

なるべく、シンプルにするためサーバ役割毎のYAMLファイルをインクルードしているだけとしています。

$Ansible/site.yml 

```yaml
---
- include: webservers.yml
- include: dbservers.yml
- include: apservers.yml
```

## 1.4. サーバの役割毎のplaybook

サーバ役割毎にplaybookを作成し、このファイルで実行するサーバのグループを指定し実行するroleを指定します。
rolesで指定しているcommonは、共通の設定であるcommonとwebサーバ固有のwebtierを指定してます。
Ansibleのroleは、roleディレクトリの指定ディレクトリ配下(commonの場合[$Ansible/roles/common])配下に配置されたmain.ymlをインクルードします)

$Ansible/webservers.yml 

```yaml
---
- hosts: webservers
  roles:
    - common
    - webtier
```

$Ansible/dbservers.yml 

```yaml
---
- hosts: dbservers
  roles:
    - common
    - dbtier
```

$Ansible/apservers.yml

```yaml
---
- hosts: apservers
  roles:
    - common
    - aptier
```

## 1.5. role配下の各役割

#### tasks
roleで実行されるtaskを定義する。 roleからmain.ymlが自動で読み込まれますので、他のファイルに分けたい時はmain.ymlからincludeすること。

$Ansible/common/tasks/main.yml

```yaml
---
- name: install yum packages
  yum: name={{ item }} state=latest
  notify: Start handler common
  with_items:
   - "{{ common_packages }}"
 
 - name: users exist
   user: name={{item.name}} state=present password={{item.password}} groups={{item.groups}}
  with_items: 
   - "{{ common_users }}"

- name: ~/.ssh for users exsit
  file: path="/home/{{item.name}}/.ssh" state=directory owner={{item.name}} group={{item.name}} mode=0700
  with_items:
   - "{{ common_users }}"

- name: authorized keys is deployed
  copy: src="authorized_keys_for_{{item.name}}" dest="/home/{{item.name}}/.ssh/authorized_keys" owner={{item.name}} group={{item.name}} mode=0600
  with_items:
   - "{{ common_users }}"

- name: sudo configured
  copy: src="sudoers" dest="/etc/sudoers" owner=root group=root mode=0440

- name: Start the ntp service
  service: name=ntpd state=started enabled=yes
  tags: ntp

- template: src=templates/ntp.conf.j2 dest=/etc/ntp.conf owner=root group=root mode=0644
  notify: restart ntp
```

$Ansible/webtier/tasks/main.yml

```yaml
---
- name: install yum packages
  yum: name={{ item }} state=latest
  notify: Start handler webtier
  with_items:
   - "{{ webtier_packages }}"
- name: httpd.conf configured
  copy: src="httpd.conf" dest="/etc/httpd/conf/httpd.conf" owner=root group=root mode=0644
```

$Ansible/dbtier/tasks/main.yml

```yaml
---
- name: install yum packages
  yum: name={{ item }} state=latest
  notify: Start handler dbtier
  with_items:
 - "{{ dbtier_packages }}"
```

$Ansible/aptier/tasks/main.yml

```yaml
---
- name: install yum packages
  yum: name={{ item }} state=latest
  notify: Start handler aptier
  with_items:
 - "{{ aptier_packages }}"
- name: tomcat configured
  copy: src="tomcat" dest="/etc/sysconfig/tomcat" owner=root group=root mode=0644
```

#### defaults
roleで利用される変数のデフォルト値をmain.ymlに定義する。

varsで、group_varsなどで変数を上書きできます。

#### vars
main.ymlにroleで利用される変数を定義します。 基本的に環境毎に変わる固定値などを記述します。group_varsなどで変数を上書きできないので注意が必要です。

$Ansible/roles/common/vars/main.yml

```yaml
---
common_packages:
  - ntpd
  - ntpdate
  - ncompress
common_users:
  - { name: opeuser,  password: "*****", groups: "opegroup" }
```

※パスワードは、opensslコマンドでハッシュ化したパスワードを入力して下さい。
ハッシュ化は、`openssl passwd -l <平文のパスワード>`

$Ansible/roles/webtier/vars/main.yml


```yaml
---
webtier_packages:
  - httpd
  - httpd-tools
  - apr
  - apr-util
```

$Ansible/roles/dbtier/vars/main.yml

```yaml
---
dbtier_packages:
  - postgresql-server
  - postgresql-contrib
```

$Ansible/roles/aptier/vars/main.yml

```yaml
---
aptier_packages:
  - tomcat
  - tomcat-el
  - tomcat-jsp
  - tomcat-lib
  - tomcat-servlet
```

#### files
copyモジュールでセットアップされるファイルを配置します。 ASCII、バイナリのどちらでもOK。

上記のtaskを設定した場合は以下のファイルを用意する必要があります。

```
httpd.conf
tomcat
authorized_keys_for_***
```

#### templates
templateモジュールでセットアップされるJinja2形式のテキストファイルを配置する。
 Jinja2形式のテキストファイルは、変数を埋め込むことができる点がfilesの下のファイルとの違いです。変数は、【default】【group_vars】【vars】のどこかに設定する必要があります。

$Ansible/roles/common/templates/ntp.conf.j2

```
driftfile /var/lib/ntp/drift

restrict 127.0.0.1 
restrict -6 ::1

server {{ ntpserver }}

includefile /etc/ntp/crypto/pw

keys /etc/ntp/keys
```

#### meta
metaを設定する事でRoleの依存関係を設定出来ます。

複数roleをtaskで実行する際に、依存関係で先に実行すべきroleを記載する。

$Ansible/roles/common/meta/main.yml

```yaml
---
dependencies:
  - { role: common }
```

$Ansible/roles/webtier/meta/main.yml

```yaml
---
dependencies:
  - { role: common }
```

#### handlers
handlersには、主にサービスの再起動といった特定の条件で発火するイベントtaskを定義します。 別のRoleにて、Apacheの設定ファイルを変更した後、Apacheを再起動したいといったケースで利用します。 この場合、別のRoleからhandlerの「restart apache2 service」をnotifyすれば、期待する挙動となるのです。

$Ansible/roles/common/handlers/main.yml

```yaml
---
- name: restart ntp
  service: name=ntpd state=restarted
  listen:restart ntp
```

$Ansible/roles/webtier/handlers/main.yml

```yaml
---
- name: restart httpd
  service: name=httpd state=restarted
  listen:Start handler webtier
```

$Ansible/roles/dbtier/handlers/main.yml

```yaml
---
- name: restart postgrad
  service: name=postgrad state=restarted
  listen:Start handler dbtier
```

$Ansible/roles/aptier/handlers/main.yml

```yaml
---
- name: restart tomcat
  service: name=tomcat state=restarted
  listen:Start handler aptier
```


#### group_vars

共通にセットする変数を格納。
$Ansible/group_vars/all.yml

```yaml
---
ntpserver: 192.168.1.2
```



### 最後に

理想的にはGitで構築用のリポジトリにpushしたら、jenkinsでAnsibleサーバにビルドして、jenkinsからainsibleのplaybookを実行し、各サーバの設定を実施していくイメージだろう。

ここまで、できれば単体試験まで自動化したいですが、それは後日・・・。

