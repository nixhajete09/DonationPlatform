# frozen_string_literal: true

# Profile routes
get '/login' do
  redirect '/profile'
end

get '/profile' do
  @profile_name = 'Nixhajete Bruger'
  @profile_email = 'bruger@example.com'
  @total_donated = 1450
  @tax_deduction_total = 1100

  @donation_history = [
    { campaign: 'Støt kræftramte', amount: 250, date: '2026-03-20', tax_deduction: true },
    { campaign: 'Plant træer', amount: 400, date: '2026-03-18', tax_deduction: true },
    { campaign: 'Dyreværn i kulden', amount: 800, date: '2026-03-12', tax_deduction: false }
  ]

  erb :profile
end
