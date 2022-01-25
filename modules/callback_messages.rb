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
          Listener::Response.std_message('Нету записей(')
        end
      end

      module_function(
        :process,
        :callback_message,
        :callback_message=
      )
    end
  end
end
