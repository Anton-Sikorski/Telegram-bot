# frozen_string_literal: true

class BirthdayBot
  # This module assigned to creating InlineKeyboardButton
  module KeyboardButton
    GET_BIRTHDAY = Telegram::Bot::Types::KeyboardButton.new(text: 'Дни рождения', callback_data: 'birthday')
    SET_BIRTHDAY = Telegram::Bot::Types::KeyboardButton.new(text: 'Добавить запись',
                                                                  callback_data: 'set_birthday')
    CHECK_DATES = Telegram::Bot::Types::KeyboardButton.new(text: 'А когда праздники?',
                                                                 callback_data: 'check_dates')
    RESET_SAVE =  Telegram::Bot::Types::KeyboardButton.new(text: 'Отменить запись',
                                                                callback_data: 'check_dates')
  end
end