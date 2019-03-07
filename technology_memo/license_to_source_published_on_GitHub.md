---
layout: default
title: GitHubで公開したソースにオープンソースライセンスの適用
---
# GitHubで公開したソースにオープンソースライセンスを適用

GitHubを無償で使う場合には、ソースコードをオープンソースする必要があります。
私も含め、オープンソースライセンスを適用しているソースコードを見かけることは正直少ないので現実かと思われます。
(実際に統計をとったわけではないので個人的な所感です。)
では、Githubの利用条件に合うように個人でオープンソースライセンスが適用できるのか調査・検証してみました。

## オープンソースライセンスとは？

まず、オープンソースソフトウェア（OSS）とは、ソースコードが無償で公開されており、だれでも複製・配布・改良できるソフトウェアのことを指す。
しかし、複製・配布・改良の範囲は【OSSライセンス】によって制限されています。

ちなみに、【有償】で販売されており、複製・配布・改良が禁止されているソフトウェアを【プロプライエタリ・ソフトウェア】と言い、複製・配布・改良が禁止されているが【無償】で提供されているソフトウェアを【フリーウェア】と言います。

IPA(独⽴⾏政法⼈ 情報処理推進機構)のライセンス関する情報を抜粋すると

>OSS ライセンスの条件はライセンス別に異なるが、現在の OSS ライセンスのほとんどは、「コピーレフト」と呼ばれる概念への適⽤状況に応じて、3 つのカテゴリ（類型）に分類することができその特徴を以下に示す。

| OSS ライセンスのカテゴリ・類型                   | ①改変部分のソースコードの開⽰ | ②他のソフトウェアのソースコード開⽰ |
| :----------------------------------------------- | :---------------------------- | :---------------------------------- |
| コピーレフト型ライセンス（代表： GPL）           | 要                            | 要                                  |
| 準コピーレフト型ライセンス（代表： MPL）         | 要                            | 不要                                |
| ⾮コピーレフト型ライセンス（代表： BSD License） | 不要                          | 不要                                |

## オープンライセンスの種類

