# mail server
# NOTE: railsコンテナの中ではproductionモード以外は常に stock_api_mocksmtp 宛に配送されます
export SMTP_HOST=stock_api_mocksmtp
export SMTP_PORT=1025
export SMTP_USER_NAME=dummy
export SMTP_PASSWORD=dummy

# mail address
export USER_NOTIFY_MAIL_FROM='neogenia.dev@gmail.com'
export ADMIN_NOTIFY_MAIL_TO='neogenia.dev@gmail.com'
export DEVISE_MAIL_REPLY_TO='neogenia.dev@gmail.com'
export DEVELOPER_NOTIFY_MAIL_TO='neogenia.dev@gmail.com'

# 外部ファイル置き場のホスト側のディレクトリ
# 変更した場合イメージのbuildが必要
#export EXTERNAL_FILES_ROOT_DIR=


# その他
# 以下コンテナ固有

#############################################################################
# stock_api_rails
#############################################################################
# railsの実行環境を指定。
#export RAILS_APP_ENV=production

# delayed_job を起動するかどうか
#export ENABLE_DELAYED_JOB=1

# delayed_job を起動しているとき、worker のポーリングのログ出力を行うかどうか（何かしらの値をセットすると出力する）
#export ENABLE_DELAYED_JOB_RESERVE_LOG=1

# assetsのデバッグを行うかどうか(application.jsにまとめない)
#export ASSETS_DEBUG=1

# Puma の待受ポート番号
export RAILS_PORT=8079


#############################################################################
# domain(変更した場合, stock_api_revproxyのコンテナリビルドが必要)
#############################################################################
export APP_DOMAIN=stock_api.neogenia.co.jp

#############################################################################
# Let's Encrypt用変数
#############################################################################
export LETS_ENCRYPT_CERT_MAIL=neogenia.dev@gmail.com
