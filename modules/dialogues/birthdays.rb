# frozen_string_literal: true

class BirthdayBot
  module Listener
    # contains methods to create new record
    module Birthdays

      def save_data
        data = State.check_state(user_id)
        # save data into main database
        puts data
        Database.save(user_id: user_id, name: data[:name], date: data[:date])
        Response.std_message 'Успех!'
        # resetting status of user
        State.replace({ user_id: user_id, name: nil, date: nil, state: 'confirmed' })
        Response.delete_message(message_id)
        StandardMessages.start
      end

      def dates(message)
        user_data = Database.select(user_id).map { |record| { id: user_id, name: record[1], date: record[2] } }
                            .sort { |a, b| time_diff(a[:date]) <=> time_diff(b[:date]) }

        return Listener::Response.std_message('Вы пока не добавили ни одной записи!') if user_data.empty?

        case message
        when 'check_dates'
          answer = user_data.map { |user| "У #{name_form(user[:name])} через #{time_diff(user[:date])} дней День Рождения!" }.join("\n")
        when 'birthdays'
          answer = user_data.map { |user| "День рождения #{name_form(user[:name])} - #{user[:date]}." }.join("\n")
        end
        Listener::Response.std_message answer
      end

      def birthdays
        dates 'birthdays'
      end

      def check_dates
        dates 'check_dates'
      end

      def time_diff(date)
        days = (Date.parse(date.gsub(/\d{4}/, '2022')) - Date.parse(Time.now.to_s)).to_i
        days.negative? ? 365 + days.to_i : days
      end

      def message_id
        Listener.message.message.message_id
      end

      def user_id
        Listener.message.from.id
      end

      def name_form(name)
        return name if name.split('').any?(/[a-z]/)

        first_name, second_name = name.split(' ')

        Petrovich(
          firstname: first_name,
          lastname: second_name
        ).genitive.to_s
      end

      module_function(
        :check_dates,
        :message_id,
        :name_form,
        :time_diff,
        :save_data,
        :birthdays,
        :user_id,
        :dates
      )
    end
  end
end
