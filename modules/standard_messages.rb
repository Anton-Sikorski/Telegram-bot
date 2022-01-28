# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to processing all standard messages
    module StandardMessages
      ADD_STATES = %w[begin filled_name filled_date confirmed].freeze
      EDIT_STATES = %W[begin edit_name edit_date confirmed]
      def process
        @message = Listener.message.text
        State.save({ user_id: user_id, name: nil, date: nil, state: ADD_STATES[3] }) if State.check_state(user_id).nil?

        # Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)

        if State.check_state(user_id)[:state] != 'confirmed'
          edit_record
          set_birthday
        else
          case @message
          when '/start', 'Привет'
            start
          when '/set_birthday', 'Добавить запись'
            set_birthday
          when '/birthdays', 'Дни рождения'
            CallbackMessages.birthday
          when '/stop'
            Response.std_message 'Пока!'
            exit(1)
          when 'А когда праздники?'
            CallbackMessages.check_dates
          else
            Response.std_message 'Первый раз такое слышу, попробуй сказать что-то другое!'
          end
        end
      end

      def start
        Response.inline_message 'Привет, выбери из доступных действий', Response.generate_keyboard_markup(
          [
            KeyboardButton::GET_BIRTHDAY,
            KeyboardButton::SET_BIRTHDAY,
            KeyboardButton::CHECK_DATES
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
        if @message == '/reset' || @message == 'Отменить запись'
          change_state
          return Response.inline_message 'Запись отменена', remove_keyboard
        end

        state = State.check_state(user_id).empty? ? nil : State.check_state(user_id)[:state]

        case state
        when ADD_STATES[3]
          change_state(ADD_STATES[0])
          Response.inline_message 'Сообщи мне имя именинника', Response.generate_keyboard_markup(
            [
              KeyboardButton::RESET_SAVE
            ],
            true
          )
        when ADD_STATES[0]
          change_state(ADD_STATES[1], @message)
          Response.std_message 'Сообщи мене дату в формате дд/мм/гггг'
        when ADD_STATES[1]
          return Response.std_message 'Попробуй ещё!' unless Listener::Security.valid_message?(@message)

          data = { name: State.check_state(user_id)[:name], date: @message }
          change_state(ADD_STATES[2], State.check_state(user_id)[:name], @message.gsub('.', '/'))
          Response.inline_message "Вот что имеем:\nИмя - #{data[:name]}, дата рождения - #{data[:date]}\n", remove_keyboard
          confirm
        end
      end

      def edit_record

      end

      def change_state(state = ADD_STATES[3], name = nil, date = nil)
        State.replace({ user_id: user_id, name: name, date: date, state: state })
      end

      def user_id
        Listener.message.from.id
      end

      def remove_keyboard
        Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      end

      module_function(
        :process,
        :confirm,
        :user_id,
        :change_state,
        :edit_record,
        :remove_keyboard,
        :set_birthday,
        :start
      )
    end
  end
end
