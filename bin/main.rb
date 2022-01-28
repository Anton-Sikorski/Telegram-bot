# frozen_string_literal: true

require 'telegram/bot'
require './lib/keys'
require './lib/state'
require './lib/database'
require './modules/listener'
require './modules/response'
require './modules/security'
require './modules/add_birthday'
require './workers/remind_worker'
require './modules/standard_messages'
require './modules/callback_messages'
require './modules/assets/inline_button'
require './modules/assets/keyboard_button'

# basic class of the app
class BirthdayBot
  include Database
  include State

  def initialize
    super
    # Initialize BD
    State.setup
    Database.setup
    # Establishing webhook via @gem telegram/bot, using API-KEY
    begin
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

BirthdayBot.new
