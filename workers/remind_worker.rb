# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-scheduler'
require 'telegram/bot'
require_relative '../lib/database'
require_relative '../lib/keys'
require_relative 'config/config'


# sends reminding messages
class RemindWorker
  include Sidekiq::Worker

  def perform
    Database.setup('../lib/development.db')

    # Listener::Response.std_message
    Telegram::Bot::Client.run(TelegramOrientedInfo::API_KEY) do |bot|
      Database.ids.each do |user_id|
        user_records = Database.select(user_id)
        bot.api.send_message(
          parse_mode: 'html',
          chat_id: 276510840,
          text: user_records
        )
      end
    end

  end
end
