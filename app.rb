require 'sinatra'
require 'sinatra/contrib'
require 'sequel'
require 'dotenv/load'
require 'sqlite3'
require 'bcrypt' # Til sikker opbevaring af adgangskoder

# Database setup
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

#login page
get '/auth' do
  erb :auth
end

post '/login' do
  bruger = db.execute("SELECT * FROM brugere WHERE navn = ?", params[:brugernavn]).first
  if bruger && BCrypt::Password.new(bruger["kode"]) == params[:kode]
    session[:user_id] = bruger["id"]
    redirect '/'
  else
    @login_error = "Forkert brugernavn eller kode."
    erb :auth # Gå tilbage til den samlede side
  end
end

post '/signup' do
  hashed_kode = BCrypt::Password.create(params[:kode])
  begin
    db.execute("INSERT INTO brugere (navn, kode) VALUES (?, ?)", [params[:brugernavn], hashed_kode])
    # Log dem ind med det samme efter oprettelse
    ny_bruger = db.execute("SELECT id FROM brugere WHERE navn = ?", params[:brugernavn]).first
    session[:user_id] = ny_bruger["id"]
    redirect '/'
  rescue
    @signup_error = "Dette navn er allerede optaget."
    erb :auth
  end
end