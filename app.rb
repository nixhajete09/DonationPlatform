require 'sinatra'
require 'sinatra/contrib'
require 'sequel'
require 'dotenv/load'
require 'pathname'

Dir.chdir(File.dirname(__FILE__))

# Database setup
DB = Sequel.connect('sqlite://db/donation_platform.db')

# Models directory
require './app/models/campaign'
require './app/models/donation'
require './app/models/user'

# Routes
Dir.glob('./app/routes/*.rb').sort.each { |file| require file }

configure do
  set :public_folder, 'public'
  set :views, 'app/views'
end

get '/ui' do
  redirect '/indsamling'
end

get '/ui/*' do |requested_path|
  cleaned_path = Pathname.new(requested_path).cleanpath.to_s
  halt 403 if cleaned_path.start_with?('/') || cleaned_path.start_with?('..')

  relative_ui_file = File.join('.', 'ui', cleaned_path)
  halt 404 unless File.file?(relative_ui_file)

  case File.extname(relative_ui_file)
  when '.html'
    content_type :html
  when '.css'
    content_type :css
  when '.js'
    content_type 'application/javascript'
  else
    content_type 'application/octet-stream'
  end

  File.binread(relative_ui_file)
end

# Home page
get '/' do
  erb :index
end

get '/indsamling' do
  erb :indsamling
end

post '/opret' do
  puts params.inspect
  "Kampagnen '#{params[:titel]}' er modtaget!"
end


