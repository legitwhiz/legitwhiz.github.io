#!/bin/sh

# git-sync
# git syncを叩くと
# リモートリポジトリをfetchする 消えたリモートブランチも掃除
# masterを最新にする
# 元いたブランチがマージ済みだったら消す
# プルリクがマージされた時に威力を発揮する
# そうじゃなかったら元いたブランチに戻る



user=`git config github.user`
git remote show ${user} > /dev/null 2>&1
has_repo=$?

git fetch --all --prune
modified=`git status | grep modified | wc -l`
if [ $modified -gt 0 ] ; then git stash ; fi
branch=`git branch | grep '*' | cut -f 2 -d ' '`
git checkout master
git pull --rebase origin master
if [ $has_repo = 0 ] ; then git push ${user} master; fi
if [ $branch != 'master' ] ; then
    if [ `git branch --merged | grep ${branch} | wc -l` -eq 1 ]
    then
        git branch -d ${branch}
    else
        git checkout ${branch}
    fi
fi
if [ $modified -gt 0 ] ; then git stash pop ; fi
