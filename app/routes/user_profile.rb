# frozen_string_literal: true

get '/profile' do
  user_id = session[:user_id].to_i
  redirect '/auth' if user_id <= 0

  user = DB[:brugere].where(id: user_id).first
  redirect '/auth' unless user

  @profile_handle = user[:navn].to_s.split('@').first
  @total_donated = 0
  @tax_deduction_total = 0

  @owned_campaigns = DB[:campaigns]
                     .where(user_id: user_id)
                     .reverse_order(:created_at)
                     .all

  erb :user_profile
end
