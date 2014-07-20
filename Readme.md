autotalks - AIトークを便利に
========================================

これはなにか
----------------------------------------

これは伺か用SHIORIサブシステムである美代(Miyo)の辞書フィルタプラグインです。

ゴーストによるユーザーの操作以外での自動発話、通称AIトークでよく使われる機能を提供するフィルタです。

インストール
----------------------------------------

### 一般

    npm install miyojs-filter-autotalks

### ゴーストに追加する場合

ghost/masterをカレントディレクトリとして同様に

    npm install miyojs-filter-autotalks

含まれるフィルタ
----------------------------------------

### autotalks

自動発話の内容を処理するフィルタです。

argumentのうちautotalksを使います。

### autotalks_caller

自動発話の間隔等を管理するフィルタです。

argumentのうちautotalks_callerを使います。

依存
----------------------------------------

このフィルタは以下に依存します。

- [miyojs-filter-variables]()
- [miyojs-filter-property]()
- [partperiod](https://www.npmjs.org/package/partperiod)

使用方法
----------------------------------------

MiyoのYAML辞書ファイルのエントリにフィルタを追加します。

    OnAITalk:
    	filters: [autotalks]

### autotalks

自動発話の内容(Value)を返します。

受け取ったstashにautotalks_triggerがあればそれが真のときのみ、なければ常に実行されます。
ただし以下で言及するjusttime条件をもった発話はその条件が整ったときautotalks_triggerに関わらず常に発話されます。

argumentのautotalks以下に自動発話の内容を記述します。

    OnAITalk:
    	filters: [autotalks]
    	argument:
    		autotalks:
    			-
    				when:
    					period: (@2012-*-*/2013-*-*@ && @*-10-12/*-10-16@)
    #					justtime: 1
    					once: id
    #					once_per_boot : id
    					condition: true == 1
    				priority: 2
    				bias: 3
    				do:
    					- \h\s[0]\e
    #				chain:
    #					- \h\s[0]\e

autotalks以下にそれぞれの条件をもった発話を配列として記述します。
この配列の順番は意味を持ちません。

この配列の各要素はそれぞれ以下の属性を持ちます。

これらの属性以外は無視されるので、識別等に使うことが出来ます。
ただし各属性の前に'_'をつけた属性は予約されていますので、使わないことが無難です。

#### when

条件の設定を記述します。

以下の属性を持ちます。

以下のうちの指定された属性の条件をすべて満たした場合のみ発話可能となります(AND)。

##### period - 期間の指定

この属性が有る場合、指定された期間にのみ発話します。

JavaScriptの式として評価できる文字列をとりますが、'@...@'は'(new PartPeriod(...)).includes(date)'に置換されます。

つまり'@...@'の'@'の間にPartPeriodによって解釈できる期間文字列を記述し、それが現在の日付と比較されます。

    period: (@2012-*-*/2013-*-*@ || @*-10-01/*-10-15@) && @12:*/17:*@

これは

    function(date){return ((new PartPeriod('2012-*-*/2013-*-*')).includes(date) || (new PartPeriod('*-10-01/*-10-15')).includes(date)) && (new PartPeriod('12:*/17:*')).includes(date)}

と解釈されます。

この式が真を返した場合のみ発話可能となります。

ここに指定された式は最初に実行される前にnew Function()によって関数化されキャッシュされます。
よってゴーストの実行中にこの値を書き換えることは実行時によって意味を成さず、避けるべきです。

この式はMiyoインスタンスをthisとして評価されます。
また現在日時を表すdate変数、SHIORIリクエストを表すrequest変数と呼ばれたエントリIDを表すid変数が使えます。

**注意** この属性は優先度とは関係ないので、期間中一度も発話されないことも考えられます。それを避けたい場合はpriority属性などを同時に利用してください。

##### justtime - 期間が来ればすぐ発話する

この属性が1である場合、指定された期間にできるだけはやく発話します。

    justtime: 1

発話するタイミングであることを通知するautotalks_triggerにかかわらず発話します。

ここに指定された値は最初に実行される前にキャッシュされます。
よってゴーストの実行中にこの値を書き換えることは実行時によって意味を成さず、避けるべきです。

**注意** この属性は優先度とは関係ないので、autotalks_triggerが発話可能としたときに期間が重なった場合は発話されないことも考えられます。それを避けたい場合はpriority属性などを同時に利用してください

**注意** この属性を指定する場合、(通常1秒ごとに)フィルタが呼ばれるたびに評価実行されるので、発話中にこの実行を避ける何らかの仕組みを用意する必要があります。またautotalks_triggerが発話可能となっていない場合実質的に優先的に発話されるので、期間を適切に設定したり、when.once属性やwhen.condition属性などを同時に利用してください。

##### once - 一回のみ

この属性が有る場合、ゴーストが初回起動してからアンインストールされるまでに一回のみ発話されます。

値には一意なID文字列を指定します。

    once: hoge

この文字列は複数の発話に対して指定されてもかまいませんが、その場合発話されるのはそのうち一つのみで、一度も発話されないものが存在することになります。
またIDはすべてのautotalksで共有されます。

**注意** この属性は優先度とは関係ないので、一度も発話されないことも考えられます。それを避けたい場合はpriority属性などを同時に利用してください。

##### once_per_boot - 起動ごとに一回のみ

この属性が有る場合、ゴーストが起動してから終了されるまでに一回のみ発話されます。

指定はonce属性と同一です。

##### condition - 一般的条件

この属性が有る場合、指定された条件が真である場合のみ発話します。

JavaScriptの式として評価できる文字列をとります。
ここに指定される式は真偽値を返すべきです。

true等の単純な値や、以下のような実行時によって代わる式も可能です。

    this.variables.hoge_flag == 'yes'

ここに指定された式は最初に実行される前にnew Function()によって関数化されキャッシュされます。
よってゴーストの実行中にこの値を書き換えることは実行時によって意味を成さず、避けるべきです。

この式はMiyoインスタンスをthisとして評価されます。
またSHIORIリクエストを表すrequest変数と呼ばれたエントリIDを表すid変数が使えます。

#### priority

優先度を指定します。

数値的に大小比較できる値をとります。
この属性がない場合はpriority=0とされます。

大きな値ほど優先度が高いとされ、その優先度の発話が発話可能であった場合それ以下の優先度の発話は無視されます。

同じ優先度の場合その中からランダムに選ばれます。

    priority: 1

**注意** この属性は常に有効なので一定条件下の制限をつけなければ特定のものばかり発話されることになります。when.once属性やwhen.condition属性などを同時に利用してください。

#### bias

発話の頻度を指定します。
この属性がない発話はbias=1として処理されます。

biasの数値で重み付けられた(エントリのbias)/(全エントリのbiasの合計)の確率で発話が選択されます。

JavaScriptの式として評価できる文字列をとります。
ここに指定される式は正値を返すべきです。

42等の単純な数値や、以下のような実行時によって代わる式も可能です。

    this.variables.hoge_bias

ここに指定された式は最初に実行される前にnew Function()によって関数化されキャッシュされます。
よってゴーストの実行中にこの値を書き換えることは実行時によって意味を成さず、避けるべきです。

この式はMiyoインスタンスをthisとして評価されます。
またSHIORIリクエストを表すrequest変数と呼ばれたエントリIDを表すid変数が使えます。

#### do

発話が選ばれたときに返すエントリを記述します。

この内容はトップレベルのイベントエントリ直下の記述と同様にMiyo.prototype.call_entryで処理されるので、この下に配列やfilterを自由に記述できます。

    do:
    	filter: [autotalks]
    	argument:
    		...

#### chain

発話が選ばれたときに返すチェイントークを記述します。

do属性のかわりに指定します。
両方ある場合はchain属性が優先されます。

内容は配列で指定します。

    chain:
    	- \h\s[0]チェイン1\e
    	- \h\s[0]チェイン2\e
    	...

配列の各内容は1回の発話ごとに順番にMiyo.prototype.call_valueで処理されます。

このチェイントークを含む発話は一度選ばれるとその内容すべての発話が終わるまで他のすべての自動発話はなされません。

when.justtime属性をもつ発話のチェイントークの2つ目以降は通常の発話のタイミングでなされます。

### autotalks_caller

stashにautotalks_triggerを付加して指定されたIDのエントリをcall_id()を返します。

autotalks_triggerが真値である場合、自動発話の条件が満たされたことを示します。

以下で秒数という記述がありますが、これは正確にはこのフィルタが呼ばれた回数であり、OnSecondChangeのたびにこのフィルタが呼ばれることを前提としています。

argumentのautotalks_caller以下に自動発話の設定を記述します。

    OnSecondChange:
    	filters: [autotalks_caller]
    	argument:
    		autotalks_caller:
    			id: OnAITalk
    			count: 42
    			fluctuation: 5

属性は以下の通りです。

#### id - call_id()するエントリ名

OnAITalkエントリ等にautotalksフィルタを指定しておいて、そのエントリを呼ぶことを想定しています。

JavaScriptの式として評価できる文字列をとります。
ここに指定される式は正整数値を返すべきです。

単純な文字列や、以下のような実行時によって代わる式も可能です。

    this.variables.aitalk_mode == 'angry' ? 'OnAITalkAngry' : 'OnAITalk'

ここに指定された式は最初に実行される前にnew Function()によって関数化されキャッシュされます。
よってゴーストの実行中にこの値を書き換えることは実行時によって意味を成さず、避けるべきです。

この式はMiyoインスタンスをthisとして評価されます。
またSHIORIリクエストを表すrequest変数と呼ばれたエントリIDを表すid変数が使えます。

#### count - 通常の自動発話での発話間隔秒数

JavaScriptの式として評価できる文字列をとります。
ここに指定される式は正整数値を返すべきです。

42等の単純な数値や、以下のような実行時によって代わる式も可能です。

    this.variables.autotalk_interval == 'long' ? 300 : 60

ここに指定された式は最初に実行される前にnew Function()によって関数化されキャッシュされます。
よってゴーストの実行中にこの値を書き換えることは実行時によって意味を成さず、避けるべきです。

この式はMiyoインスタンスをthisとして評価されます。
またSHIORIリクエストを表すrequest変数と呼ばれたエントリIDを表すid変数が使えます。

#### fluctuation - 通常の自動発話での発話間隔秒数のゆらぎ秒数

count属性で指定された秒数±fluctuation属性で指定された秒数で発話します。

この属性がない場合、fluctuationは0とされます。

JavaScriptの式として評価できる文字列をとります。
ここに指定される式は正整数値を返すべきです。

仕様はcount属性と変わりません。

例
----------------------------------------

### 一番簡単な例

60秒に一回ランダムにしゃべるだけの例です。

    OnSecondChange:
    	filters: [autotalks_caller]
    	argument:
    		autotalks_caller:
    			id: OnAITalk
    			count: 60
    OnAITalk:
    	filters: [autotalks]
    	argument:
    		autotalks:
    			-
    				do:
    					- \h\s[0]AIトーク1です。\e
    					- \h\s[0]AIトーク2です。\e

### 入れ子になったautotalks

autotalksの発話のdo属性はトップレベルのエントリの内容と同様に処理されるのでautotalksを入れ子にすることが可能です。

    OnSecondChange:
    	filters: [autotalks_caller]
    	argument:
    		autotalks_caller:
    			id: OnAITalk
    			count: 60
    OnAITalk:
    	filters: [autotalks]
    	argument:
    		autotalks:
    			-
    				when:
    					period: @*-*-01/*-*-03@
    				do:
    					filter: [autotalks]
    					argument:
    						autotalks:
    							-
    								when:
    									condition: this.variables.akeome
    								do:
				    					- \h\s[0]あけおめ。\e

once属性などを指定する場合はIDが全autotalksで効果があることに注意してください。

### OnMinuteChangeのautotalks

時報を通知するにはOnSecondChangeに設定したautotalksでjusttimeを使うのもいいですが、OnMinuteChangeで処理することも可能です。

    

### 発話のかぶりを防ぐ

autotalksには発話中であることを判定する機能はありません。
そのためそのまま使用したのでは他のトークの発話中にかぶってしまうことがあったり、justtimeの扱いが難しいなどの問題があります。

これを解消するには発話状態を管理するvalue_filterプラグインの[miyojs-filter-talking]()などを利用し、autotalksを呼ぶ前に処理をはさむなどが考えられます。

    _load :
    	filters : [..., append_value_filters, ...]
    	argument :
    		append_value_filters:
    			...
    			- talking
    OnSecondChange:
    	filters: [conditions]
    	argument:
    		conditions:
    			-
    				condition: <%= ! vt.talking %>
    				result: <%= call_id('OnAITalk') %>
    OnAITalk:
    	filter: [autotalks_trigger, autotalks]
    	argument:
    		autotalks_trigger:
    			count: 60
    		autotalks:
    			-
    				do:
    					- \h\s[0]AIトーク1です。\e
    					- \h\s[0]AIトーク2です。\e
