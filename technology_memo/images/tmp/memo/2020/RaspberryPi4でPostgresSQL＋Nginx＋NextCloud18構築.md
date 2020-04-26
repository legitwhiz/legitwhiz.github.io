# RaspberryPi4でPostgresSQL＋Nginx＋NextCloud18構築

[Raspbian初期設定(RaspberryPi4)](https://qiita.com/legitwhiz/items/bc897259b27f3c0e7aa0) の続きです。

Raspbian:10.3
kernel:4.19.97-v7l+ #1294
postgresql-11 11.7-0
PHP 7.2
Nginx 1.14.2-2
NextCloud



## 1. NAS構築

目的は、自分用のクラウドファイルサーバとして構築してみました。
WebDAVサーバも使えればマウントもできるので便利になるかと思いNextCloudを導入してみました。



### 1.1. Nginxのインストール

まずは、Webサーバをインストール

どうせなら経験のないNginxをチョイス。

```
$ apt -y install nginx
$ systemctl enable nginx
$ systemctl start nginx
```



### 1.2. PHP-7.2-fpmのインストール

Apacheでは、PHPを直接実行することができましたが、Nginxはphp-fpmをインストールする必要があるようなので、PHPおよびphp-fpmをインストールしました。また、NextCloudの前提となっているPHP関連パッケージもインストールしました。

```bash
$ sudo apt -y install apt-transport-https lsb-release ca-certificates
$ sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
$ sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
$ sudo apt update
$ sudo apt upgrade
$ sudo apt -y install php7.2 php7.2-ctype php7.2-curl php7.2-xml php7.2-gd php7.2-iconv php7.2-json php7.2-mbstring php7.2-xmlreader php7.2-zip php7.2-pgsql php7.2-fpm php7.2-bz2 php7.2-intl
```



### 1.3. PostgreSQLのインストール・データベースの作成

DBもMySQLは自宅サーバでも以前使用していましたが、PostgresSQLはなかったので導入してみました。

※業務では、PostgresSQLはありますが。

```
$ apt -y install postgresql postgresql-contrib
$ su - postgres
$ psql
postgres=# CREATE ROLE nextcloud;  // nextcloudというロールを作成
postgres=# \password nextcloud  // ロールのパスワード設定

postgres=# ALTER ROLE nextcloud WITH LOGIN;  // ロールにログイン権限を付与
postgres=# CREATE DATABASE nextclouddb WITH OWNER nextcloud;
// nextclouddbというデータベースを作成し、nextcloudに所有権を与える
postgres=# exit;
```

rootユーザで

```
$ vi /etc/postgresql/11/main/pg_hba.conf
local   all       all        md5 <-peerをmd5に修正 
$ systemctl restart postgresql

```



### 1.4. 無料 DDNS サービスへの登録

自宅でサーバを公開するには外部に公開する IP アドレス（プロバイダから支給）が必要です。
ですが、家庭で接続するプロバイダの場合は、このIPアドレスが時々変更されてしまいます。
そこでドメインを発行し，このドメインとIP アドレスを動的に結びつける（DDNS）ことで、ドメインから自宅のサーバに接続することが可能となります。

無料 DDNS サービスを行っている[ieServer](http://ieserver.net/login.html)を使用することにします。

```
$ mkdir /home/［ユーザ名］/scripts
$ cd /home/［ユーザ名］/scripts
$ wget http://ieserver.net/ddns-update.txt
$ mkdir ddns
$ cd ddns
$ vi ddns-update.pl
```

※http://ieserver.net/ddns-update.txtを貼り付けつて以下を修正する。

```
$ACCOUNT         = "     ";     # アカウント(サブドメイン)名設定
$DOMAIN          = "     ";     # ドメイン名設定
$PASSWORD        = "     ";     # パスワード設定
```


```
$ chmod 700 ddns-update.pl
$ crontab -e
*/10 * * * * /home/［ユーザ名］/scripts/ddns/ddns-update.pl
```

### 1.5. Let’s Encryptの無償のSSL証明書の取得

certbotをインストールするためにリポジトリを追加する。

```
$ vi /etc/apt/sources.list
deb http://ftp.debian.org/debian buster-backports main
$ apt update

```

※updateを実行時にエラーとなってしまいましたが、公開鍵が足りていないため以下コマンドで公開鍵を登録しています。

```
$ apt update
公開鍵を利用できないため、以下の署名は検証できませんでした: NO_PUBKEY XXXXXXXXXXXXXXXX NO_PUBKEY XXXXXXXXXXXXXXXX
$ apt-key adv --keyserver keyserver.ubuntu.com --recv-keys XXXXXXXXXXXXXXXX
```



certbotをインストール

```
$ apt -y install certbot python-certbot-nginx -t buster-backports
```



### 1.6.phpの設定

```
$ vi /etc/php/7.2/fpm/pool.d/www.conf

listen = /run/php/php7.2-fpm.sock
listen.mode = 0666
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
```



```
$ vi /etc/php/7.2/fpm/php-fpm.conf

daemonize = yes
```



### 1.7. Nginxの事前設定

証明書をインストールするために、とりあえずNginxが使用できるようにします。

```
$ vi /etc/nginx/sites-enabled/default

server_name XXX.jp;
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
        #
        #       # With php-fpm (or other unix sockets):
                fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        #       # With php-cgi (or other tcp sockets):
        #       fastcgi_pass 127.0.0.1:9000;
        }
```

設定したconfigをチェックしてから起動します。

```
$ nginx -t  #nginx config check
$ systemctl stop nginx
$ systemctl start nginx
```



### 1.8. 証明書のインストール

証明書のインストールを実施する場合は、事前にWebサーバを停止させること。

```
$ certbot --nginx
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx

Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: XXX.jp
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel): 1
Obtaining a new certificate
Deploying Certificate to VirtualHost /etc/nginx/sites-enabled/default

Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: No redirect - Make no further changes to the webserver configuration.
2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
new sites, or if you're confident your site works on HTTPS. You can undo this
change by editing your web server's configuration.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 1

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations! You have successfully enabled https://XXX.jp

You should test your configuration at:
https://www.ssllabs.com/ssltest/analyze.html?d=XXX.jp
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/XXX.jp/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/XXX.jp/privkey.pem
   Your cert will expire on 2020-07-10. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option. To non-interactively renew *all* of
   your certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

root@raspberrypi:/etc/letsencrypt/renewal#
```

Let's Encrypt 認証局が発行する SSL/TLS サーバ証明書の有効期間は、短期間（90日間）です。
少なくとも、1.5か月に一回は、証明書を更新する必要があります。

なので、1か月に一回証明書を自動で更新するようにcronに組み込みます。

```
$ crontab -e
0 1 1 * * root /usr/bin/certbot renew --force-renew --webroot-path /var/www/html/ --post-hook "systemctl reload nginx"
```



### 1.9 NextCloud用設定

NginxでNextCloudを実行するために設定です。

```
$ cp -p /etc/nginx/sites-enabled/default ~/default
$ vi /etc/nginx/sites-enabled/default
upstream php-handler {
    #server 127.0.0.1:9000;
    server unix:/var/run/php/php7.2-fpm.sock;
}

server {
    listen 80;
    listen [::]:80;
    server_name <domain name>;
    # enforce https
    return 301 https://$server_name:443$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name <domain name>;

    # Use Mozilla's guidelines for SSL/TLS settings
    # https://mozilla.github.io/server-side-tls/ssl-config-generator/
    # NOTE: some settings below might be redundant
    ssl_certificate /etc/letsencrypt/live/<domain name>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain name>/privkey.pem;
    #ssl_certificate /etc/ssl/nginx/cloud.example.com.crt;
    #ssl_certificate_key /etc/ssl/nginx/cloud.example.com.key;

    # Add headers to serve security related headers
    # Before enabling Strict-Transport-Security headers please read into this
    # topic first.
    #add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";
    #
    # WARNING: Only add the preload option once you read about
    # the consequences in https://hstspreload.org/. This option
    # will add the domain to a hardcoded list that is shipped
    # in all major browsers and getting removed from this list
    # could take several months.
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header X-Download-Options noopen;
    add_header X-Permitted-Cross-Domain-Policies none;
    add_header Referrer-Policy no-referrer;

    # Remove X-Powered-By, which is an information leak
    fastcgi_hide_header X-Powered-By;

    # Path to the root of your installation
    root /var/www/html/nextcloud;

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # The following 2 rules are only needed for the user_webfinger app.
    # Uncomment it if you're planning to use this app.
    #rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
    #rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;

    # The following rule is only needed for the Social app.
    # Uncomment it if you're planning to use this app.
    #rewrite ^/.well-known/webfinger /public.php?service=webfinger last;

    location = /.well-known/carddav {
      return 301 $scheme://$host:$server_port/remote.php/dav;
    }
    location = /.well-known/caldav {
      return 301 $scheme://$host:$server_port/remote.php/dav;
    }

    # set max upload size
    client_max_body_size 512M;
    fastcgi_buffers 64 4K;

    # Enable gzip but do not remove ETag headers
    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
    gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

    # Uncomment if your server is build with the ngx_pagespeed module
    # This module is currently not supported.
    #pagespeed off;

    location / {
        rewrite ^ /index.php;
    }

    location ~ ^\/(?:build|tests|config|lib|3rdparty|templates|data)\/ {
        deny all;
    }
    location ~ ^\/(?:\.|autotest|occ|issue|indie|db_|console) {
        deny all;
    }

    location ~ ^\/(?:index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+)\.php(?:$|\/) {
        fastcgi_split_path_info ^(.+?\.php)(\/.*|)$;
        set $path_info $fastcgi_path_info;
        try_files $fastcgi_script_name =404;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $path_info;
        fastcgi_param HTTPS on;
        # Avoid sending the security headers twice
        fastcgi_param modHeadersAvailable true;
        # Enable pretty urls
        fastcgi_param front_controller_active true;
        fastcgi_pass php-handler;
        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
    }

    location ~ ^\/(?:updater|oc[ms]-provider)(?:$|\/) {
        try_files $uri/ =404;
        index index.php;
    }

    # Adding the cache control header for js, css and map files
    # Make sure it is BELOW the PHP block
    location ~ \.(?:css|js|woff2?|svg|gif|map)$ {
        try_files $uri /index.php$request_uri;
        add_header Cache-Control "public, max-age=15778463";
        # Add headers to serve security related headers (It is intended to
        # have those duplicated to the ones above)
        # Before enabling Strict-Transport-Security headers please read into
        # this topic first.
        #add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";
        #
        # WARNING: Only add the preload option once you read about
        # the consequences in https://hstspreload.org/. This option
        # will add the domain to a hardcoded list that is shipped
        # in all major browsers and getting removed from this list
        # could take several months.
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        add_header Referrer-Policy no-referrer;

        # Optional: Don't log access to assets
        access_log off;
    }

    location ~ \.(?:png|html|ttf|ico|jpg|jpeg|bcmap)$ {
        try_files $uri /index.php$request_uri;
        # Optional: Don't log access to other assets
        access_log off;
    }
}
```





### 1.10 NextCloud18のインストール

この時点の最新であるNextCloud18を導入します。

```
$ cd /var/www/html
$ curl https://download.nextcloud.com/server/releases/nextcloud-18.0.3.tar.bz2 | sudo tar -jxv
$ chown -R www-data:www-data /var/www/html
```



### 1.11. NextCloudセットアップ

最後にhttps://<domain name>/nextcloud にアクセスし，セットアップする。

| 項目名            |          入力する値          |
| :---------------- | :--------------------------: |
| Username          |       自分で決めて入力       |
| Password          |       自分で決めて入力       |
| Data folder       | /var/www/html/nextcloud/data |
| Database user     |              ※1              |
| Database password |              ※1              |
| Database name     |              ※1              |
| localhost         |      localhost:5432 ※2       |

※1「2.3. PostgreSQLのインストール・データベースの作成」で設定したDBロール、パスワード、DB名を設定すること。
※2 DB接続先IP：ポート番号を設定します。
Finish Setupを押下し,設定完了までしばらく待てば終了です。
後は、自分の好みのプラグインを導入してみたり、自分以外のユーザが使えるようにユーザを作成するなりしてみてください。
Webでアクセスしお好きなファイルをアップロードしてください。
もちろん、WebDAVでマウントしてファイルをアップロードすることも可能です。


### 1.12. USBディスクのマウント

NextCloudのデータディレクトリをUSBディスクのマウントポイントとしましたが、fstabの設定がまずく書き込み権限でエラーとなったためfstabを修正しました。

```
$ vi /etc/fstab
UUID="C00EE4C60EE4B716"    /data    ntfs-3g      async,auto,dev,exec,gid=33,rw,uid=33,umask=007    0    0
```
