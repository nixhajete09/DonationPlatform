require 'uri'

# Campaigns routes
get '/campaigns' do
  @query = params[:q].to_s.strip
  @selected_category = params[:category].to_s.strip
  @selected_category = 'Alle' if @selected_category.empty?
  @categories = homepage_categories

  campaigns = featured_campaigns

  campaigns = campaigns.select { |campaign| campaign.category == @selected_category } if @selected_category != 'Alle'

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

get '/campaigns/new' do
  @categories = homepage_categories - ['Alle']
  @form_error = params[:error]
  @form_values = {
    title: params[:title].to_s,
    description: params[:description].to_s,
    goal: params[:goal].to_s,
    category: params[:category].to_s,
    image_url: params[:image_url].to_s
  }
  erb :'campaigns/new'
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
  title = params[:title].to_s.strip
  description = params[:description].to_s.strip
  goal = params[:goal].to_s.strip.to_i
  category = params[:category].to_s.strip
  image_url = params[:image_url].to_s.strip

  if title.empty? || description.empty? || goal <= 0 || category.empty?
    redirect "/campaigns/new?error=Udfyld+alle+p%C3%A5kr%C3%A6vede+felter&title=#{URI.encode_www_form_component(title)}&description=#{URI.encode_www_form_component(description)}&goal=#{goal}&category=#{URI.encode_www_form_component(category)}&image_url=#{URI.encode_www_form_component(image_url)}"
  end

  if !image_url.empty? && image_url !~ %r{\Ahttps?://}i
    redirect "/campaigns/new?error=Inds%C3%A6t+et+gyldigt+billedlink+der+starter+med+http+eller+https&title=#{URI.encode_www_form_component(title)}&description=#{URI.encode_www_form_component(description)}&goal=#{goal}&category=#{URI.encode_www_form_component(category)}&image_url=#{URI.encode_www_form_component(image_url)}"
  end

  DB[:campaigns].insert(
    title: title,
    description: description,
    goal: goal,
    deadline: Date.today + 30,
    category: category,
    image_url: image_url,
    created_at: Time.now
  )

  redirect '/campaigns'
end
