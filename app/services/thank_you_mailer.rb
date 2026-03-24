require 'fileutils'
require 'logger'
require 'net/smtp'

class ThankYouMailer
  def initialize(logger: Logger.new($stdout))
    @logger = logger
  end

  def tier_for(amount)
    value = amount.to_f
    return :basic if value < 200
    return :personal if value <= 1000

    :premium
  end

  def send_tiered_thank_you(recipient_email:, donor_name:, amount:, campaign_title:, collected:, goal:)
    tier = tier_for(amount)
    subject = "Tak for din donation til #{campaign_title}"
    body = build_body(
      tier: tier,
      donor_name: donor_name,
      amount: amount,
      campaign_title: campaign_title,
      collected: collected,
      goal: goal
    )

    if smtp_configured?
      send_via_smtp(to: recipient_email, subject: subject, body: body)
      return { sent: true, mode: 'smtp', tier: tier }
    end

    simulate_delivery(to: recipient_email, subject: subject, body: body)
    { sent: true, mode: 'simulated', tier: tier }
  rescue StandardError => e
    @logger.error("ThankYouMailer error: #{e.message}")
    { sent: false, mode: 'failed', tier: tier, error: e.message }
  end

  private

  def smtp_configured?
    ENV['SMTP_ADDRESS'] && ENV['MAIL_FROM']
  end

  def build_body(tier:, donor_name:, amount:, campaign_title:, collected:, goal:)
    greeting_name = donor_name.to_s.strip.empty? ? 'dig' : donor_name

    tier_message = case tier
                   when :basic
                     'Tusind tak for din stotte. Din donation gor en forskel.'
                   when :personal
                     'Tusind tak for din store stotte. Her er en personlig tak og en kort kampagneopdatering.'
                   else
                     'Tusind tak for dit meget store bidrag. Vi folger op med en dedikeret besked.'
                   end

    <<~BODY
      Hej #{greeting_name},

      #{tier_message}

      Donation: #{amount.to_i} kr
      Kampagne: #{campaign_title}
      Fremgang: #{collected.to_i} kr af #{goal.to_i} kr

      Venlig hilsen
      Danmarks Donation
    BODY
  end

  def send_via_smtp(to:, subject:, body:)
    from = ENV.fetch('MAIL_FROM')
    address = ENV.fetch('SMTP_ADDRESS')
    port = ENV.fetch('SMTP_PORT', '587').to_i
    username = ENV['SMTP_USERNAME']
    password = ENV['SMTP_PASSWORD']

    message = <<~MAIL
      From: Danmarks Donation <#{from}>
      To: <#{to}>
      Subject: #{subject}
      MIME-Version: 1.0
      Content-Type: text/plain; charset=UTF-8

      #{body}
    MAIL

    if username.to_s.empty?
      Net::SMTP.start(address, port) { |smtp| smtp.send_message(message, from, to) }
    else
      Net::SMTP.start(address, port, 'localhost', username, password, :plain) do |smtp|
        smtp.send_message(message, from, to)
      end
    end
  end

  def simulate_delivery(to:, subject:, body:)
    FileUtils.mkdir_p('tmp')
    File.open('tmp/sent_emails.log', 'a') do |file|
      file.puts("--- #{Time.now.utc} ---")
      file.puts("TO: #{to}")
      file.puts("SUBJECT: #{subject}")
      file.puts(body)
      file.puts
    end
  end
end
