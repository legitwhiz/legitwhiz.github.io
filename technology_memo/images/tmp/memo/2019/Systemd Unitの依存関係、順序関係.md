# Systemd Unitの依存関係、順序関係
現在有効なUnitの依存関係、順序関係は次のコマンド確認できます。

- `# systemctl list-dependencies <Unit名>`
  • 指定Unitが必要とするUnitを表示します。（指定省略時は「default.target」）
  • 依存Unitがtargetタイプの際は、さらに、それが必要なUnitを再帰表示します。
  • --allオプションをつけると、すべてのUnitを再帰表示します。
 – # systemctl list-dependencies <Unit名> --after
   • 指定Unitより先に起動するUnitをツリー表示します。
   • --allオプションは上と同様。 
 – # systemctl list-dependencies <Unit名> --before
  • 指定Unitより後に起動するUnitをツリー表示します。
  • --allオプションは上と同様。

   # systemctl list-dependencies
   default.target
   ├─atd.service
   ├─auditd.service
   ・
   ・
   ・
   ├─basic.target
   │ ├─fedora-autorelabel-mark.service
   ・・・ 
   │ ├─firewalld.service
   │ ├─paths.target
   │ ├─sockets.target
   │ │ ├─avahi-daemon.socket
   │ │ ├─dbus.socket
   ・・・
   │ ├─sysinit.target
   │ │ ├─dev-hugepages.mount
   │ │ ├─dev-mqueue.mount
   │ │ ├─lvm2-monitor.service
   │ │ ├─plymouth-read-write.service
   │ │ ├─plymouth-start.service
   ・・・
   ├─getty.target
   │ └─getty@tty1.service
   └─remote-fs.target
