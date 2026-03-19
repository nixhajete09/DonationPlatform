# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'fileutils'
require 'rack/test'

FileUtils.mkdir_p('db')

require_relative '../app'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app
  Sinatra::Application
end
