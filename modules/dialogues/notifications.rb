# frozen_string_literal: true

class BirthdayBot
  module Listener
    # contains methods to create new record
    module Notifications
      def state
        if Users.notify?(user_id)
          Users.replace(user_id: user_id, notify: false.to_s)
          Response.std_message 'Оповещения выключены'
        else
          Users.replace(user_id: user_id, notify: true.to_s)
          Response.std_message 'Оповещения включены'
        end
      end

      def user_id
        Listener.message.from.id
      end

      module_function(
        :user_id,
        :state
      )
    end
  end
end
