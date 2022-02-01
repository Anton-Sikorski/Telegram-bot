# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-scheduler'
require 'telegram/bot'
require_relative '../lib/database'
require_relative '../lib/keys'
require_relative 'config/config'
require_relative '../lib/users'

# sends reminding messages
class RemindWorker
  include Sidekiq::Worker

  def perform
    Database.setup('../lib/development.db')
    Users.setup('../lib/development.db')
    users = Database.ids
    users.each { |user_id| Users.save(user_id) } if Users.select_all.empty?
    notifications = Users.select_all

    Telegram::Bot::Client.run(TelegramOrientedInfo::API_KEY) do |bot|
      users.each do |user_id|
        next unless notifications[user_id]

        user_data = Database.select(user_id).map { |record| { id: user_id, name: record[1], date: record[2] } }
        answer = user_data.map { |record| respond(record[:name], time_diff(record[:date])) }.compact.join('\n')
        next if answer.empty?

        bot.api.send_message(
          parse_mode: 'html',
          chat_id: user_id,
          text: answer
        )
      end
      puts "Success. Data sent at #{Time.now.strftime '%d-%m-%y %H%M'}"
    end
  end

  def respond(name, days)
    case days
    when 30
      "У #{name} через #{days} дней День Рождения!"
    when 7, 14, 21
      "До Дня Рождения #{name} осталось #{days} дней !"
    when 5..7
      "Уже через #{days} дней у #{name} День Рождения!"
    when 2..5
      "Уже через #{days} дня у #{name} День Рождения!"
    when 1
      "День Рождения #{name} уже завтра!!!"
    end
  end

  def time_diff(date)
    days = (Date.parse(date.gsub(/\d{4}/, '2022')) - Date.parse(Time.now.to_s)).to_i
    days.negative? ? 365 + days.to_i : days
  end
end
