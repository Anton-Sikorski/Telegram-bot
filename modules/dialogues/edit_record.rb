# frozen_string_literal: true

class BirthdayBot
  module Listener
    # module to edit records
    module EditRecord
      EDIT_STATES = %w[begin_edit id_set edit_name edit_date confirmed].freeze

      def edit_record
        message = Listener.message.text
        if ['/reset', 'Отменить действие'].include?(message)
          change_state
          return Response.inline_message 'Редактирование отменено', StandardMessages.start
        end

        state = State.check_state(user_id)[:state]
        user_records = Database.select(user_id)

        case state
        when 'confirmed'
          change_state(EDIT_STATES[0])
          Response.inline_message "Выберите номер записи для изменения:\n#{
            user_records.map.with_index { |record, index| "#{index + 1}) #{record[1]}" }.join("\n")}",
                                  Response.generate_keyboard_markup([KeyboardButton::RESET_SAVE], true)
        when EDIT_STATES[0]
          return Response.std_message 'Нет такой записи. Попробуй ещё!' unless record_exist?(message)

          record_id = message.to_i - 1
          change_state(EDIT_STATES[1], user_records[record_id][3], user_records[record_id][1],
                       user_records[record_id][2])
          choice
        when EDIT_STATES[2]
          return Response.std_message 'Попробуй ещё!' unless Security.valid_name?(message)

          data = State.check_state(user_id)
          change_state('confirmed', data[:record_id], message, data[:date])
          confirm
        when EDIT_STATES[3]
          return Response.std_message 'Попробуй ещё!' unless Security.valid_date?(message)

          data = State.check_state(user_id)
          change_state('confirmed', data[:record_id], data[:name], message.gsub('.', '/'))
          confirm
        end
      end

      def edit_name
        data = State.check_state(user_id)
        State.replace({ user_id: user_id, name: data[:name], date: data[:date],
                        state: EDIT_STATES[2], record_id: data[:record_id] })
        Response.std_message 'Введите имя:'
        Response.delete_message(message_id)
      end

      def edit_date
        data = State.check_state(user_id)
        State.replace({ user_id: user_id, name: data[:name], date: data[:date],
                        state: EDIT_STATES[3], record_id: data[:record_id] })
        Response.std_message 'Введите дату:'
        Response.delete_message(message_id)
      end

      def delete_record
        Database.delete_record(State.check_state(user_id)[:record_id])
        Response.delete_message(message_id)
        Response.std_message 'Успешно удалено!'
        State.replace({ user_id: user_id, name: nil, date: nil, state: 'confirmed' })
        StandardMessages.start
      end

      def confirm
        Response.inline_message 'Сохраняем?', Response.generate_inline_markup(
          [
            InlineButton::CONFIRM_EDIT,
            InlineButton::DECLINE_EDIT
          ]
        )
      end

      def confirm_edit
        Database.replace(State.check_state(user_id))
        State.replace({ user_id: user_id, name: nil, date: nil, state: 'confirmed' })
        StandardMessages.start
      end

      def choice
        Response.inline_message 'Что бы вы хотели изменить?', Response.generate_inline_markup(
          [
            InlineButton::EDIT_DATE,
            InlineButton::EDIT_NAME,
            InlineButton::DELETE_RECORD
          ]
        )
      end

      def record_exist?(message)
        message.match(/\d+/) && message.to_i <= Database.select(user_id).size && !message.to_i.negative?
      end

      def change_state(state = 'confirmed', id = nil, name = nil, date = nil)
        State.replace({ user_id: user_id, record_id: id, name: name, date: date, state: state })
      end

      def message_id
        Listener.message.message.message_id
      end

      def user_id
        Listener.message.from.id
      end

      module_function(
        :choice,
        :user_id,
        :confirm,
        :edit_date,
        :edit_name,
        :message_id,
        :edit_record,
        :confirm_edit,
        :change_state,
        :record_exist?,
        :delete_record
      )
    end
  end
end
