# OpenLDAPをGUIで管理(phpLDAPAdmin)

phpLDAPadminを利用すると、WebアプリケーションのGUIを利用して
LDAPにオブジェクト（グループやユーザ）を管理(追加、削除)できます。


phpldapadminの前提パッケージは、以下となります。
apache2.4,php5.4.16-46

### 前提パッケージが導入されているか確認

```
$ rpm -qa | grep -e httpd -e php
php-common-5.4.16-45.el7.x86_64
php-5.4.16-45.el7.x86_64
php-cli-5.4.16-45.el7.x86_64
httpd-2.4.6-80.el7.centos.1.x86_64
httpd-tools-2.4.6-80.el7.centos.1.x86_64
$
```

### phpLDAPadminのインストール

```
yum install phpldapadmin
```

### phpLDAPadminの設定

```
# cp -p /etc/phpldapadmin/config.php /etc/phpldapadmin/config.php.org
# vi /etc/phpldapadmin/config.php
$servers->setValue('login','attr','dn');  ←コメントをはずす
// $servers->setValue('login','attr','uid');  ←コメント
※以下追加
$servers->setValue('server','name','<LDAP hostname>');
$servers->setValue('server','host','<LDAP Server IP>');
$servers->setValue('server','base',array('<Base DN>'));
$servers->setValue('login','bind_id','<Bind DN>');
$servers->setValue('server','port','<LDAP Port No>');

```


### phpの設定

```
vi /etc/php.ini
memory_limit = 16M
↓
memory_limit = 128M
```

### Apacheの設定

```
# vi /etc/httpd/conf.d/phpldapadmin.conf
Alias /ldapadmin /usr/share/phpldapadmin/htdocs
 
<Directory /usr/share/phpldapadmin/htdocs>
  AllowOverride All
  <IfModule mod_authz_core.c>
    # Apache 2.4
    Require all granted 
  </IfModule>
  <IfModule !mod_authz_core.c>
    # Apache 2.2
    Order Deny,Allow
    Deny from all
    Allow from 127.0.0.1
    Allow from ::1
  </IfModule>
</Directory>
```

### Apacheの再起動

```
systemctl restart httpd
```


### 後はブラウザでアクセスするだけで構築は完了です。

https://<phpldapadminを導入したサーバのIPアドレス>/phpldapadmin/


