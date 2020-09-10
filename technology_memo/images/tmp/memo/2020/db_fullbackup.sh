###################################################################
# シェル名		db_fullbackup.sh
# 機能名称		ログ収集/削除
# 実行ユーザ	postgres
# 実行サーバ	本番系　：BDMDB001, BDMDB002
# 実行形式		/houshiki/unyou/shell/db_fullbackup.sh
# 格納場所		/houshiki/unyou/shell/
# オーナー		postgres
# 関連シェル	none
# 
# 処理概要：
#	週次でフルバックアップを取得し、前回取得分のバックアップを削除する
# 
# 注釈：
#  フル/差分のバックアップで、処理内容が同一の為
#  イニシャライズ処理にて、変数[bk_mode]に指定した値で変更してる
#
# 更新履歴：
# 	2020/02/19	新規作成	m.wada
# 	2020/07/03	アーカイブログ削除、マウント先バックアップファイル削除処理追加	h.koga
# 	2020/09/07	業務連携フラグ処理の追加・フルバックアップ保持日数を6日に変更	h.koga
#
#################################################################

#####################イニシャライズ####################
#概要：
#  1：各種パラメーター値を変数にセット
#  2：shellの実行ログの格納先を変数に定義
#  3：変数セット
#  4：メッセージを変数にセット
#######################################################

  #環境変数定義
  PGDATA="/data/pgdata/data"                   #データベースクラスタのパス
  BACKUP_PATH="/backup/dbbackup"               #バックアップカタログのパス
  ARCLOG_PATH="/data/pgdata/pgarch/archives"    #WAL アーカイブ先のパス
  PATH=$PATH:/usr/pgsql-11/bin
  export PGDATA
  export BACKUP_PATH 
  export ARCLOG_PATH
  export PATH


  ###########バックアップパラメーター#################
  ### １）バックアップモード指定
  ### 概要：
  ###  この変数で指定する値で
  ###  バックアップ時のフル/差分を指定する
  ### 変数名：bk_mode
  ### 値    ：full/incremental
  ###         full        :フルバックアップ
  ###         incremental :差分バックアップ
  ###
  ### 2)保持サイクル
  ### 概要：
  ###  この変数で指定する値で
  ###  保持する期間を指定
  ### 変数名：cycle_d
  ### 値    ：整数値
  ###
  ### 3)保持世代
  ### 概要：
  ###  この変数で指定する値で
  ###  保持する世代を指定する
  ### 変数名：keep_gen
  ### 値    ：整数値
  ###
  ### 4)アーカイブログ保持日数                 # 2020/07/02 追加
  ### 概要：
  ###  この変数で指定する値（日数）より前の
  ###  アーカイブログは削除
  ### 変数名:keep_arc
  ### 値    : 整数値
  ###
  ### 5)バックアップディレクトリ保持日数           # 2020/07/02 追加
  ### 概要：
  ###  この変数で指定する値（日数）より前の
  ###  nfsマウント先のバックアップディレクトリ/ファイルは削除
  ### 変数名:keep_bkdir
  ### 値    : 整数値
  ###
  ####################################################
  
  #バックアップモード
  bk_mode=full
  
  #保持サイクル(日)                     # 2020/09/07 週1世代にするため、7→6日間保持に変更
  cycle_d=6
  
  #保持世代
  keep_gen=1

  #アーカイブログ保持日数               # 2020/07/02 追加
  keep_arc=8
  
  #nfsマウント先バックアップディレクトリ保持日数         # 2020/07/02 追加
  keep_bkdir=8

  #データベースクラスタディレクトリ
  pg_dat="/data/pgdata/data"
  
  #WALログディレクトリ
  pg_wal="/data/pgdata/pgxlog"

  #アーカイブログディレクトリ
  pg_arc="/backup/pgdata/pgarch"

  
  ############　NFS関連パラメーター　################
  #  NFS関連のパラメーターを変数にセット
  ###################################################
  
  #NFSサーバーホスト名
  nfs_host="bdmbk001"

  #NFSディレクトリ
  nfs_dir="/backup/`hostname`/"

  #バックアップディレクトリ
  bkdir="/dbbackup"

  #マウントポイント
  mount_p="/backup"
  
  ################  その他  #########################
  #  業務連携フラグパス、ログファイルのパス、各種メッセージなどを
  #  変数にセット
  ###################################################
  
  #方式から業務への連携フラグファイル
  BKend_Flag="/backup/dbflag/dbbackupComplete"
  
  #実行ログの格納先とファイル名
  SHELL_LOG="/houshiki/unyou/log/db_fullbackup.log"
  
  #ログメッセージ用のシェル名
  SHELLNAME="`basename $0`:"
  
  #メッセージ
  shellStart_msg="info:${SHELLNAME} Shell start."                                                    #シェルスタート      ※ 2020/09/07 追加
  inf_msg_flbkST="info:${SHELLNAME} PostgresSQL full backup is started."                             #フルバックアップ開始
  inf_msg_exisFB="info:${SHELLNAME} Previously acquired full backup did not exist."                  #前回バックアップがない
  inf_msg_exisDF="info:${SHELLNAME} The differential backup obtained last week did not exist."       #前週バックアップがない
  err_msg_flbkFA="error:${SHELLNAME} Full backup failed.:"                                            #バックアップ失敗
  err_msg_dlfbFA="error:${SHELLNAME} Failed to delete previous full backup."                         #前回バックアップ削除失敗
  err_smg_dldbFA="error:${SHELLNAME} Failed to delete differential backup taken last week."          #前週バックアップ削除失敗
  inf_msg_moutAL="info:${SHELLNAME} Continue processing because it is already mounted"               #既にマウント済みの為、後続処理を続行
  err_msg_nfssNF="error:${SHELLNAME} NFSserver is not found"                                         #NFSサーバー(ログ集)が不明
  err_msg_nfsmFD="error:${SHELLNAME} NFS mount Faild"                                                #NFSマウント失敗
  err_msg_bkdrNF="error:${SHELLNAME} Backup directory is not found"                                  #バックアップディレクトリが不明
  inf_msg_notmou="info:${SHELLNAME} not mounted"                                                     #NFSマントされていない
  err_msg_unmoFD="error:${SHELLNAME} NFS unmount Faild"                                              #NFSマウント解除失敗
  err_msg_bkvrFD="error:${SHELLNAME} Backup verification failed:"                                     #バックアップ検証失敗
  inf_msg_chkFlg="info:${SHELLNAME} Flagfile check Complete"                                         #業務連携フラグチェック成功  ※ 2020/09/07 追加

  shellErr_msg="error:${SHELLNAME} Processing Faild :Exception Err"                                  #エラー　：予定外エラー
  END_msg_NoFlag="error:${SHELLNAME} The Flagfile for starting dbbackup is not found. Shell stop."   #終了メッセージ　業務処理完了フラグがないため、エラー終了  ※ 2020/09/07 追加
  END_msg_err="${SHELLNAME} Processing complete :shell Process error"                                #終了メッセージ　エラー終了
  END_msg_comp="${SHELLNAME} Processing complete :shell Process complete"                            #終了メッセージ　正常終了
  
  inf_pgr_show="-----Output backup catalog information :"                                           #バックアップカタログのログ出力開始区切り
  
  ###########バックアップカタログ初期化###############
  #概要：
  #  PostgreSQLのバックアップツール
  #「pg_rman」の実行に必要なパラメーターをセットする
  ####################################################
  
  #pg_rmanパラメーターセット
  #pg_rman init -B ${nfs_dir} -D ${pg_dat} -A ${pg_wal}
  

