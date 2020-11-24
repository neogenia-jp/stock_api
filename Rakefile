def env_sh(cmd)
  sh "SCRIPT_DIR=bin/ source bin/common.sh && #{cmd}"
end

def env_extract(env_var_exp)
  `SCRIPT_DIR=bin/ source bin/common.sh && echo #{env_var_exp}`.chomp
end

def env_get(env_var_name)
  env_extract "$#{env_var_name}"
end

def env_get_from_container(env_var_name, container_name)
  `docker exec -t #{container_name} bash -c 'echo $#{env_var_name}'`.chomp
end

# run docker stop & rm
def ddown(name)
  sh "docker stop #{name}" if get_container_status(name) == 'running'
  sh "docker rm #{name}"
end

# run docker exec
def de(args)
  sh "docker exec #{args}"
end

# run docker-compose
def _dc(env, name, *args)
  sh "#{env} bin/run-docker-compose-#{name}.sh #{args.flatten.join(' ')}"
end

def dc(name, *args)
  _dc nil, name, *args
end

def dc_up(name, *args)
  _dc nil, name, 'up -d --build', *args
end

def ddc_up(name, *args)
  _dc 'DEBUG=manual', name, 'up -d --build', *args
end

def get_container_status(*container_names)
  a = container_names.map{|n| `docker inspect --format '{{.State.Status}}' #{n} 2>/dev/null`.chomp}
  a = a.first if a.length==1
  a
end

def wait_for_container_status(container_name, expected_status)
  while get_container_status(container_name) != expected_status.to_s do
    #echo "waiting container $container_name become to $expected_status"
    sleep 3
  end
end

def check_container_has_running(*container_names)
  [get_container_status(*container_names)].flatten.each.with_index do |s,i|
    raise "コンテナ`#{container_names[i]}` が起動していません。" if s != 'running'
  end
end

def rails_is_production_mode?(container_name = 'stock_api_rails')
  (env_get_from_container(:RAILS_ENV, container_name) || env_get(:RAILS_APP_ENV)) == 'production'
end

namespace :config do
  desc 'env_app.sh をエディタで開きます'
  task :app do
    sh '${EDITOR:-vi} bin/env_config/env_app.sh'
  end

end

namespace :submodule do
  desc 'サブモジュールを初期化します'
  task init: [] do
  end
end

namespace :fs do
  # 必要なディレクトリ一覧
  DIRS = %w[
    $RAILS_APP_ROOT_DIR/tmp
    $RAILS_APP_ROOT_DIR/log
    $RAILS_APP_ROOT_DIR/config
    $RAILS_APP_ROOT_DIR/public/packs
    $RAILS_APP_ROOT_DIR/.bundle
  ]

  DIRS.each do |dir_def|
    dir_path = env_extract dir_def
    task dir_def do
      mkdir dir_path unless Dir.exist? dir_path
      chmod 0777, dir_path
    end
  end

  desc '必要なディレクトリの作成、権限の設定を行います'
  task ensure_dir: DIRS do
  end
end

namespace :compose do
  desc 'コンテナ構成を停止し、削除します'
  task down: [] do
    dc 'all-in-one', 'down'
  end

  desc 'リバースプロキシコンテナを起動します'
  task up_front: [] do
    dc_up :revproxy
  end

  desc 'Railsコンテナを通常起動します'
  task up_rails: [] do
    dc_up 'all-in-one', :stock_api_rails
  end

  task ensure_rails: [] do
    if get_container_status(:stock_api_rails) != 'running'
      #Rake::Task['compose:up_rails'].invoke
      ddc_up 'all-in-one', :stock_api_rails
    end
  end

  desc 'ローカル開発用コンテナ構成を起動します'
  task up_all: [] do
    dc_up 'all-in-one'
  end

  desc 'ローカル開発用コンテナ構成をデバッグモードで起動します'
  task up_debug: [] do
    ddc_up 'all-in-one'
  end

  desc 'ローカル開発用コンテナ構成をデバッグモードで起動し、RailsのCUIデバッグを開始します'
  task up_debug_rails: ['compose:up_debug'] do
    Rake::Task['rails:debug'].invoke
  end
end

