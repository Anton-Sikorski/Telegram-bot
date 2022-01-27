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
    users = Database.ids

    Telegram::Bot::Client.run(TelegramOrientedInfo::API_KEY) do |bot|
      users.each do |user_id|
        user_data = Database.select(user_id).map { |record| { id: user_id, name: record[1], date: record[2] } }
        answer = ''
        user_data.map do |record|
          record[:date] = record[:date].gsub('.', '/')
          answer += "У #{record[:name]} через #{diff(record[:date])} дней День Рождения!\n"
        end
        bot.api.send_message(
          parse_mode: 'html',
          chat_id: user_id,
          text: answer
        )
      end
    end
    # user_data = users.map do |user_id|
    #   pp record = Database.select(user_id)
    #   #{ id: user_id, name: record[1], date: record[2] }
    # end

    # users.each do |user_id|
    #   pp user_data #.find_all { |record| record[:id] == user_id }
    # end
  end

  def diff(date)
    (Date.parse(date) - Date.parse(Time.now.to_s)).to_i % 365
  end
end
