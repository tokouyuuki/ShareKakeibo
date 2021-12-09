# ShareKakeibo

## 概要
•Swiftで書かれた、家を共有する人々に特化した家計簿のアプリケーションです。<br>
•毎月の支払い額を自動計算する機能を搭載しています。<br>
•月々のお支払い状況や金額をカテゴリ別にグラフで表示する機能を搭載しています。<br>
•グループを作成して招待することができます。そのグループと情報を共有することもできます。<br>
•決済日を設定し、決済日が到来するとプッシュ通知でお知らせします。また、グループ内のユーザーが「有料」か「未払い」かを知ることができる機能を搭載しています。
<!-- • It is a household account book application specialized for people who share a house, written in Swift.  
• It is equipped with a function that automatically calculates your payment amount every month.  
• It is equipped with a function to display monthly payment transitions and amounts by category using graphs.  
• You can create groups and invite them. You can also share information with that group.  
• We will set a settlement date and notify you with a push notification when the settlement date arrives. In addition, it is equipped with a function that allows users in the group to know whether it is "paid" or "unpaid".   -->


## 目的
現在リリースされている共有家計簿アプリの多くは、多くの機能を備えているため、少し使いにくいアプリです。<br>
このシェア家計簿アプリは、機能がシンプルなので使いやすいです。<br>
使いやすさを重視したアプリを作るのが目的です。
<!-- Many of the currently released share household account book apps are a little difficult to use because they have many functions. This Share Kakeibo app is easy to use because it has simple functions.   -->


<!-- ## Demo
最近はアニメGIFなどを貼付けて実際の動作例を見せるプロジェクトをよく見る．頑張って拙い英語を長々と書くよりも，分かりやすいデモを準備した方が伝わりやすい．百聞は一見に如かずである．例えば，  

pearkes/gethub. 
peco/peco. 
tcnksm/cli-init. 
ユーザにツールをインストールさせることなく，使ってみたいと思わせることができる．  

自分は，アニメGIFの作成にRebuild #47で紹介されてたLICEcapを使っている．サイトを訪れるとその90年代感に驚くが，シンプルで使いやすい．  

 
 ## Usage
 ここでは，ツールを動かすためにはどのようなコマンドを用いれば良いのかを記載します。上では「動いた結果」を示しましたが，こちらは「動くための命令」を書きます。ターミナル上で引数を与える場合は，その旨も記載しておきましょう。データセットの細かい形式指定などもしておくと親切だと思います。
  -->
 
 ## 使用したライブラリー
 次の各サンプルをXcodeプロジェクトとして開き、モバイルデバイスまたはシミュレーターで実行できます。<br>
 ポッドをインストールして.xcworkspaceファイルを開くだけで、Xcodeでプロジェクトを確認できます。
 
<!--  You can open each of the following samples as an Xcode project, and run them on a mobile device or a simulator. Simply install the pods and open the .xcworkspace file to see the project in Xcode.   -->
 
  pod 'Firebase/Auth'<br>
  pod 'Firebase/Firestore'<br> 
  pod 'IQKeyboardManagerSwift'<br>
  pod 'ViewAnimator'<br>
  pod 'Firebase/Storage'<br> 
  pod 'SDWebImage'<br>
  pod 'Charts'<br>
  pod 'SegementSlide'<br> 
  pod 'Parchment'<br>
  pod 'CropViewController'<br>
