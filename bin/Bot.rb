#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'PerraldBot'

bot = PerraldBot::TwitchBot.new
trap("INT") { bot.quit }
bot.run
