# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to processing all standard messages
    module StandardMessages
      STATES = %w[begin filled_name filled_date confirmed].freeze

      def process
        @message = Listener.message.text
        @user_id = Listener.message.from.id
        State.save({ user_id: @user_id, name: nil, date: nil, state: STATES[3] }) if State.check_state(@user_id).nil?

        if State.check_state(@user_id)[:state] != STATES[3]
          set_birthday
        else
          case @message
          when '/start'
            start
          when '/stop'
            Response.std_message 'Пока!'
            exit(1)
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

        if @message == '/reset'
          State.replace({ user_id: user_id, name: nil, date: nil, state: STATES[3] })
          return Response.std_message 'Отменяем запись'
        end

        pp State.check_state(user_id)
        state = State.check_state(user_id).empty? ? nil : State.check_state(user_id)[:state]
        print "#{state} : state}\n"


        case state
        when STATES[3]
          State.replace({ user_id: user_id, name: nil, date: nil, state: STATES[0] })
          Response.std_message 'Сообщи мне имя именинника'
        when STATES[0]
          return Response.std_message 'Invalid name' unless @message.match(/\w+/)

          State.replace({ user_id: user_id, name: @message, date: nil, state: STATES[1] })
          Response.std_message 'Сообщи мене дату в формате дд/мм/гггг'
        when STATES[1]
          return Response.std_message 'Invalid date' unless @message.match(%r{\d\d/\d\d/\d\d\d\d})

          data = { user_id: user_id, name: State.check_state(user_id)[:name], date: @message, state: STATES[2] }
          State.replace(data)
          Response.std_message "Got: name - #{data[:name]}, birth date - #{data[:date]}\nSaving?(y/n)"
        when STATES[2]
          return unless @message == 'y' || @message == 'n'

          case @message
          when 'y'
            data = State.check_state(user_id)
            Database.save(user_id: user_id, name: data[:name], date: data[:date])
            Response.std_message 'Saved!'
            State.replace({ user_id: user_id, name: data[:name], date: data[:date], state: STATES[3] })
          when 'n'
            State.replace({ user_id: user_id, name: nil, date: nil, state: STATES[0] })
          else
            Response.std_message 'Invalid input'
          end
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
