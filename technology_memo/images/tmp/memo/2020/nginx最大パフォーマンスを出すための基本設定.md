## nginx最大パフォーマンスを出すための基本設定

- Nginxチューニング
- nginx最大限にスピードを出すために、設定パラメーターをチュニングしました。
- nginx設定例

```
user www-data;
pid /var/run/nginx.pid;
worker_processes auto;
worker_rlimit_nofile 100000;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
events {
    worker_connections 2048;
    multi_accept on;
    use epoll;
}
http {
    server_tokens off;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    access_log off;
    error_log /var/log/nginx/error.log crit;
    keepalive_timeout 10;
    client_header_timeout 10;
    client_body_timeout 10;
    reset_timedout_connection on;
    send_timeout 10;
    limit_conn_zone $binary_remote_addr zone=addr:5m;
    limit_conn addr 100;
    include /etc/nginx/mime.types;
    default_type text/html;
    charset UTF-8;
    gzip on;
    gzip_http_version 1.0;
    gzip_disable "msie6";
    gzip_proxied any;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript application/json;
    open_file_cache max=100000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

## 解説

- `worker_processes auto;` - Nginx本体のプロセス数、autoにしてnginx内部判定に任せるのは賢明
- `worker_rlimit_nofile 100000;` - workerプロセスが最大に開けるファイル数の制限。このように設定したら、ulimit -a以上のファイル数を処理できるようになり、too many open files問題を回避できる
- `worker_connections 2048;` - 一つのworkerプロセグが開ける最大コネクション数
- `multi_accept on;` - できるだけクライアントからのリクエストを受け取る
- `use epoll;` - Linuxカーネル2.6以上の場合はepoll、BSDの場合kqueue
- `server_tokens off;` - セキュリティ対策です、エラー画面のnginxバージョン番号を非表示
- `sendfile on;` - ハードディスクio処理とsocket-io処理のバランスを取るため、onにしてください。
- `tcp_nopush on;` - 一つのデータパッケージに全てのヘッダー情報を含まれる
- `tcp_nodelay on;` - データをキャウッシュしないで、どんどん送信させる、リアルタイムアプリに最適
- `keepalive_timeout 10;` - keep-aliveタイムアウト時間、少し短くしとく
- `client_header_timeout 10;` - クライアントタイムアウト時間、少し短くしとく
- `client_body_timeout 10;` - クライアントタイムアウト時間、少し短くしとく
- `reset_timedout_connection on;` - 非アクティブクライアントのコネクションをクロースする
- `send_timeout 10;`- クライアントへの送信タイムアウト
- `limit_conn_zone $binary_remote_addr zone=addr:5m;` - 各種keyの共有メモリ設定
- `limit_conn addr 100;` - keyの最大コネクション数、例：addrは100に設定する（一つのIPアドレスは100コネクションんをリクエストできる）
- `gzip on;` - 転送内容をgzipで圧縮、推薦
- `gzip_http_version 1.0;` - 圧縮httpバージョン
- `gzip_disable "msie6";` - ie6圧縮禁止
- `gzip_proxied any;` - 全てのプロキシも圧縮
- `gzip_min_length 1024;` - gzip 圧縮を行うデータの最小サイズです。これより小さいデータは圧縮されません。
- `gzip_comp_level 6;` - 圧縮レベル設定、1-9
- `gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript application/json;` - 圧縮ファイルタイプ
- `open_file_cache max=100000 inactive=20s;` - キャッシュをオープンする同時に最大数とキャッシュ時間も指定する、20秒以上の非アクティブファイルをクリアする
- `open_file_cache_valid 30s;` - open_file_cacheの検知間隔時間をチェックする
- `open_file_cache_min_uses 2;` - open_file_cacheの非アクティブファイルの最小ファイル数
- `open_file_cache_errors on;` - ファイルのエラー情報もキャッシュする

設定したら、nginxサービスを再起動して有効させる。

## worker_processes、worker_rlimit_nofile、worker_connectionsディレクティブについて



- 同時クライアント数はworker_process * worker_connectionとなる

- worker_processesディレクティブではnginxのワーカープロセス数を指定する。CPUのコア数を設定するのが推奨。autoとしておけばコア数を見て自動設定するようなのでこの設定をしておくのが良さそう

- worker_rlimit_nofileディレクティブを設定すればnginxのワーカープロセスのディスクプリンタを設定する事ができる。nginxで「Too many open files」などと表示された場合やworker_connectionsの値を上げる場合にこの設定を行う。

- worker_connectionsディレクティブではワーカープロセスで許容するコネクション数を指定する。この値はディスクプリンタ以上の設定ができないので、設定を上げる場合にはworker_rlimit_nofileを設定したほうが良い

- nginxでworker_processesをautoにすると、CPU数と同数のworker_processesが生成される。

  