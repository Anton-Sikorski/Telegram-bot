# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to processing all standard messages
    module StandardMessages
      STATES = %w[begin filled_name filled_date confirmed].freeze

      def process
        @message = Listener.message.text
        State.save({ user_id: user_id, name: nil, date: nil, state: STATES[3] }) if State.check_state(user_id).nil?

        if State.check_state(user_id)[:state] != STATES[3]
          set_birthday
        else
          case @message
          when '/start', 'Привет'
            start
          when '/set_birthday'
            set_birthday
          when '/birthdays'
            CallbackMessages.birthday
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
            InlineButton::SET_BIRTHDAY,
            InlineButton::CHECK_DATES
          ]
        )
      end

      def confirm
        Response.inline_message 'Сохраняем?', Response.generate_inline_markup(
          [
            InlineButton::CONFIRM_SAVE,
            InlineButton::DECLINE_SAVE
          ]
        )
      end

      def set_birthday
        if @message == '/reset'
          change_state
          return Response.std_message 'Запись отменена'
        end

        state = State.check_state(user_id).empty? ? nil : State.check_state(user_id)[:state]

        case state
        when STATES[3]
          change_state(STATES[0])
          Response.std_message 'Сообщи мне имя именинника'
        when STATES[0]
          change_state(STATES[1], @message)
          Response.std_message 'Сообщи мене дату в формате дд/мм/гггг'
        when STATES[1]
          return Response.std_message 'Попробуй ещё!' unless valid_message?(@message)

          data = { name: State.check_state(user_id)[:name], date: @message }
          change_state(STATES[2], State.check_state(user_id)[:name], @message.gsub('.', '/'))
          Response.std_message "Вот что имеем:\nИмя - #{data[:name]}, дата рождения - #{data[:date]}\n"
          confirm
        end
      end

      def birthdays
        Response.std_message 'Вы ещё не добавили не одной записи!'
      end

      def plug_message
        Response.std_message 'Первый раз такое слышу, попробуй сказать что-то другое!'
      end

      def change_state(state = STATES[3], name = nil, date = nil)
        State.replace({ user_id: user_id, name: name, date: date, state: state })
      end

      def user_id
        Listener.message.from.id
      end

      def valid_message?(message)
        return false unless message.match(%r{^\d{2}[./-]\d{2}[./-]\d{4}})

        # Response.std_message 'Неверный формат. Попробуй ещё!'
        day, months, year = message.gsub('.', '/').split('/').map(&:to_i)
        if day > 31 || day < 1
          Response.std_message 'Неверно указан день.'
          return false
        end

        if months > 12 || months < 1
          Response.std_message 'Неверно указан месяц.'
          return false
        end

        if year > 2022 || year < 1921
          Response.std_message 'Неверно указан год.'
          return false
        end

        true
      end

      module_function(
        :process,
        :birthdays,
        :valid_message?,
        :confirm,
        :user_id,
        :change_state,
        :plug_message,
        :set_birthday,
        :start
      )
    end
  end
end
