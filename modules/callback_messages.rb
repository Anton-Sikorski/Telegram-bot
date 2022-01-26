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

      module_function(
        :process,
        :birthday,
        :callback_message,
        :callback_message=
      )
    end
  end
end
