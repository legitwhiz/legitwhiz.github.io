---
layout: default
title: SSHでパスワードを応答しなくてもログインする方法
---

# SSHでパスワードを応答しなくてもログインする方法

SSH接続で鍵認証を使わず、パスワード認証を使っている現場は、まだまだ多いですね。

通常の運用でSSH接続する際、パスワード認証で手動でパスワードを入力するのは、コンソール、ターミナルでも他人には見えない("*"や"●"や"無表記")ため、セキュリティ的にあまり問題ないと考えてます。

(キーボードで打つところを後ろからみたり、キーロガーで盗まれる可能性はありますが...。)

問題なのは、ツールやスクリプト等でSSH接続(SCPを含む)する場合、パスワードを平文で記載することですよね。



まずは、鍵認証を使わずパスワード認証を使用しパスワードを自動応答するスクリプトのパターンがどんなものがあるか調査してみました。



まあ、最初に自動応答で思い浮かぶのが`expect`ですかね。





1. expect

```
#!/usr/bin/expect

log_file /var/log/expect.log

set RemoteHost [lindex $argv 0]
set PW [lindex $argv 1]
set Prompt "\[#$%>\]"

set timeout 5

spawn env LANG=C /usr/bin/ssh ${RemoteHost}
expect {
    "(yes/no)?" {
        send "yes\n"
        exp_continue
    }
    -re "password:" {
        send -- "${PW}\n"
    }
}

expect {
    -glob "${Prompt}" {
        log_user 0
        send "date\n"
    }
}

expect {
    -regexp "\n.*\r" {
        log_user 1
        send "exit\n"
        exit 0
    }
}
```



2. sshaskpass





3. sshpass

sshpass コマンドを使いSSHパスワード認証でログインします。コマンド内に直接パスワードを記載。

```bash
sudo yum -y install sshpass
```




```bash
sshpass -p "PASSWORD" ssh -o "StrictHostKeyChecking no" user@server
```





```bash
nopass hoge@192.168.1.1 bash -s < script.sh
```



4.pexpect



```python
def ssh_connect(user, hostname, password, command):
    FIRST_MESSAGE = "Are you sure you want to continue connecting"
    #パスワードが'-'の場合は鍵認証とします。
    if password == '-':
        ssh = pexpect.run('ssh %s@%s %s' % (user, hostname, command))
        #改行コードの削除
        res = ssh.strip()
        #byte形式なのでstr型に変換
        res = res.decode('utf-8')
    else:  #それ以外はパスワード認証です
        ssh = pexpect.spawn('ssh %s@%s %s' % (user, hostname, command))
        #初回アクセス時の対応です
        ret = ssh.expect([FIRST_MESSAGE, 'assword:*', pexpect.EOF, pexpect.TIMEOUT])
        if ret == 0:
            ssh.sendline("yes")
            ssh.expect('assword:*')
            ssh.sendline(password)
        if ret == 1:
            ssh.sendline(password)
        ssh.expect(pexpect.EOF)
        res = ssh.before
        res = res.strip()
        res = res.decode('utf-8')
    return res
```



list.txt

```
user host pass
例：

tarou 172.16.1.1 password
```









254972
76880

178092/1024
174MB



cat /proc/sys/kernel/core_pattern
grep -e DumpCore -e DefaultLimitCORE /etc/systemd/system.conf
