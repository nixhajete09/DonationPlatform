require 'sinatra'
require 'sinatra/contrib'
require 'sequel'
require 'dotenv/load'
require 'pathname'
require 'bcrypt'
require 'sqlite3'

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
  default_ui_file = Dir.glob(File.join('.', 'ui', '*.html')).sort.first
  halt 404, 'Ingen HTML-fil fundet i ui-mappen' unless default_ui_file

  redirect "/ui/#{File.basename(default_ui_file)}"
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


#opret/login page 
get '/auth' do
  erb :opret
end

get '/opret' do
  erb :opret
end

post '/login' do
  bruger = DB[:brugere].where(navn: params[:brugernavn]).first
  
  if bruger && BCrypt::Password.new(bruger[:kode]) == params[:kode]
    session[:user_id] = bruger[:id]
    redirect '/'
  else
    @login_error = "Forkert brugernavn eller kode."
    erb :auth
  end
end

post '/signup' do
  hashed_kode = BCrypt::Password.create(params[:kode])
  begin
    # Sequel syntax til at indsætte data
    new_id = DB[:brugere].insert(navn: params[:brugernavn], kode: hashed_kode)
    
    session[:user_id] = new_id
    redirect '/'
  rescue Sequel::UniqueConstraintViolation
    @signup_error = "Dette navn er allerede optaget."
    erb :auth
  rescue => e
    @signup_error = "Der skete en fejl: #{e.message}"
    erb :auth
  end
end
