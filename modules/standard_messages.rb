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
        when '/set_birthday'
          set_birthday
        when 'name'
          Response.std_message Listener.message.from.id
        when '/stop'
          Response.std_message 'Bye!'
          exit(1)
        else
          plug_message
        end
      end

      def start
        Response.inline_message 'Привет, выбери из доступных действий', Response.generate_inline_markup(
          [
            InlineButton::GET_BIRTHDAY
          ]
        )
      end

      def set_birthday
        Response.std_message 'Введите данные в формате: имя дд/мм/год'
        Database.save({ user_id: Listener.message.from.id, date: '21/03/2000', name: 'Anton' })
      end

      def birthdays
        Response.std_message 'Вы ещё не добавили не одной записи!'
      end

      def plug_message
        Response.std_message 'Первый раз такое слышу, попробуй сказать что-то другое!'
      end


      module_function(
        :process,
        :birthdays,
        :plug_message,
        :set_birthday,
        :start
      )
    end
  end
end
