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
          # Listener::Response.std_message('Нету записей(')
        when 'set_birthday'
          Listener::StandardMessages.set_birthday
        when 'reset'
          State.replace({ user_id: Listener.message.from.id, name: nil, date: nil, state: STATES[0] })
        when 'save_data'
          save_data
        end
      end

      def birthday
        data = Database.select(Listener.message.from.id)
        if data.empty?
          Listener::Response.std_message('Вы пока не добавили ни одной записи!')
        else
          answer = String.new
          data.each do |record|
            answer += "День рождения #{record[1]} #{record[2]} числа.\n"
          end
          Listener::Response.std_message "Все записи: \n#{answer}"
        end
      end

      def save_data(user_id = Listener.message.from.id)
        data = State.check_state(user_id)
        Database.save(user_id: user_id, name: data[:name], date: data[:date])
        Response.std_message 'Успех!'
        State.replace({ user_id: user_id, name: data[:name], date: data[:date], state: StandardMessages::STATES[3] })
        Response.delete_message(message_id)
      end

      def chat_id
        Listener.message.message.chat.id
      end

      def message_id
        Listener.message.message.message_id
      end


      module_function(
        :process,
        :save_data,
        :chat_id,
        :message_id,
        :birthday,
        :callback_message,
        :callback_message=
      )
    end
  end
end
