module Util
  class WebRequest
    class << self
      def post(uri, params = {}, headers = {})
        request(:post, uri, params, headers)
      end

      def post_json(uri, json, headers = {})
        post(uri, json, headers.merge('Content-Type': "application/json"))
      end

      def get(uri, params = {}, headers = {})
        request(:get, uri, params, headers)
      end

      private
      def request(request_method, uri_str, params = {}, headers = {})
        uri = build_uri(request_method, uri_str, params)
        req = build_req(request_method, uri, params, headers)

        with_http(uri) do |http|
          http.request(req)
        end
      end

      def build_uri(request_method, uri_str, params)
        URI.parse(uri_str).tap do |uri|
          if request_method == :get
            query = params.to_query
            if query.size > 0
              uri.query = query
            end
          end
        end
      end

      def build_req(request_method, uri, params, headers)
        build_base_req(request_method, uri, params).tap do |req|
          if !headers.empty?
            headers.each do |k, v|
              req[k] = v
            end
          end
        end
      end

      def build_base_req(request_method, uri, params)
        case request_method
        when :post
          req = Net::HTTP::Post.new(uri.path)
          if String === params
            req.body = params
          else
            req.set_form_data(params)
          end
          req
        when :get
          Net::HTTP::Get.new(uri.request_uri)
        end
      end

      def with_http(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        yield http
      end
    end
  end
end

