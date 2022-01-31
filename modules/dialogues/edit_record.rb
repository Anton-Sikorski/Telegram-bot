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
          return Response.inline_message 'Редактирование отменено', Response.remove_keyboard
        end

        state = State.check_state(user_id)[:state]

        case state
        when 'confirmed'
          change_state(EDIT_STATES[0])
          Response.inline_message "Выберите номер записи для изменения:\n#{
            user_records.map.with_index do |record, index|
              "#{index + 1}) #{record[1]}"
            end.join("\n")}", Response.generate_keyboard_markup(
              [
                KeyboardButton::RESET_SAVE
              ],
              true
            )
        when EDIT_STATES[0]
          unless message.match(/\d+/) && message.to_i <= user_records.size && !message.to_i.negative?
            return Response.std_message 'Нет такой записи. Попробуй ещё!'
          end

          record_id = message.to_i - 1
          change_state(EDIT_STATES[1], user_records[record_id][3],
                       user_records[record_id][1], user_records[record_id][2])
          Response.inline_message 'Что бы вы хотели изменить?', Response.generate_inline_markup(
            [
              InlineButton::EDIT_DATE,
              InlineButton::EDIT_NAME,
              InlineButton::DELETE_RECORD
            ]
          )
        when EDIT_STATES[2]
          data = State.check_state(user_id)
          pp message.to_s
          change_state('confirmed', data[:record_id],
                       message, data[:date])
          confirm
        when EDIT_STATES[3]
          return Response.std_message 'Попробуй ещё!' unless Listener::Security.valid_record?(message)

          data = State.check_state(user_id)
          change_state('confirmed', data[:record_id],
                       data[:name], message.gsub('.', '/'))
          confirm
          # when EDIT_STATES[1]
          #   return Response.std_message 'Попробуй ещё!' unless Listener::Security.valid_message?(message)
          #
          #   data = { name: State.check_state(user_id)[:name], date: message }
          #   change_state(EDIT_STATES[2], State.check_state(user_id)[:name], message.gsub('.', '/'))
          #   Response.inline_message "Вот что имеем:\nИмя - #{data[:name]}, дата рождения - #{data[:date]}\n",
          #                           Response.remove_keyboard
          #   confirm
        end
      end

      def confirm
        Response.inline_message 'Сохраняем?', Response.generate_inline_markup(
          [
            InlineButton::CONFIRM_EDIT,
            InlineButton::DECLINE_EDIT
          ]
        )
      end

      def change_state(state = 'confirmed', id = nil, name = nil, date = nil)
        State.replace({ user_id: user_id, record_id: id, name: name, date: date, state: state })
      end

      def user_records
        Database.select(user_id)
      end

      def user_id
        Listener.message.from.id
      end

      module_function(
        :user_id,
        :confirm,
        :change_state,
        :user_records,
        :edit_record
      )
    end
  end
end
