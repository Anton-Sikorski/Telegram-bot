# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to processing all standard messages
    module StandardMessages
      def process
        case Listener.message.text
        when '/start'
          start
        when '/get_birthdays'
          birthdays
        else
          return plug_message if Listener.message.reply_to_message.nil?


        end
      end

      private

      def start
        Response.inline_message 'Привет, выбери из доступных действий', Response.generate_inline_markup(
          [
            InlineButton::GET_BIRTHDAY
          ]
        )
      end

      def birthdays
        Response.std_message 'Вы ещё не добавили не одной записи!'
      end

      def plug_message
        Response.std_message 'Первый раз такое слышу, попробуй сказать что-то другое!'
      end

      module_function(
        :process
      )
    end
  end
end
