require 'openssl'
require 'base64'
require 'hipchat'

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
      api_token = "" # FIXME get the api token from the ENV
      room = "" # FIXME get the room from the ENV

      client = HipChat::Client.new(api_token, :api_version => 'v2')

      msg = "#{params['message_type']} #{params['alert_type']}: #{params['entity_id']} - #{params['state_message']}. Routing key: #{params['routing_key']}".gsub(/"/, '') # FIXME get rid of the quotes in a better way

      client[room].send('VictorOps Hook', msg, :color => 'red')
    end
  end
end
