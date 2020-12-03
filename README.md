# Stock API

株式関連 API サーバ


## Usage

起動

```sh
rake init:development
rake compose:up_all
```

データ取込

```sh
rake rails:bash

# 以下は Rails コンテナ内での作業
bin/rails batch:quotations:load[202010]
bin/rails batch:quotations:load[202009]
bin/rails batch:quotations:load[202008]
```

データ取り込みが完了したら、ブラウザで以下のURLにアクセスしてみて下さい。
`https://${docker_host}/inheritance?date=20201024&codes=1301`

## コンテナへのアタッチ方法

起動中のコンテナの中へ入ってシェルを使用したい場合などは、`rake rails:bash` コマンドを使います。
スーパーユーザでのシェルが必要な場合は、`rake rails:root_bash` コマンドを使って下さい。

他にも様々な構成間利用の Rake タスクが定義されています。
`rake -T` としてどんなコマンドが利用可能か確認してみてください。

### 例1: Rails のデバッグ起動

```sh
rake rails:debug
```

### 例2: コンテナの終了および再起動

```sh
# 終了
rake compose:down

# 起動
rake compose:up_all
```

## ローカルデバッグ用のHTTPS証明書の生成

`mkcert` を使ってローカルデバッグ用のHTTPS証明書を生成することができます。
ヘルパースクリプトが用意されているので、以下のように実行するだけです。 
※事前に `mkcert` がインストールされている必要があります。Macでは `brew install mkcert` とするだけでインストールできます。

```bash
revproxy/run_mkcert.sh
```

コマンドが正常終了すると `revproxy/mnt/` ディレクトリに `cert.pem` `key.pem` ファイルが生成されますので、確認してください。

### 仮想マシンでDockerを利用している場合

`mkcert` は、Dockerを稼働させるPCではなくWebブラウザを起動するPCで行う必要があります。
仮想マシン環境で Docker を利用している場合は注意が必要です。
WebブラウザとDockerを稼働させる環境が異なる場合、以下のようにIPアドレスを追加指定することができます。

例: Dockerを稼働させるPCのIPアドレスが `192.168.59.105` の場合
```bash
revproxy/run_mkcert.sh 192.168.59.105
```

これで、ブラウザにて `https://192.168.59.105/` とアクセスしてもHTTPS証明書エラーが出ないようになります。

## 取り込み処理のcron登録

```
# 毎月7日〜12日の 10時、19時 ただし月曜〜金曜のみ
1 10,19 7-12 * 1-5  docker exec stock_api_rails bin/rails batch:quotations:load[`date '+\%Y\%m' --date '1 month ago'`]
```