namespace :rails do
  desc 'Rails コンテナを停止し、削除します'
  task down: [] do
    ddown 'stock_api_rails'
  end

  desc 'Rails コンテナに入ります'
  task bash: %w|compose:ensure_rails| do
    de '-ti -u www-data stock_api_rails bash'
  end

  desc 'Rails コンテナに入ります(rootユーザ)'
  task root_bash: %w|compose:ensure_rails| do
    de '-ti stock_api_rails bash'
  end

  desc 'Rails コンテナで bundle install を実行します'
  task bundle_install: %w|compose:ensure_rails| do
    de '-t -u www-data stock_api_rails bundle install'
  end

  desc 'Rails コンテナですべてのテストを実行します'
  task test: %w|bundle_install| do
    de '-t -u www-data stock_api_rails bin/rails test'
  end

  desc 'Rails コンテナの動作モードを取得します'
  task env: [] do
    puts "CONFIG:"
    puts "  RAILS_APP_ENV: #{env_get :RAILS_APP_ENV}"
    puts "  ASSETS_DEBUG:  #{env_get :ASSETS_DEBUG}"
    s = get_container_status 'stock_api_rails'
    puts "CONTAINER: #{s}"
    next if s != 'running'
    puts "  DEBUG:         #{env_get_from_container :DEBUG, 'stock_api_rails'}"
    puts "  MYSQL_DB_HOST: #{env_get_from_container :MYSQL_DB_HOST, 'stock_api_rails'}"
    puts "  RAILS_ENV:     #{env_get_from_container :RAILS_ENV, 'stock_api_rails'}"
    puts "  ASSETS_DEBUG:  #{env_get_from_container :ASSETS_DEBUG, 'stock_api_rails'}"
    puts "  ENABLE_DELAYED_JOB:      #{env_get_from_container :ENABLE_DELAYED_JOB, 'stock_api_rails'}"
    puts "  EXTERNAL_FILES_ROOT_DIR: #{env_get_from_container :EXTERNAL_FILES_ROOT_DIR, 'stock_api_rails'}"
  end

  desc 'Rails console を開きます'
  task c: %w|bundle_install| do
    de '-ti -u www-data stock_api_rails bin/rails c'
  end

  desc 'Rails をデバッグ実行します'
  task debug: %w|compose:ensure_rails| do
    de '-ti stock_api_rails /var/scripts/start_debug_webapp.sh'
  end

  desc 'Rails をリモートデバッグで実行します'
  task remote_debug: %w|compose:ensure_rails| do
    de '-ti stock_api_rails /var/scripts/start_remote_debug_webapp.sh'
  end

  desc 'Rails のDBマイグレーション実行します'
  task db_migrate: %w|bundle_install| do
    de '-t -u www-data stock_api_rails bin/rails db:migrate'
  end

  desc 'Rails の assets をクリアしてプリコンパイルを実行します'
  task assets_regenerate: %w|bundle_install| do
    de '-t stock_api_rails rm -rf public/assets/*'
    de '-t -u www-data stock_api_rails bin/rails assets:precompile'
  end

  desc 'Rails をリスタートします'
  task restart: [] do
    de '-t stock_api_rails /var/scripts/restart_webapp.sh'
  end

  desc 'delayed_job を起動します'
  task start_delayed_job: [] do
    de '-t -u www-data stock_api_rails bin/delayed_job start'
  end

  desc 'Rails アプリケーションログを開きます'
  task log: [] do
    log_file = rails_is_production_mode? ? 'production' : 'development'
    de "-ti stock_api_rails less -R log/#{log_file}.log"
  end
end

namespace :init do
  desc '必要なファイル及びディレクトリの整備'
  task fs: %w|fs:ensure_dir| do
  end

  desc 'DBを初期化します'
  task db: %w|| do
  end

  desc '開発環境用に必要な初期化を全て行います(fs, db, container)'
  task development: %w|submodule:init init:fs init:db rails:db_migrate compose:down| do
  end

  desc 'プロダクション環境用に必要な初期化を全て行います(fs, db)'
  task production: %w|submodule:init init:fs compose:down| do
    log = env_extract '$RAILS_APP_ROOT_DIR/log/production.log'
    if File.exist? log
      chmod 777, log
    end
  end
end

namespace :deploy do
  desc 'git stash && git pull && git stash pop'
  task git_pull: [] do
    sh 'git stash'
    sh 'git pull'
    sh 'git stash pop'
  end

  desc 'webappサーバ用のコンテナ構成を再起動します'
  task up_webapp: %w|init:production| do
    dc :webapp, :down if get_container_status(:stock_api_rails).include? 'running'
    dc_up :webapp
    sh 'docker ps'
  end

  desc 'リバースプロキシを起動します'
  task up_revproxy: [] do
    dc_up :revproxy
    sh 'docker ps'
  end

  desc 'リバースプロキシを停止し削除します'
  task down_revproxy: [] do
    if get_container_status(:stock_api_revproxy) == 'running'
      sh 'docker stop stock_api_revproxy'
      sh 'docker rm stock_api_revproxy'
    end
    sh 'docker ps'
  end
end