現在どのライセンスの利用割合の[調査結果](https://www.blackducksoftware.com/top-open-source-licenses)が以下となります。

MIT Licenseが圧倒的に多いですね。だだし、GitHubだとどうなのか・・・。

| 順位 | ライセンス名                                               | 利用割合 |カテゴリ|
| ---- | ------------------------------------------- | -------- | ------------- |
| 1    | MIT License                                                | 38%      | ⾮コピーレフト型 |
| 2    | GNU General Public License (GPL 2.0)                       | 14%      | コピーレフト型 |
| 3    | Apache License 2.0                                         | 13%      | ⾮コピーレフト型 |
| 4    | ISC License                                                | 10%      | ⾮コピーレフト型 |
| 5    | GNU General Public License (GNU) 3.0                       | 6%       | 準コピーレフト型 |
| 6    | BSD License 2.0 (3-clause, New or Revised) License         | 5%       | ⾮コピーレフト型 |
| 7    | Artistic License (Perl)                                    | 3%       | 準コピーレフト型 |
| 8    | GNU Lesser General Public License (LGPL) 2.1（バージョン） | 3%       | 準コピーレフト型 |
| 9    | GNU Lesser General Public License (LGPL) 3.0バージョン）   | 1%       | 準コピーレフト型 |
| 10   | Eclipse Public License (EPL)                               | 1%       | 準コピーレフト型 |


## 個人で適用できるオープンライセンスは？

【オープンソース】と言うとなんか大掛かりな【オープンソースプロジェクト】に参加しているのかと思いがちですが、意外とそうでもないみたいです。

「自分の書いたソースコードが誰かの役に立てれば」という気持ちで、誰でもオープンソースのプロジェクトを作れちゃうんです。

一番簡単なのが、【パブリックドメイン】です。ようするに【権利放棄】ということなので誰でも自由に好き勝手に使えます。CC0など

だけど、せっかく作ったソースコードなのだから作者名ぐらい残したいですよね。

それに自分の名前を載せられないぐらい自信がないソースコードではあれば、そもそも公開しなければいいんですし。

また、オープンソースで公開したのにも関わらず、制限をかけるようなコピーレフト型、準コピーレフト型のライセンスは個人的には正直つまらないし、「自分の書いたソースコードが誰かの役に立てれば」に反しているので【⾮コピーレフト型】を適用したいですね。

## GitHubで公開している文書(MarkDownなど)とか画像もオープンソースライセンス適用対象なのか？

ブログやSNSなどで公開した文章や画像なんかは何もしなくても、【著作権法】で守られています。

ですが、ソースコードも含め文章も画像も『ドンドン使っていいよ』と思うのであれば、文章も画像も対象としてオープンソースライセンスを選定しなければなりません。

【MIT License】だと、ソフトウェアを対象としているため明示的に文書や画像も対象とは書かれていないので、少し不安を感じます。

かと言って、【CC Licenses】は文章、画像を対象としているが、プログラムコードの利用を許諾していない。

それなら【MIT License】、【CC Licenses】のいずれも適用するようにすればいいのではないか。

## オープンソースライセンスの適用方法

### CC Licensesの原文を取得

ここに[CC Licensesの原文](https://creativecommons.org/licenses/by/4.0/legalcode.txt)があるので、テキスト部分をコピーし、【LICENSE】として保存します。

### MIT Licensesの原文を取得

ここに[MIT Licensesの原文](https://opensource.org/licenses/mit-license.php)があるので、テキスト部分をコピーし、【LICENSE】として保存します。

**要するに２つのライセンスを一つの文書【LICENSE】に記載すればいいのです。多分・・・**

### README.mdに記載する

【README.md】の文末にソースコードは【MIT Licenses】を使用し、GitHub Pagesで公開している【文章】や【画像】を【CC Licenses】ですよと主張するために以下を追記します。

```
# License
The source code is licensed MIT. The website content is licensed CC BY 4.0,see LICENSE.
```

### 各ソースコードに記載する

各ソースコードにコメント※1でMIT Licensesを表記します。
ここで原文を全て記載する必要はなく、『詳細は【LICENSE】を見てネ』としています。※2

※1:コメントの記述方法は、各プログラミング言語の文法に合わせてください。

※2:公式サイトでは、『「著作権表示」と「ライセンスの全文」の掲載については、ソースコードの中や、同梱の別ファイルなどに下記のような記述を掲載するだけでかまいません。』となっているため。

【例】

```
Copyright (c) 2019 Daisuke Sakamoto (Legit Whiz)
This software is released under the MIT License, see LICENSE.
```

### GitHub Pagesのソースコード

GitHub Pagesで公開しているhtmlやmarkdownで書かれた【文書】、contentsで使用している【画像】は、【CC Licenses】を使用し、contentsに記載したソースコードは【MIT Licenses】を使用し、ライセンス情報は『詳細は【LICENSE】を見てネ』としています。そして、その内容をhtmlやcssもしくはmarkdownに記載します。

【例】

```
Copyright (c) 2019 Daisuke Sakamoto (Legit Whiz)
This software is released under the MIT License, see LICENSE, see LICENSE.
This website content is released under the CC BY 4.0 License, see LICENSE.
```

### GitHubで公開

【LICENSE】、【README.md】、【MIT Licenses】を表記を入れたソースコード、【CC Licenses】をを表記を入れたCSS、htmlをGitHubにプッシュすれば完了となります。
って簡単でしたね。



なお、【MIT Licenses】の適用方法は、以下を参考にさせていただきました。

(この場を使ってお礼申し上げます。)

[MITライセンスのソースコードをGithubにあげるまで](https://qiita.com/syamaoka/items/ac9ceda558e03378a658)





ちなみにGitHubに【LICENSE】をプッシュすると自動的に内容によりライセンス種別を判断してリポジトリにライセンス形態を表示してくれてました。

【MIT Licenses】の場合

![MIT_Lisence](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/MIT_Lisence.png)

【CC Licenses】の場合

![MIT_Lisence](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/CC_License.png)

【MITとCC】を混在した場合

![MIT_Lisence](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/View_License.png)





