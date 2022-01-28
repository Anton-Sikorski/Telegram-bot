# frozen_string_literal: true

class BirthdayBot
  module Listener
    # Module for security checks
    module Security
      def message_is_new(start_time, message)
        message_time = defined?(message.date) ? message.date : message.message.date
        message_time.to_i > start_time
      end

      def message_too_far
        message_date = defined?(Listener.message.date) ? Listener.message.date : Listener.message.message.date
        message_delay = Time.now.to_i - message_date.to_i
        # if message delay less then 5 min then processing message, else ignore
        message_delay > (5 * 60)
      end

      def valid_message?(message)
        unless message.match(%r{^\d{2}[./-]\d{2}[./-]\d{4}})
          Response.std_message 'Неверный формат'
          return false
        end

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
        :valid_message?,
        :message_is_new,
        :message_too_far
      )
    end
  end
end
