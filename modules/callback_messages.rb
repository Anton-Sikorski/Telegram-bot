# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to processing all callback messages
    module CallbackMessages
      attr_accessor :callback_message

      def process
        self.callback_message = Listener.message.message
        case Listener.message.data
        when 'birthday'
          birthdays
        when 'set_birthday'
          Listener::AddBirthday.set_birthday
        when 'reset'
          State.replace({ user_id: Listener.message.from.id, name: nil, date: nil,
                          state: 'confirmed' })
          Response.delete_message(message_id)
          StandardMessages.start
        when 'save_data'
          save_data
          StandardMessages.start
        when 'check_dates'
          check_dates
        when 'edit_record'
          edit_record
        end
      end

      def birthdays
        data = Database.select(Listener.message.from.id)
        if data.empty?
          Listener::Response.std_message('Вы пока не добавили ни одной записи!')
        else
          answer = String.new
          data.sort { |a, b| time_diff(a[2]) <=> time_diff(b[2]) }.each do |record|
            answer += "День рождения #{record[1]} - #{record[2]}.\n"
          end
          Listener::Response.std_message "Все записи: \n#{answer}"
        end
      end

      def save_data(user_id = Listener.message.from.id)
        data = State.check_state(user_id)
        # save data into main database
        puts data
        Database.save(user_id: user_id, name: data[:name], date: data[:date])
        Response.std_message 'Успех!'
        # resetting status of user
        State.replace({ user_id: user_id, name: nil, date: nil, state: 'confirmed' })
        Response.delete_message(message_id)
      end

      def message_id
        Listener.message.message.message_id
      end

      def check_dates
        user_id = Listener.message.from.id
        user_data = Database.select(user_id).map { |record| { id: user_id, name: record[1], date: record[2] } }

        if user_data.empty?
          Listener::Response.std_message('Вы пока не добавили ни одной записи!')
        else
          answer = String.new
          user_data.sort { |a, b| time_diff(a[:date]) <=> time_diff(b[:date]) }.map do |record|
            days_left = time_diff(record[:date])
            answer += "У #{record[:name]} через #{days_left} дней День Рождения!\n"
          end
          Listener::Response.std_message answer
        end
      end

      def time_diff(date)
        days = (Date.parse(date.gsub(/\d{4}/, '2022')) - Date.parse(Time.now.to_s)).to_i
        days.negative? ? 365 + days.to_i : days
      end

      module_function(
        :process,
        :save_data,
        :message_id,
        :birthdays,
        :check_dates,
        :time_diff,
        :callback_message,
        :callback_message=
      )
    end
  end
end
