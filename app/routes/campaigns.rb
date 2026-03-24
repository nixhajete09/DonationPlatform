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
  @donation_email_status = params[:email_status]
  @donation_tier = params[:tier]
  @tax_deduction_selected = params[:tax] == '1'
  erb :'campaigns/show'
end

post '/campaigns/:id/donations' do
  campaign = find_campaign_by_id(params[:id])
  halt 404, 'Kampagne ikke fundet' unless campaign

  amount = params[:amount].to_s.strip
  amount_value = amount.to_f
  donor_name = params[:donor_name].to_s.strip
  donor_email = params[:donor_email].to_s.strip
  wants_tax_deduction = params[:tax_deduction] == '1'
  cpr_digits = params[:cpr].to_s.gsub(/\D/, '')

  if amount.empty? || amount_value <= 0
    redirect "/campaigns/#{campaign.id}?status=error&error=Indtast+et+gyldigt+bel%C3%B8b"
  end

  if wants_tax_deduction && cpr_digits.length != 10
    redirect "/campaigns/#{campaign.id}?status=error&error=CPR+skal+v%C3%A6re+10+cifre+for+skattefradrag&tax=1"
  end

  email_status = 'none'
  tier = ThankYouMailer.new.tier_for(amount_value).to_s

  unless donor_email.empty?
    unless donor_email.match?(/\A[^\s@]+@[^\s@]+\.[^\s@]+\z/)
      redirect "/campaigns/#{campaign.id}?status=error&error=Indtast+en+gyldig+email+eller+lad+feltet+v%C3%A6re+tomt"
    end

    collected_after = example_collected_amount(campaign.goal) + amount_value
    email_result = ThankYouMailer.new.send_tiered_thank_you(
      recipient_email: donor_email,
      donor_name: donor_name,
      amount: amount_value,
      campaign_title: campaign.title,
      collected: collected_after,
      goal: campaign.goal
    )

    email_status = email_result[:sent] ? email_result[:mode] : 'failed'
    tier = email_result[:tier].to_s
  end

  tax_flag = wants_tax_deduction ? '&tax=1' : ''
  redirect "/campaigns/#{campaign.id}?status=success&amount=#{amount_value.to_i}&email_status=#{email_status}&tier=#{tier}#{tax_flag}"
end

post '/campaigns' do
  # TODO: Create new campaign
  redirect '/campaigns'
end
