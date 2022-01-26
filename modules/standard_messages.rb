# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to processing all standard messages
    module StandardMessages
      STATES = %w[begin filled_name filled_date confirmed].freeze
      def process
        @user_id = Listener.message.from.id
        State.save({ user_id: @user_id, name: nil, date: nil, state: STATES[3] }) if State.check_state(@user_id).empty?

        if State.check_state(@user_id)[:state] != STATES[3]
          set_birthday
        else
          case Listener.message.text
          when '/start'
            start
          when '/get_birthdays'
            birthdays
          when '/set_birthday'
            set_birthday
          when '/stop'
            Response.std_message 'Пока!'
            exit(1)
          when '/state'
            Response.std_message State.check_state(@user_id)
          else
            plug_message
          end
        end
      end

      def start
        Response.inline_message 'Привет, выбери из доступных действий', Response.generate_inline_markup(
          [
            InlineButton::GET_BIRTHDAY,
            InlineButton::SET_BIRTHDAY
          ]
        )
      end

      def set_birthday(user_id = @user_id)
        pp State.check_state(user_id)
        state = State.check_state(user_id).empty? ? nil : State.check_state(user_id)[:state]
        print "#{state} : state}\n"

        case state
        when STATES[3]
          State.replace({ user_id: user_id, name: nil, date: nil, state: STATES[0] })
          Response.std_message 'Сообщи мене имя именинника'
        when STATES[0]
          State.replace({ user_id: user_id, name: Listener.message.text, date: nil, state: STATES[1] })
          Response.std_message 'Сообщи мене дату в формате дд/мм/гггг'
        when STATES[1]
          data = { user_id: user_id, name: State.check_state(user_id)[:name], date: Listener.message.text, state: STATES[2] }
          State.replace(data)
          Response.std_message "Got: #{data}\nSaving?"
        when STATES[2]
          data = State.check_state(user_id)
          Database.save(user_id: user_id, name: data[:name], date: data[:date])
          Response.std_message 'Saved!'
          State.replace({ user_id: user_id, name: data[:name], date: data[:date], state: STATES[3] })
        else
          Response.std_message 'invalid answer'
        end
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
