# frozen_string_literal: true

class BirthdayBot
  module Listener
    # contains methods to create new record
    module Notifications
      def state
        Users.save(user_id) unless Users.select_all.keys.include?(user_id)
        if Users.notify?(user_id)
          turn_off(user_id)
          Response.std_message 'Оповещения выключены'
        else
          turn_on(user_id)
          Response.std_message 'Оповещения включены'
        end
      end

      def turn_on(user_id)
        Users.replace(user_id: user_id, notify: true.to_s)
      end

      def turn_off(user_id)
        Users.replace(user_id: user_id, notify: false.to_s)
      end

      def user_id
        Listener.message.from.id
      end

      module_function(
        :user_id,
        :turn_off,
        :turn_on,
        :state
      )
    end
  end
end
