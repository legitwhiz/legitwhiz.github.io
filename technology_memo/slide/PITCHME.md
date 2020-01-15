### GitPitchのサンプル

---

キーボードの「矢印キー」か、<br/>スマホの「フリック操作」で<br/>ページ移動ができます

+++

上下にも移動できます

---

### 外部のJSファイルを表示↓

+++?code=sample.js

リポジトリ内の「sample.js」を読み込んで表示してます

---

### 指定したコードのハイライト表示

```
var str1 = 'hello world';
var flag = true;
var result = 10 + 20;

console.log( str1 );
console.log( str2 );
console.log( str3 );
```
@[1](str1に「hello world」の文字列を代入)
@[2](flagに「true」を代入)
@[3](resultに「10 + 20」の計算結果を代入)
@[5-7](すべての変数をコンソールに表示する)

---

### gistのコードを表示↓

+++?gist=1f39d3baae495652ac52609cce31aaed

gistに公開したソースコードを読み込んで表示しています

---

### HTMLタグも利用可能

<br/>
<p style="font-weight: bold; color:#ffaaaa">これはstyle属性を付けたpタグです</p>
<br/>
リンクは<a href="#" target="_blank">コチラ</a>

---

### 順番にアニメーション表示

- Java
- JavaScript |
- Kotlin     |
- Go         |
- Scala      |

---

### グラフやチャートの表示

<canvas data-chart="radar">
  Month, 1月, 2月, 3月, 4月, 5月, 6月, 7月
  1980, 65, 59, 80, 81, 56, 55, 40
  2017, 28, 48, 40, 19, 86, 27, 90
</canvas>
