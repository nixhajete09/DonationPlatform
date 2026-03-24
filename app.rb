# frozen_string_literal: true

require 'sinatra'
require 'sinatra/contrib'
require 'sequel'
require 'dotenv/load'
require 'date'
require 'uri'
require 'pathname'
require 'bcrypt'
require 'sqlite3'

Dir.chdir(File.dirname(__FILE__))

# Database setup
DB = Sequel.connect('sqlite://db/donation_platform.db')

unless DB.table_exists?(:campaigns)
  DB.create_table :campaigns do
    primary_key :id
    String :title, null: false
    String :description, text: true, null: false
    Integer :goal, null: false
    Date :deadline
    String :category, null: false
    String :image_url
    DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  end
end

unless DB.table_exists?(:donations)
  DB.create_table :donations do
    primary_key :id
    foreign_key :campaign_id, :campaigns, null: false, on_delete: :cascade
    String :donor_name
    String :donor_email
    Integer :amount, null: false
    TrueClass :anonymous, default: false
    TrueClass :tax_deduction, default: false
    String :cpr
    DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  end
end

# Models directory
require_relative 'app/models/campaign'
require_relative 'app/models/donation'
require_relative 'app/models/user'
require_relative 'app/services/thank_you_mailer'

# Routes
Dir.glob('app/routes/*.rb').sort.each { |file| require_relative file }

configure do
  set :public_folder, 'public'
  set :views, 'app/views'
end

