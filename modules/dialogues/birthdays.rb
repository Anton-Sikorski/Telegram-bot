# frozen_string_literal: true

class BirthdayBot
  module Listener
    # contains methods to create new record
    module Birthdays
      def birthdays
        data = Database.select(user_id)

        return Listener::Response.std_message('Вы пока не добавили ни одной записи!') if data.empty?

        answer = data.sort { |a, b| time_diff(a[2]) <=> time_diff(b[2]) }.map do |record|
          "День рождения #{record[1]} - #{record[2]}."
        end.join("\n")
        Listener::Response.std_message "Все записи: \n#{answer}"
      end

      def save_data
        data = State.check_state(user_id)
        # save data into main database
        puts data
        Database.save(user_id: user_id, name: data[:name], date: data[:date])
        Response.std_message 'Успех!'
        # resetting status of user
        State.replace({ user_id: user_id, name: nil, date: nil, state: 'confirmed' })
        Response.delete_message(message_id)
        StandardMessages.start
      end

      def check_dates
        user_data = Database.select(user_id).map { |record| { id: user_id, name: record[1], date: record[2] } }

        return Listener::Response.std_message('Вы пока не добавили ни одной записи!') if user_data.empty?

        answer = user_data.sort { |a, b| time_diff(a[:date]) <=> time_diff(b[:date]) }.map do |record|
          "У #{record[:name]} через #{time_diff(record[:date])} дней День Рождения!"
        end.join("\n")

        Listener::Response.std_message answer
      end

      def time_diff(date)
        days = (Date.parse(date.gsub(/\d{4}/, '2022')) - Date.parse(Time.now.to_s)).to_i
        days.negative? ? 365 + days.to_i : days
      end

      def message_id
        Listener.message.message.message_id
      end

      def user_id
        Listener.message.from.id
      end

      module_function(
        :check_dates,
        :message_id,
        :time_diff,
        :save_data,
        :birthdays,
        :user_id
      )
    end
  end
end