########################## pg_rman 戻り値制御####################################################
#処理名　　：fnc_rtn_val
#引数　　　
#　　引数１：$1
#　　値　　：pg_rman実行後の戻り値
#　　内容　：実行結果
#戻り値　　
#　　戻り値：rman_val
#　　値　　：下記、pg_rmanの戻り値が示すメッセージ
#　　内容　：pg_rmanの戻り値から内容を判別してメッセージをセット
#概要：
#  pg_rmanの戻り値が正常/異常以外にも制御可能な為、
#  戻り値から、ログに出力するメッセージを判別し変数にセットする。
#
#その他：pg_rman戻り値
#  ---------------------------------------------------------------------------------------
#  戻り値  |メッセージ                     |概要
#  ---------------------------------------------------------------------------------------
#  0       |SUCCESS                        |正常に終了しました。 
#  1       |HELP                           |ヘルプを表示し、終了しました。 
#  2       |ERROR                          |未分類のエラーです。 
#  3       |FATAL                          |エラーが再帰的に発生し強制終了しました。 
#  4       |PANIC                          |未知の致命的エラーです。 
#  10      |ERROR_SYSTEM                   |I/O またはシステムエラーです。 
#  11      |ERROR_NOMEM                    |メモリ不足です。 
#  12      |ERROR_ARGS                     |入力パラメータが不正です。 
#  13      |ERROR_INTERRUPTED              |シグナルにより中断されました。(Ctrl+C 等) 
#  14      |ERROR_PG_COMMAND PostgreSQL    |サーバへ発行したSQLが失敗しました。 
#  15      |ERROR_PG_CONNECT PostgreSQL    |サーバに接続できません。 
#  20      |ERROR_ARCHIVE_FAILED WAL       |アーカイブに失敗しました。 
#  21      |ERROR_NO_BACKUP                |バックアップが見つかりません。 
#  22      |ERROR_CORRUPTED                |バックアップが破損しています。 
#  23      |ERROR_ALREADY_RUNNING          |他の pg_rman が実行中です。 
#  24      |ERROR_PG_INCOMPATIBLE          |PostgreSQL サーバとの互換性がありません。 
#  25      |ERROR_PG_RUNNING               |PostgreSQL サーバが起動中のためリストアできません。 
#  26      |ERROR_PID_BROKEN               |postmaster.pid ファイルが破損しています。 
#  ---------------------------------------------------------------------------------------
##############################################################################################
function fnc_rtn_val(){
 
 case "$1" in
   "2" ) rman_val="ERROR" ;; 
   "3" ) rman_val="FATAL" ;;
   "4" ) rman_val="PANIC" ;;
   "10" ) rman_val="ERROR_SYSTEM" ;;
   "11" ) rman_val="ERROR_NOMEM" ;;
   "12" ) rman_val="ERROR_ARGS" ;;
   "13" ) rman_val="ERROR_INTERRUPTED" ;;
   "14" ) rman_val="ERROR_PG_COMMAND PostgreSQL" ;;
   "15" ) rman_val="ERROR_PG_CONNECT PostgreSQL" ;;
   "20" ) rman_val="ERROR_ARCHIVE_FAILED WAL" ;;
   "21" ) rman_val="ERROR_NO_BACKUP" ;;
   "22" ) rman_val="ERROR_CORRUPTED" ;;
   "23" ) rman_val="ERROR_ALREADY_RUNNING" ;;
   "24" ) rman_val="ERROR_PG_INCOMPATIBLE" ;;
   "25" ) rman_val="ERROR_PG_RUNNING" ;;
   "26" ) rman_val="ERROR_PID_BROKEN" ;;
  esac

}

