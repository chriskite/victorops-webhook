require 'openssl'
require 'base64'

module VictorOpsWebhook::Plugin
  class Hipchat < Sinatra::Base
    configure :development do
      enable :logging
    end

    helpers do
      def verify!
        victorops_sig = request.env['HTTP_X_VICTOROPS_SIGNATURE'].to_s
        logger.info "Sig is |#{victorops_sig}|"
        halt 403 unless !!victorops_sig
        
        token = ENV['VICTOROPS_HIPCHAT_TOKEN'].to_s
        logger.info "Token is #{token}"

        data = request.url.to_s
        data += params.sort.inject("") { |acc, vars| acc += vars[0].to_s + vars[1].to_s }
        logger.info "Data is #{data}"

        computed_sig = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), token, data)).to_s.chomp
        logger.info "Computed sig is |#{computed_sig}|"

        halt 403 unless victorops_sig == computed_sig

        logger.info("ITS ACTUALLY VICTOROPS!")
      end
    end

    before do
      verify!
    end

    post '/hipchat/:key' do
      # TODO post to hipchat room for route key params['key']
    end
  end
end
