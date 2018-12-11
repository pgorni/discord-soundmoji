require 'discordrb'
require './lib/soundmoji.rb'

# Check for required env. variables
["SOUNDMOJI_BOT_ID", "SOUNDMOJI_BOT_TOKEN"].each do |var|
  unless ENV[var]
    puts "#{var}: variable not specified, exiting."
    exit
  end
end

# Create the bot
bot = Discordrb::Commands::CommandBot.new(
    token: ENV['SOUNDMOJI_BOT_TOKEN'], 
    client_id: ENV['SOUNDMOJI_BOT_ID'], 
    prefix: "!"
  )

bot.include! Soundmoji



puts %q{                                                           
 _ ) o  _ _  _   _ _ )  __ _ _       _   _ ) _ _   _  o  o 
(_(  ( ( (_ (_) ) (_(     ( (_) (_( ) ) (_( ) ) ) (_) (  ( 
       _)                 _)                          _)   
}

puts "Invite the bot with this link: #{bot.invite_url}."

bot.run