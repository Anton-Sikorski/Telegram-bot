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
          birthday
        when 'set_birthday'
          Listener::StandardMessages.set_birthday
        when 'reset'
          State.replace({ user_id: Listener.message.from.id, name: nil, date: nil, state: StandardMessages::STATES[3] })
          Response.delete_message(message_id)
        when 'save_data'
          save_data
        when 'check_dates'
          user_id = Listener.message.from.id
          user_data = Database.select(user_id).map { |record| { id: user_id, name: record[1], date: record[2] } }
          if user_data.empty?
            Listener::Response.std_message('Вы пока не добавили ни одной записи!')
          else
            answer = ''
            user_data.map do |record|
              record[:date] = record[:date].gsub('.', '/')
              answer += "У #{record[:name]} через #{(Date.parse(record[:date].gsub(/\d{4}/, '2022')) - Date.parse(Time.now.to_s)).to_i} дней День Рождения!\n"
            end
            Listener::Response.std_message answer
          end
        end
      end

      def birthday
        data = Database.select(Listener.message.from.id)
        if data.empty?
          Listener::Response.std_message('Вы пока не добавили ни одной записи!')
        else
          answer = String.new
          data.each do |record|
            answer += "День рождения #{record[1]} - #{record[2]}.\n"
          end
          Listener::Response.std_message "Все записи: \n#{answer}"
        end
      end

      def save_data(user_id = Listener.message.from.id)
        data = State.check_state(user_id)
        # save data into main database
        Database.save(user_id: user_id, name: data[:name], date: data[:date])
        Response.std_message 'Успех!'
        # resetting status of user
        State.replace({ user_id: user_id, name: nil, date: nil, state: StandardMessages::STATES[3] })
        Response.delete_message(message_id)
      end

      def message_id
        Listener.message.message.message_id
      end

      module_function(
        :process,
        :save_data,
        :message_id,
        :birthday,
        :callback_message,
        :callback_message=
      )
    end
  end
end
