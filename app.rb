require 'sinatra'
require 'sinatra/contrib'
require 'sequel'
require 'dotenv/load'
require 'fileutils'

# Database setup
FileUtils.mkdir_p('db')
DB = Sequel.connect('sqlite://db/donation_platform.db')

# Models directory
require_relative 'app/models/campaign'
require_relative 'app/models/donation'
require_relative 'app/models/user'

# Routes
Dir.glob('app/routes/*.rb').each { |file| require_relative file }

configure do
  set :public_folder, 'public'
  set :views, 'app/views'
end

# Home page
get '/' do
  erb :index
end
