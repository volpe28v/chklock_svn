Subversion 上でファイルをロックしているユーザ名を確認するスクリプトです。

[example]

$ chklock.rb 
   naoki    hello.html         #=> locking by naoki(me)
   zidane   hoge/hogehoge.rb   #=> locking by zidane(other)
 *          hoge/fuga2.c       #=> editing by me
 * naoki    hoge/fuga.cpp      #=> locking and editing by naoki(me)
 +          boost.js           #=> adding by me

[制限事項]
・ruby が必須です。(ruby 1.8.7 で動作確認済み)
・*(編集中) +(追加中)マークは自分のみ有効です

hoge

