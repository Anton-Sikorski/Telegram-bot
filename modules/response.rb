# frozen_string_literal: true

class BirthdayBot
  module Listener
    # This module assigned to responses from bot
    module Response
      def std_message(message, chat_id: false)
        chat = chat_id_defined?
        chat = chat_id if chat_id
        Listener.bot.api.send_message(
          parse_mode: 'html',
          chat_id: chat,
          text: message
        )
      end

      def inline_message(message, inline_markup, editless: false, chat_id: false)
        chat = chat_id_defined?
        chat = chat_id if chat_id

        if editless
          return Listener.bot.api.edit_message_text(
            chat_id: chat,
            parse_mode: 'html',
            message_id: Listener.message.message.message_id,
            text: message,
            reply_markup: inline_markup
          )
        end

        Listener.bot.api.send_message(
          chat_id: chat,
          parse_mode: 'html',
          text: message,
          reply_markup: inline_markup
        )
      end

      def generate_inline_markup(kbrd, force: false)
        Telegram::Bot::Types::InlineKeyboardMarkup.new(
          inline_keyboard: kbrd
        )
      end

      def generate_keyboard_markup(kbrd, one_time = false, force: false)
        Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: kbrd,
          one_time_keyboard: one_time
        )
      end

      def force_reply_message(text, chat_id: false)
        chat = chat_id_defined?
        chat = chat_id if chat_id
        Listener.bot.api.send_message(
          parse_mode: 'html',
          chat_id: chat,
          text: text,
          reply_markup: Telegram::Bot::Types::ForceReply.new(
            force_reply: true,
            selective: true
          )
        )
      end

      def delete_message(message_id, chat_id: false)
        chat = chat_id_defined?
        chat = chat_id if chat_id
        Listener.bot.api.deleteMessage(
          chat_id: chat,
          message_id: message_id
        )
      end

      def remove_keyboard
        Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      end

      def chat_id_defined?
        defined?(Listener.message.chat.id) ? Listener.message.chat.id : Listener.message.message.chat.id
      end

      module_function(
        :std_message,
        :delete_message,
        :chat_id_defined?,
        :remove_keyboard,
        :generate_inline_markup,
        :generate_keyboard_markup,
        :inline_message,
        :force_reply_message
      )
    end
  end
end
