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

    Telegram::Bot::Client.run(TelegramOrientedInfo::API_KEY) do |_bot|
      users.each do |user_id|
        user_data = Database.select(user_id).map { |record| { id: user_id, name: record[1], date: record[2] } }
        answer = user_data.map do |record|
          days_left = diff(record[:date])
          respond(record[:name], days_left)
        end.compact.join('\n')

        next if answer.empty?

        bot.api.send_message(
          parse_mode: 'html',
          chat_id: user_id,
          text: answer
        )
      end
    end
  end

  def respond(name, days)
    case days
    when 30
      "У #{name} через #{days} дней День Рождения!"
    when 7, 14, 21
      "До Дня Рождения #{name} осталось #{days} дней !"
    when 2..7
      "Уже через #{days} дня у #{name} День Рождения!"
    when 1
      "День Рождения #{name} уже завтра!!!"
    end
  end

  def diff(date)
    (Date.parse(date.gsub(/\d{4}/, '2022')) - Date.parse(Time.now.to_s)).to_i
  end
end
