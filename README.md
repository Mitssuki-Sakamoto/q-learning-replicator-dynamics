# q-learning-replicator-dynamics

## コーディング規約

* 変数/関数名などの大文字・小文字とprefixは以下の規則に従う．

    | 名称                            | 規則                                                                                                           |
    | ------------------------------- | -------------------------------------------------------------------------------------------------------------- |
    | ローカル変数名                  | `camelCase`                                                                                               |
    | グローバル変数名                | `g_lowerCamelCase`                                                                                             |
    | クラス                 | `CamelCase`                                                                                                    |
    | メンバ変数名                    | `lowerCamelCase`                                                                                                                                                                    |
    | 関数名                    | `camelCase()`                                                                                             |
    | 定数 | `SNAKE_CASE`                                                                                                                                             



## ディレクトリ構成

```
root/
 ├ src/
 │  ├ env/ # 環境(ゲーム)強化学習とゲームを分離・統合
 │  ├ agent/　# エージェント
 │  ├ expriment/ # 強化学習のトレイン, レプリケータによる戦略の分析
 │  └ evolutionary_dynamics/ # レプリケータや利得計算
 └ outcomes/
    └hogehoge_yyyy-mm-dd-hh-mm-ss/
```
