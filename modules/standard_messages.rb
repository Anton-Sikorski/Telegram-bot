# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to processing all standard messages
    module StandardMessages
      def process
        message = Listener.message.text
        user_id = Listener.message.from.id
        if State.check_state(user_id).nil?
          State.save({ user_id: user_id, name: nil, date: nil,
                       state: 'confirmed' })
        end

        state = State.check_state(user_id)[:state]
        if state == 'confirmed'
          case message
          when '/start', 'Привет'
            start
          when '/edit_record', 'Изменить запись'
            EditRecord.edit_record
          when '/set_birthday', 'Добавить запись'
            AddBirthday.set_birthday
          when '/birthdays', 'Дни рождения'
            CallbackMessages.birthdays
          when '/stop'
            Response.std_message 'Пока!'
            exit(1)
          when 'А когда праздники?'
            CallbackMessages.check_dates
          else
            Response.std_message 'Первый раз такое слышу, попробуй сказать что-то другое!'
          end
        elsif AddBirthday::ADD_STATES.any?(state)
          AddBirthday.set_birthday
        elsif EditRecord::EDIT_STATES.any?(state)
          EditRecord.edit_record
        end
      end

      def start
        Response.inline_message 'Выбери из доступных действий', Response.generate_keyboard_markup(
          [
            KeyboardButton::GET_BIRTHDAY,
            KeyboardButton::SET_BIRTHDAY,
            KeyboardButton::CHECK_DATES
          ]
        )
      end

      module_function(
        :process,
        :start
      )
    end
  end
end
