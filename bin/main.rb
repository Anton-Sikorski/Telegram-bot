# frozen_string_literal: true

require 'telegram/bot'
require 'petrovich'
require_relative '../lib/keys'
require_relative '../lib/state'
require_relative '../lib/users'
require_relative '../lib/database'
require_relative '../workers/remind_worker'
require_relative '../modules/listener'
require_relative '../modules/response'
require_relative '../modules/security'
require_relative '../modules/standard_messages'
require_relative '../modules/callback_messages'
require_relative '../modules/dialogues/birthdays'
require_relative '../modules/dialogues/edit_record'
require_relative '../modules/dialogues/add_birthday'
require_relative '../modules/dialogues/notifications'
require_relative '../modules/assets/inline_button'
require_relative '../modules/assets/keyboard_button'

# basic class of the app
class BirthdayBot
  include Database
  include State
  include Users

  def initialize
    super
    # Initialize BD
    State.setup
    Users.setup
    Database.setup
    # Establishing webhook via @gem telegram/bot, using API-KEY
    loop do
      listen
    rescue Faraday::ConnectionFailed
      puts "#{Time.now}) Connection failed"
      retry
    end
  end

  def listen
    Telegram::Bot::Client.run(TelegramOrientedInfo::API_KEY) do |bot|
      # Start time variable, for exclude message what was sends before bot starts
      start_bot_time = Time.now.to_i

      # Active socket listener
      bot.listen do |rqst|
        Thread.start(rqst) do |message|
          # Processing the new income message    #if that message sent after bot run.
          Listener.catch_new_message(message, bot) if Listener::Security.message_is_new(start_bot_time, message)
        rescue Telegram::Bot::Exceptions::ResponseError => e
          puts "#{Time.now.strftime '%d%m %H%M%S'}) Telegram response error \n#{e}"
        end
      end
    end
  end
end

BirthdayBot.new
