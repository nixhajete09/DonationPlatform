# Campaigns routes
get '/campaigns' do
  # TODO: Fetch campaigns from database
  erb :'campaigns/index'
end

get '/campaigns/:id' do
  # TODO: Fetch specific campaign
  erb :'campaigns/show'
end

post '/campaigns' do
  # TODO: Create new campaign
  redirect '/campaigns'
end
