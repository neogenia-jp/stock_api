FROM neogenia/ruby2.6-many-others:2.6.6

#####################################################
# timezone, lang settings
RUN ln -sf /usr/share/zoneinfo/Japan /etc/localtime

RUN echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=ja_JP.UTF-8

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:en
ENV LC_ALL ja_JP.UTF-8


#####################################################
# install sqlite3 and more
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    haskell-stack \
    cabal-install

# install hpdft
RUN cd /tmp \
 && git clone https://github.com/k16shikano/hpdft.git \
 && cd hpdft \
 && cabal update \
 && cabal install --bindir=/usr/local/bin

#####################################################
# set environment valiables
# RAILSアプリルートディレクトリのマウント先
ARG rails_app_mount_to=/var/rails
# アプリケーション制御スクリプトのコピー先
ARG scripts_copy_to=/var/scripts
# 外部ファイルのマウント先
ARG external_files_mount_to=/var/extfiles

ENV TERM=xterm \
    RAILS_ROOT_DIR=$rails_app_mount_to \
    SCRIPTS_ROOT_DIR=$scripts_copy_to \
    EXTERNAL_FILES_ROOT_DIR=$external_files_mount_to


#####################################################
# add scripts
ADD resources/monit/* /etc/monit/conf-available/
RUN ln -s /etc/monit/conf-available/rails /etc/monit/conf-enabled/
ADD resources/scripts $scripts_copy_to
# monit設定ファイルに記載されている環境変数を置換
RUN sed -i -e "s!@RAILS_ROOT_DIR!${RAILS_ROOT_DIR}!g" \
           -e "s!@SCRIPTS_ROOT_DIR!${SCRIPTS_ROOT_DIR}!g" \
           /etc/monit/conf-available/rails \
           /etc/monit/conf-available/delayed_job

RUN mkdir /var/www && chown www-data:www-data /var/www

# bundle default config
RUN mkdir /var/www && chown www-data:www-data /var/www
RUN bundle config set path vendor/bundle \
 && su www-data -c "bundle config set path vendor/bundle"

VOLUME $external_files_mount_to
VOLUME $rails_app_mount_to
WORKDIR $rails_app_mount_to

ARG rails_port=8079
EXPOSE $rails_port 1235 26163

ENV SECRET_KEY_BASE=00000000

