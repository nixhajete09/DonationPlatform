ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec'
require_relative '../app'

module AppHelper
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include AppHelper
end
