require 'sinatra'
require 'sinatra/contrib'
require 'sequel'
require 'dotenv/load'
require 'date'

# Database setup
DB = Sequel.connect('sqlite://db/donation_platform.db')

# Models directory
require_relative 'app/models/campaign'
require_relative 'app/models/donation'
require_relative 'app/models/user'
require_relative 'app/services/thank_you_mailer'

# Routes
Dir.glob('app/routes/*.rb').each { |file| require_relative file }

configure do
  set :public_folder, 'public'
  set :views, 'app/views'
end

helpers do
  def homepage_categories
    %w[Alle Klima Dyr Sundhed Lokalt]
  end

  def default_featured_campaigns
    [
      Campaign.new(
        id: 1,
        title: 'Støt kræftramte',
        description: 'Hjælp familier med behandling og praktisk støtte i hverdagen.',
        goal: 10_000,
        deadline: Date.today + 30,
        category: 'Sundhed'
      ),
      Campaign.new(
        id: 2,
        title: 'Plant træer',
        description: 'Sammen planter vi nye træer i udsatte områder i Danmark.',
        goal: 10_000,
        deadline: Date.today + 45,
        category: 'Klima'
      ),
      Campaign.new(
        id: 3,
        title: 'Dyreværn i kulden',
        description: 'Støt midlertidige ophold og foder til hjemløse kæledyr.',
        goal: 15_000,
        deadline: Date.today + 20,
        category: 'Dyr'
      ),
      Campaign.new(
        id: 4,
        title: 'Mad til familier i krise',
        description: 'Hjælp med madposer og hverdagsvarer til pressede familier.',
        goal: 20_000,
        deadline: Date.today + 25,
        category: 'Lokalt'
      ),
      Campaign.new(
        id: 5,
        title: 'Akut hjælp til psykisk trivsel',
        description: 'Støt gratis samtaler og rådgivning til unge i mistrivsel.',
        goal: 18_000,
        deadline: Date.today + 40,
        category: 'Sundhed'
      ),
      Campaign.new(
        id: 6,
        title: 'Rent vand til landsbyer',
        description: 'Bidrag til brønde, filtre og vandtanke i udsatte områder.',
        goal: 30_000,
        deadline: Date.today + 55,
        category: 'Klima'
      ),
      Campaign.new(
        id: 7,
        title: 'Nødfond for dyrlægehjælp',
        description: 'Hjælp skadede dyr med behandling, medicin og transport.',
        goal: 22_000,
        deadline: Date.today + 35,
        category: 'Dyr'
      ),
      Campaign.new(
        id: 8,
        title: 'Skoleudstyr til børn',
        description: 'Støt skoletasker, bøger og udstyr til børn uden ressourcer.',
        goal: 16_000,
        deadline: Date.today + 28,
        category: 'Lokalt'
      ),
      Campaign.new(
        id: 9,
        title: 'Grønne byhaver',
        description: 'Skab lokale byhaver med fællesskab, læring og biodiversitet.',
        goal: 12_000,
        deadline: Date.today + 50,
        category: 'Klima'
      ),
      Campaign.new(
        id: 10,
        title: 'Hospice støttefond',
        description: 'Giv ro og omsorg til patienter og familier i svære perioder.',
        goal: 25_000,
        deadline: Date.today + 32,
        category: 'Sundhed'
      ),
      Campaign.new(
        id: 11,
        title: 'Vinterly til hjemløse',
        description: 'Finansier varme tæpper, soveposer og varme måltider.',
        goal: 27_000,
        deadline: Date.today + 18,
        category: 'Lokalt'
      ),
      Campaign.new(
        id: 12,
        title: 'Red havmiljøet nu',
        description: 'Støt strandrensning og fjernelse af plastik i kystområder.',
        goal: 21_000,
        deadline: Date.today + 60,
        category: 'Klima'
      )
    ]
  end

  def featured_campaigns
    return default_featured_campaigns unless DB.table_exists?(:campaigns)

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

  def progress_percentage(collected, goal)
    return 0 if goal.to_i <= 0

    percentage = (collected.to_f / goal.to_f) * 100
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
        created_at: row[:created_at]
      )
    end

    featured_campaigns.find { |campaign| campaign.id.to_i == id }
  rescue Sequel::Error
    featured_campaigns.find { |campaign| campaign.id.to_i == id }
  end
end

# Home page
get '/' do
  @selected_category = params[:category].to_s.strip
  @selected_category = 'Alle' if @selected_category.empty?

  campaigns = featured_campaigns
  campaigns = campaigns.select { |campaign| campaign.category == @selected_category } if @selected_category != 'Alle'

  @categories = homepage_categories
  @featured_campaigns = campaigns
  erb :index
end
