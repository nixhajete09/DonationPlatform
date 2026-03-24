# frozen_string_literal: true

# Auth routes
get '/auth' do
  erb :auth
end

get '/opret' do
  redirect '/auth'
end

post '/login' do
  bruger = DB[:brugere].where(navn: params[:brugernavn]).first

  if bruger && BCrypt::Password.new(bruger[:kode]) == params[:kode]
    session[:user_id] = bruger[:id]
    redirect '/'
  else
    @login_error = 'Forkert brugernavn eller kode.'
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
    @signup_error = 'Dette navn er allerede optaget.'
    erb :auth
  rescue StandardError => e
    @signup_error = "Der skete en fejl: #{e.message}"
    erb :auth
  end
end
