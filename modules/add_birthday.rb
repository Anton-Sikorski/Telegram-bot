# frozen_string_literal: true

class BirthdayBot
  module Listener
    # contains methods to create new record
    module AddBirthday
      ADD_STATES = %w[begin_add filled_name filled_date confirmed].freeze

      def set_birthday
        message = Listener.message.text
        if ['/reset', 'Отменить действие'].include?(message)
          change_state
          return Response.inline_message 'Запись отменена', Response.remove_keyboard
        end

        state = State.check_state(user_id)[:state]

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
          change_state(ADD_STATES[1], message)
          Response.std_message 'Сообщи мене дату в формате дд/мм/гггг'
        when ADD_STATES[1]
          return Response.std_message 'Попробуй ещё!' unless Listener::Security.valid_record?(message)

          data = { name: State.check_state(user_id)[:name], date: message }
          change_state(ADD_STATES[2], State.check_state(user_id)[:name], message.gsub('.', '/'))
          Response.inline_message "Вот что имеем:\nИмя - #{data[:name]}, дата рождения - #{data[:date]}\n",
                                  Response.remove_keyboard
          confirm
        end
      end

      def confirm
        Response.inline_message 'Сохраняем?', Response.generate_inline_markup(
          [
            InlineButton::CONFIRM_SAVE,
            InlineButton::DECLINE_SAVE
          ]
        )
      end

      def change_state(state = ADD_STATES[3], name = nil, date = nil)
        State.replace({ user_id: user_id, name: name, date: date, state: state })
      end

      def user_id
        Listener.message.from.id
      end

      module_function(
        :confirm,
        :user_id,
        :change_state,
        :set_birthday
      )
    end
  end
end
