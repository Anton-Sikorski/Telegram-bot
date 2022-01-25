require 'telegram/bot'
require '../lib/keys'

class BirthdayBot
  include Database
  def initialize
    super
    # Initialize BD
    Database.setup
    # Establishing webhook via @gem telegram/bot, using API-KEY
    begin
      retries ||= 0
      listen
    rescue Faraday::ConnectionFailed
      puts 'Retrying...'
      retry
    end
  end

  def listen
    Telegram::Bot::Client.run(TelegramOrientedInfo::API_KEY) do |bot|
      # Start time variable, for exclude message what was sends before bot starts
      start_bot_time = Time.now.to_i
      # Active socket listener
      bot.listen do |message|
        # Processing the new income message    #if that message sent after bot run.
        Listener.catch_new_message(message, bot) if Listener::Security.message_is_new(start_bot_time, message)
      end
    end
  end
end
