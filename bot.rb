require 'discordrb'
require './lib/soundmoji.rb'

# Check for required env. variables
["SOUNDMOJI_BOT_ID", "SOUNDMOJI_BOT_TOKEN"].each do |var|
    unless ENV[var]
        puts "#{var}: variable not specified, exiting."
        return
    end
end

# Create the bot
bot = Discordrb::Commands::CommandBot.new(
    token: ENV['SOUNDMOJI_BOT_TOKEN'], 
    client_id: ENV['SOUNDMOJI_BOT_ID'], 
    prefix: "!"
  )

bot.include! Soundmoji

puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'

bot.run