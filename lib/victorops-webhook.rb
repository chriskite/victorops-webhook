require 'sinatra/base'
$:.unshift File.dirname(__FILE__)
require 'version'

# TODO Scan for and load plugins
require 'plugins/hipchat'

module VictorOpsWebhook
  class Root < Sinatra::Base
    use Plugin::Hipchat # TODO load plugins dynamically

    set :bind, '0.0.0.0'

    get '/' do
      "victorops-webhook #{VictorOpsWebhook::VERSION}"
    end

    # start the server if ruby file executed directly
    run! if app_file == $0
  end
end
