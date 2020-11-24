# https://stackoverflow.com/questions/6803307/omniauth-using-wrong-callback-port-in-a-reverse-proxy-setup/17809294
# https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/http/url.rb#L220
OmniAuth.config.full_host = lambda do |env|
  scheme         = env['rack.url_scheme']
  local_host     = env['HTTP_HOST']  # リバースプロキシ環境下では元のホスト名が設定されているはず
  "#{scheme}://#{local_host}"
end
