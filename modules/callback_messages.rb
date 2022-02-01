# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to processing all callback messages
    module CallbackMessages
      attr_accessor :callback_message

      def process
        self.callback_message = Listener.message.message
        case Listener.message.data
        when 'birthday'
          Birthdays.birthdays
        when 'set_birthday'
          AddBirthday.set_birthday
        when 'reset'
          reset
        when 'save_data'
          Birthdays.save_data
        when 'check_dates'
          Birthdays.check_dates
        when 'edit_record'
          EditRecord.edit_record
        when 'edit_name'
          EditRecord.edit_name
        when 'edit_date'
          EditRecord.edit_date
        when 'delete_record'
          EditRecord.delete_record
        when 'confirm_edit'
          EditRecord.confirm_edit
        end
      end

      def reset
        State.replace({ user_id: user_id, name: nil, date: nil,
                        state: 'confirmed' })
        Response.delete_message(message_id)
        StandardMessages.start
      end

      def user_id
        Listener.message.from.id
      end

      module_function(
        :reset,
        :process,
        :user_id,
        :callback_message,
        :callback_message=
      )
    end
  end
end
