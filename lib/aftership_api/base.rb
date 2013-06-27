require 'httpi'
require 'json'

HTTPI.log = false

module AfterShipAPI
  module V2
    class Base
      def self.call(http_verb_method, *args)
        url = "#{AfterShipAPI::API_URL}/v#{AfterShipAPI::API_VERSION}/#{args.first.to_s}.#{AfterShipAPI::API_FORMAT}"
        req_body = {:api_key => AfterShipAPI.api_key}
        if args.last.is_a?(Hash)
          args.last.each do |k, v|
            HTTPI.logger.warn("this field #{k} should be array") if %w(emails smses).include?(k.to_s) && !v.is_a?(Array)
          end

          opt = {}
          args.last.each {|k, v| v.is_a?(Array) ? opt["#{k}[]"] = v : opt[k] = v}
          req_body.merge!(opt)
        end

        request = HTTPI::Request.new(url)
        request.body = req_body
        response = HTTPI.send(http_verb_method.to_sym, request)

        if response.nil?
          raise(AfterShipAPIError.new("response is nil"))
        else
          return JSON.parse(response.raw_body)
        end
      end

      class AfterShipAPIError < StandardError;
      end
    end
  end
end