helpers do
  def homepage_categories
    %w[Alle Klima Dyr Sundhed Lokalt]
  end

  def normalized_selected_category(raw_category)
    category = raw_category.to_s.strip
    category.empty? ? 'Alle' : category
  end

  def filter_campaigns(campaigns, selected_category:, query:)
    filtered_campaigns = campaigns

    filtered_campaigns = filtered_campaigns.select { |campaign| campaign.category == selected_category } if selected_category != 'Alle'

    search_query = query.to_s.strip.downcase
    return filtered_campaigns if search_query.empty?

    filtered_campaigns.select do |campaign|
      [campaign.title, campaign.description, campaign.category].any? do |value|
        value.to_s.downcase.include?(search_query)
      end
    end
  end

  def campaign_form_redirect_url(error:, title:, description:, goal:, category:, image_url:)
    query = URI.encode_www_form(
      error: error,
      title: title,
      description: description,
      goal: goal,
      category: category,
      image_url: image_url
    )

    "/campaigns/new?#{query}"
  end

  def default_featured_campaigns
    [
      Campaign.new(
        id: 1,
        title: 'Støt kræftramte',
        description: 'Hjælp familier med behandling og praktisk støtte i hverdagen.',
        goal: 10_000,
        deadline: Date.today + 30,
        category: 'Sundhed',
        image_url: 'https://picsum.photos/seed/kraeft/800/450'
      ),
      Campaign.new(
        id: 2,
        title: 'Plant træer',
        description: 'Sammen planter vi nye træer i udsatte områder i Danmark.',
        goal: 10_000,
        deadline: Date.today + 45,
        category: 'Klima',
        image_url: 'https://picsum.photos/seed/traeer/800/450'
      ),
      Campaign.new(
        id: 3,
        title: 'Dyreværn i kulden',
        description: 'Støt midlertidige ophold og foder til hjemløse kæledyr.',
        goal: 15_000,
        deadline: Date.today + 20,
        category: 'Dyr',
        image_url: 'https://picsum.photos/seed/dyrevaern/800/450'
      ),
      Campaign.new(
        id: 4,
        title: 'Mad til familier i krise',
        description: 'Hjælp med madposer og hverdagsvarer til pressede familier.',
        goal: 20_000,
        deadline: Date.today + 25,
        category: 'Lokalt',
        image_url: 'https://picsum.photos/seed/madkasse/800/450'
      ),
      Campaign.new(
        id: 5,
        title: 'Akut hjælp til psykisk trivsel',
        description: 'Støt gratis samtaler og rådgivning til unge i mistrivsel.',
        goal: 18_000,
        deadline: Date.today + 40,
        category: 'Sundhed',
        image_url: 'https://picsum.photos/seed/trivsel/800/450'
      ),
      Campaign.new(
        id: 6,
        title: 'Rent vand til landsbyer',
        description: 'Bidrag til brønde, filtre og vandtanke i udsatte områder.',
        goal: 30_000,
        deadline: Date.today + 55,
        category: 'Klima',
        image_url: 'https://picsum.photos/seed/vand/800/450'
      ),
      Campaign.new(
        id: 7,
        title: 'Nødfond for dyrlægehjælp',
        description: 'Hjælp skadede dyr med behandling, medicin og transport.',
        goal: 22_000,
        deadline: Date.today + 35,
        category: 'Dyr',
        image_url: 'https://picsum.photos/seed/dyrlaege/800/450'
      ),
      Campaign.new(
        id: 8,
        title: 'Skoleudstyr til børn',
        description: 'Støt skoletasker, bøger og udstyr til børn uden ressourcer.',
        goal: 16_000,
        deadline: Date.today + 28,
        category: 'Lokalt',
        image_url: 'https://picsum.photos/seed/skole/800/450'
      ),
      Campaign.new(
        id: 9,
        title: 'Grønne byhaver',
        description: 'Skab lokale byhaver med fællesskab, læring og biodiversitet.',
        goal: 12_000,
        deadline: Date.today + 50,
        category: 'Klima',
        image_url: 'https://picsum.photos/seed/byhave/800/450'
      ),
      Campaign.new(
        id: 10,
        title: 'Hospice støttefond',
        description: 'Giv ro og omsorg til patienter og familier i svære perioder.',
        goal: 25_000,
        deadline: Date.today + 32,
        category: 'Sundhed',
        image_url: 'https://picsum.photos/seed/hospice/800/450'
      ),
      Campaign.new(
        id: 11,
        title: 'Vinterly til hjemløse',
        description: 'Finansier varme tæpper, soveposer og varme måltider.',
        goal: 27_000,
        deadline: Date.today + 18,
        category: 'Lokalt',
        image_url: 'https://picsum.photos/seed/hjemloese/800/450'
      ),
      Campaign.new(
        id: 12,
        title: 'Red havmiljøet nu',
        description: 'Støt strandrensning og fjernelse af plastik i kystområder.',
        goal: 21_000,
        deadline: Date.today + 60,
        category: 'Klima',
        image_url: 'https://picsum.photos/seed/havmiljoe/800/450'
      )
    ]
  end

  def seed_default_campaigns_if_needed
    return unless DB.table_exists?(:campaigns)

    existing_campaigns = DB[:campaigns].select(:id, :title, :image_url).all
    existing_by_title = existing_campaigns.each_with_object({}) do |row, hash|
      hash[row[:title]] = row
    end

    default_featured_campaigns.each do |campaign|
      existing = existing_by_title[campaign.title]

      if existing
        DB[:campaigns].where(id: existing[:id]).update(image_url: campaign.image_url) if existing[:image_url].to_s.strip.empty? && !campaign.image_url.to_s.strip.empty?
        next
      end

      DB[:campaigns].insert(
        title: campaign.title,
        description: campaign.description,
        goal: campaign.goal,
        deadline: campaign.deadline,
        category: campaign.category,
        image_url: campaign.image_url,
        created_at: Time.now
      )
    end
  rescue Sequel::Error
    nil
  end

  def featured_campaigns
    return default_featured_campaigns unless DB.table_exists?(:campaigns)

    seed_default_campaigns_if_needed

    campaigns = DB[:campaigns]
                .reverse_order(:created_at)
                .limit(24)
                .all
                .map do |row|
                  Campaign.new(
                    id: row[:id],
                    title: row[:title] || 'Uden titel',
                    description: row[:description] || 'Beskrivelse kommer snart.',
                    goal: row[:goal].to_i,
                    deadline: row[:deadline],
                    category: row[:category] || 'Andet',
                    image_url: row[:image_url],
                    created_at: row[:created_at]
                  )
                end

    campaigns.empty? ? default_featured_campaigns : campaigns
  rescue Sequel::Error
    default_featured_campaigns
  end

  def example_collected_amount(goal)
    return 0 if goal.to_i <= 0

    (goal.to_i * 0.55).to_i
  end

  def collected_amount_for_campaign(campaign)
    base = example_collected_amount(campaign.goal)
    return base unless DB.table_exists?(:donations)

    donated = DB[:donations].where(campaign_id: campaign.id.to_i).sum(:amount).to_i
    base + donated
  rescue Sequel::Error
    base
  end

  def progress_percentage(collected, goal)
    return 0 if goal.to_i <= 0

    percentage = (collected.to_f / goal) * 100
    [[percentage.round, 0].max, 100].min
  end

  def find_campaign_by_id(campaign_id)
    id = campaign_id.to_i
    return nil if id <= 0

    if DB.table_exists?(:campaigns)
      row = DB[:campaigns].where(id: id).first
      return nil unless row

      return Campaign.new(
        id: row[:id],
        title: row[:title] || 'Uden titel',
        description: row[:description] || 'Beskrivelse kommer snart.',
        goal: row[:goal].to_i,
        deadline: row[:deadline],
        category: row[:category] || 'Andet',
        image_url: row[:image_url],
        created_at: row[:created_at]
      )
    end

    featured_campaigns.find { |campaign| campaign.id.to_i == id }
  rescue Sequel::Error
    featured_campaigns.find { |campaign| campaign.id.to_i == id }
  end
get '/ui' do
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
  @selected_category = normalized_selected_category(params[:category])
  @query = params[:q].to_s.strip

  @categories = homepage_categories
  @featured_campaigns = filter_campaigns(
    featured_campaigns,
    selected_category: @selected_category,
    query: @query
  )
  erb :index
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