##################### ログ出力関数 ########################################
#処理名　　：fnc_logmsg
#引数　　　：
#　引数１：$1
#　値　　：メッセージ
#　内容　：チェック時のActive/inactiveの状態を指定
#
#　引数２：$2
#　値　　：Severity値(2～6）
#　内容　：関数呼び出し時にSeverityとして付与
#概要：
#  syslogのフォーマット形式(BSD)でログファイルに
#  実行ログを出力する。
#  併せて、画面に出力する。
#  
#  shellの実行結果の為、Facilityは、1：user-level messagesに固定
#  Priorityの値を求める際にFacilityは×8の値を利用するので８固定
#  Severity は以下とし、引数にて判別する
#    2：Critical: critical conditions 
#    3：Error: error conditions 
#    4：Warning: warning conditions 
#    5：Notice: normal but significant condition 
#    6：Informational: informational messages 
###########################################################################
function fnc_logmsg() {
  local pri=$((8+$2))
  local fname=${BASH_SOURCE[1]##*/}
  echo -e "${pri} $(date '+%Y-%m-%dT%H:%M:%S') `hostname`:(${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $1" |sudo tee -a ${SHELL_LOG}
}

####################　終了処理　####################
#処理名  ：Fnc_End_Proc
#引数　  ：
#　引数１：$1                                     ※本当は引数なしなのでは。
#　値　　：fnc_logmsg　に渡すSeverity値
#　内容　：メッセージのpriに使う値をセット
#処理概要：
#  1)NFSマウントを解除する
#  2)正常終了時のみ、業務処理への連携フラグファイルを作成
#  3)終了ステータスから処理結果をログ及び画面出力し
#  戻り値を付与して処理終了
#  
#$end_st値による終了処理分岐：
#      0: 正常終了
#      1: 業務連携フラグがないため、終了
#  9(他): 異常終了
####################################################
function Fnc_End_Proc(){
  
  #処理完了メッセージ(正常/異常)を出力してshell終了         ※ ロジックを整えました 2020/09/07
  if [ ${end_st} = "" ];then           # 終了ステータスのフラグがセットされていない場合エラーとする
    Fnc_discnt_nfs
    fnc_logmsg "$shellErr_msg" 6
    #例外エラーが発生しているのでsyslogにもエラーメッセージを出力
    logger -i -- "$shellErr_msg"
    exit 9

  elif [ ${end_st} = 0 ];then          # 正常終了
    touch $BKend_Flag    # 方式から業務への連携フラグ作成
    Fnc_discnt_nfs
    fnc_logmsg "$END_msg_comp" 6
    exit 0
    
  elif [ ${end_st} = 1 ];then          # 業務処理完了フラグファイルがないため、終了  ※ 2020/09/07 追加
    fnc_logmsg "$END_msg_NoFlag" 4
    logger -i -- "$END_msg_NoFlag"
    exit 1
    
  else                                 # 異常終了
    Fnc_discnt_nfs
    fnc_logmsg "$END_msg_err" 6
    logger -i -- "$END_msg_err"
    exit 9
  fi

}

####################　NFS切断　####################
#処理名  ：Fnc_discnt_nfs
#引数　  ：none
#処理概要：
#  NFSマウントを解除する
#  
####################################################
function Fnc_discnt_nfs(){

#マウント解除

  #マウント状態確認
  sudo mountpoint -q $mount_p

  #確認コマンドの戻り値からNFSマウントされてない場合のみ処理
  if [ $? = 0 ];then
    #NFSマウント解除
    sudo -t nfs umount ${mount_p} 

    if [ $? != 0  ];then
      #解除失敗メッセージ
      msg=$err_msg_unmoFD
      fnc_logmsg "$msg" 6
    fi
  
       
  elif [ $? = 1 ];then
    #マウントされていない為、メッセージ出力のみ
    msg=$inf_msg_notmou
    fnc_logmsg "$msg" 6
    
  fi

}

####################　NFS接続　####################
#処理名  ：Fnc_Cnct_nfs
#引数　  ：none
#処理概要：
#  NFSに接続する
#  
####################################################
function Fnc_Cnct_nfs(){


     #マウント状態確認
     sudo mountpoint -q $mount_p
     
     #確認コマンドの戻り値からNFSマウントされてない場合のみ処理
     if [ $? = 0 ];then
       #マウント済みの為、メッセージ出力のみでマウント処理をしない
       msg=$inf_msg_moutAL
       fnc_logmsg "$msg" 6
       
     elif [ $? = 1 ];then
       #BK/ログ集サーバー確認(戻り値だけ欲しいので標準出力は破棄)
       ping -c 1 $nfs_host
       
       if [ ! $? = 0 ];then
       
         #サーバーが見つからない為、メッセージを出力し処理終了(戻り値9)
         fnc_logmsg "$err_msg_nfssNF" 3
         end_st=9
         #終了処理の呼び出し
         Fnc_End_Proc 3
       
       fi
       
       #NFSマウント
       sudo mount -t nfs ${nfs_host}:${nfs_dir} ${mount_p}
       
       if [ ! $? = 0 ];then

         #NFSマウント失敗した為、メッセージを出力し処理終了(戻り値9)
         fnc_logmsg "$err_msg_nfsmFD" 3
         end_st=9
         #終了処理の呼び出し
         Fnc_End_Proc 3
       
       fi
     fi
     
   #バックアップディレクトリ確認  
   if [ ! -e "${mount_p}/${bkdir}" ]; then
      #バックアップ先のディレクトリなしの為、メッセージを出力し処理終了(戻り値9)
      fnc_logmsg "$err_msg_bkdrNF" 3
      end_st=9
      #終了処理の呼び出し
      Fnc_End_Proc 3
   
   fi

}


#############　業務処理フラグチェック　#############
#処理名  ：Fnc_Chk_flag
#引数　  ：none
#処理概要：
#  業務処理完了フラグファイルのチェック
#
#  60秒間隔でチェックし、180回チェックして存在しなければ、
#  プロセス終了
#  
#ローカル変数：
#  ---------------------------------------------
#  変数名        |説明
#  ---------------------------------------------
#  WatchFile     |フラグファイルパス
#  flag_count    |フラグチェックのカウンタ 
#  max_flag_coun |カウンタの上限値
#  Wait_time     |フラグチェック間隔
#  ---------------------------------------------
####################################################
function Fnc_Chk_flag(){
  # ローカル変数定義
  local WatchFile="/data/import_result/dbloadComplete"
  local flag_count=0
  local max_flag_count=180
  local Wait_time=60

  # フラグチェック処理
  while [ $flag_count -lt $max_flag_count ]
  do
     #フラグの存在確認
      if [ -f $WatchFile ]; then
          sudo rm -f $WatchFile
          fnc_logmsg "$inf_msg_chkFlg" 6
          break
      fi
      
      flag_count=`expr $flag_count + 1`
      sleep $Wait_time
  done

  # フラグチェック回数が上限に達した場合、業務影響をなくすためシェル終了
  if [ $max_flag_count -eq $flag_count ]; then
      end_st=1
      Fnc_End_Proc
  fi
}


####################メイン処理#########################
#概要：
#  1)処理前チェック
#  2)バックアップ取得
#  3)過去バックアップ削除
#######################################################
  #戻り値フラグ用変数のリセット
  cmd_st=""

  #シェルスタートのメッセージ出力    # 20200907 追加
  msg=$shellStart_msg
  fnc_logmsg "$msg" 6

  #業務処理フラグのチェック          # 20200907 追加
  Fnc_Chk_flag

  #バックアップ処理開始メッセージ出力
  msg=$inf_msg_flbkST
  fnc_logmsg "$msg" 6

  #NFSマウント
  Fnc_Cnct_nfs

  #前回取得フルバックアップの存在確認
  #前回実行日を取得
  pre_date=`date -d "7 days ago " +%Y-%m-%d`
    
  #バックアップの一覧から対象の数を取得(対象日付のFULLが存在すること)
  count=`pg_rman show | grep -v grep | grep $pre_date | grep  FULL | wc -l` > /dev/null
  
  if [ ${count} = 0 ];then
      msg=$inf_msg_exisFB
      fnc_logmsg "$msg" 6
    
  fi
    
  #先週取得差分バックアップの存在確認    ※ 差分バックアップ廃止のため、コメントアウト 2020/09/07
  ##7日前を取得
  ## pre_date=`date -d "7 days ago " +%Y-%m-%d`
  ##   
  ## #バックアップの一覧から対象の件数を取得(対象日付のINCRが存在すること)
  ## count=`pg_rman show |grep -v grep | grep $pre_date | grep INCR | wc -l` > /dev/null
  ## 
  ## if [ ${count} = 0 ];then
  ##   msg=$inf_msg_exisDF
  ##   fnc_logmsg "$msg" 6
  ##   
  ## fi

  #バックアップ実行
  pg_rman backup --backup-mode=${bk_mode} --compress-data --progress --keep-data-generations=${keep_gen} --keep-data-days=${cycle_d} --keep-arclog-days=${keep_arc}

  #実行結果を変数に格納
  cmd_st=$?

  #実施結果
  if [ ${cmd_st} = 0 ];then
    #終了ステータスをセット
    end_st=0
  
  else
    #戻り値からエラーメッセージを取得
    fnc_rtn_val "$cmd_st"
    
    #エラーメッセージの出力
    msg=${err_msg_flbkFA}${rman_val}
    fnc_logmsg "$msg" 3
    end_st=9
    
    #終了処理を呼び出し
    Fnc_End_Proc 3
    
  fi

  #バックアップ検証
  pg_rman validate
  
  #実行結果を変数に格納
  cmd_st=$?
  
  #検証結果
  if [ ${cmd_st} = 0 ];then
    #終了ステータスをセット
    end_st=0
    
  else
    #戻り値からエラーメッセージを取得
    fnc_rtn_val "$cmd_st"
    
    #エラーメッセージの出力
    msg=${err_msg_bkvrFD}${rman_val}
    fnc_logmsg "$msg" 3
    end_st=9
    
    #終了処理を呼び出し
    Fnc_End_Proc 3
    
  fi
  
  #バックアップカタログ情報をログに出力
  echo "${inf_pgr_show}STRA----" |sudo tee -a ${SHELL_LOG} 
  pg_rman show detail |sudo tee -a ${SHELL_LOG}
  echo  "${inf_pgr_show}END----" |sudo tee -a ${SHELL_LOG}
  
  #nfsマウント先の古いバックアップディレクトリ/ファイルを削除            # 20200702 追加
  find $BACKUP_PATH -maxdepth 1 -type d -mtime +${keep_bkdir} -print | grep -E '[0-9]{8}' | xargs --no-run-if-empty rm -r
  #find $BACKUP_PATH -maxdepth 1 -type d -mtime +${keep_bkdir} -print | grep -E '[0-9]{8}' | xargs --no-run-if-empty ls -ld   # テスト用
  
  
#############  終了処理     ###########################
#概要：
#　業務処理連携のため、正常終了の処理直前に
#　バックアップ処理完了のフラグファイルを作成する。
#
#　処理結果から正常/異常終了に応じて、
#　メッセージを出力後戻り値を付与して処理終了を行う為、
#　エラートラップされ途中で終了していないので
#　本処理を通過時は「正常終了」とし
#　完了ステータスは「０(正常)」
#######################################################
  
  #終了処理(正常終了)
  end_st=0
  Fnc_End_Proc 6
