# Campaigns routes
get '/campaigns' do
  @query = params[:q].to_s.strip
  campaigns = featured_campaigns

  unless @query.empty?
    search = @query.downcase
    campaigns = campaigns.select do |campaign|
      [campaign.title, campaign.description, campaign.category].any? do |value|
        value.to_s.downcase.include?(search)
      end
    end
  end

  @campaigns = campaigns
  erb :'campaigns/index'
end

get '/campaigns/:id' do
  @campaign = find_campaign_by_id(params[:id])
  halt 404, 'Kampagne ikke fundet' unless @campaign

  @collected = example_collected_amount(@campaign.goal)
  @progress = progress_percentage(@collected, @campaign.goal)
  @donation_status = params[:status]
  @donation_amount = params[:amount]
  @donation_error = params[:error]
  @tax_deduction_selected = params[:tax] == '1'
  erb :'campaigns/show'
end

post '/campaigns/:id/donations' do
  campaign = find_campaign_by_id(params[:id])
  halt 404, 'Kampagne ikke fundet' unless campaign

  amount = params[:amount].to_s.strip
  amount_value = amount.to_f
  wants_tax_deduction = params[:tax_deduction] == '1'
  cpr_digits = params[:cpr].to_s.gsub(/\D/, '')

  if amount.empty? || amount_value <= 0
    redirect "/campaigns/#{campaign.id}?status=error&error=Indtast+et+gyldigt+beloeb"
  end

  if wants_tax_deduction && cpr_digits.length != 10
    redirect "/campaigns/#{campaign.id}?status=error&error=CPR+skal+vaere+10+cifre+for+skattefradrag&tax=1"
  end

  tax_flag = wants_tax_deduction ? '&tax=1' : ''
  redirect "/campaigns/#{campaign.id}?status=success&amount=#{amount_value.to_i}#{tax_flag}"
end

post '/campaigns' do
  # TODO: Create new campaign
  redirect '/campaigns'
end
