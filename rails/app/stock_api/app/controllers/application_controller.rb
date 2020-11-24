class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # 例外ハンドラ
  rescue_from Exception,                      with: :render_500 unless Rails.env.development?
  rescue_from AppValidationError,             with: :handle_validation_error
  rescue_from AppAjaxOnlyError,               with: :handle_ajax_only_error
  rescue_from AppNotFoundError,               with: :render_404 unless Rails.env.development?
  rescue_from ActiveRecord::RecordNotFound,   with: :render_404 unless Rails.env.development?
  rescue_from ActionController::RoutingError, with: :render_404 unless Rails.env.development?


  def handle_validation_error
    render action_name
  end

  def handle_ajax_only_error
    render nothing: true, status: :service_unavailable
  end

  def render_403(message)
    if request.xhr? || params[:format] == :json
      render json: { error: message }, status: 403
    else
      render template: 'errors/error_403', status: 403, locals: { message: message }, format: :html
    end
  end

  def render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.pretty_log}" if e

    if request.xhr? || params[:format] == :json
      render json: { error: '404 Not Found' }, status: 404
    #elsif request.url.split("/")[3] == 'admin'
    #  render template: 'errors/admin_error_500', status: 500, locals: { exception: e }
    else
      render template: 'errors/error_404', status: 404, locals: { exception: e }, format: :html
    end
  end

  def render_500(e = nil)
    logger.error "Rendering 500 with exception: #{e.pretty_log}" if e

    if request.xhr? || params[:format] == :json
      render json: { error: '500 Internal Server Error' }, status: 500
    #elsif request.url.split("/")[3] == 'admin'
    #  render template: 'errors/admin_error_500', status: 500, locals: { exception: e }
    else
      render template: 'errors/error_500', status: 500, locals: { exception: e }, format: :html
    end
  end

  def allow_ajax_only!
    raise AppAjaxOnlyError.new unless request.xhr?
  end

  # Etag と Last-Modified ヘッダを付与してファイルダウンロードを行う
  def send_file_with_etag(file_path, filename: nil, disposition: :inline, extract_gzip: false)
    f = file_path.is_a?(Pathname) ? file_path : Pathname.new(file_path)
    stat = f.stat
    filename ||= File.basename(f.to_s)

    # キャッシュコントロール
    return unless stale?({etag: stat.mtime, last_modified: stat.mtime})

    if extract_gzip && f.to_s.end_with?('.gz')
      # 圧縮ファイルを展開して送る
      require 'zlib'
      data = ''
      Zlib::GzipReader.open(file_path) {|gz| data=gz.read }  # 圧縮ファイルの中身を取り出す
      filename = filename.delete_suffix('.gz') # 末尾の .gz を取り除く
      send_data data, disposition: disposition, filename: filename, length: data.size
    else
      # そのままファイルを送る
      send_file f, disposition: disposition, filename: filename, length: stat.size
    end
  end

  helper_method :url_encode
  def url_encode(str)
    ERB::Util.url_encode(str)
  end
end
