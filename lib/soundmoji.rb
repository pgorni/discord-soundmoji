require 'discordrb'

class Soundmoji
  extend Discordrb::EventContainer
  extend Discordrb::Commands::CommandContainer

  rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
  rate_limiter.bucket :sound, delay: 3 

  sounds = {
    "example": "snd/example.mp3"
  }

  command(:soundmoji_connect, required_permissions: [:manage_channels]) do |event|
    channel = event.user.voice_channel
    next event.user.pm("You aren't connected to a voice channel.") unless channel
    event.bot.voice_connect(channel)
    event.user.pm("Connected to voice channel: #{channel.name}")
  end

  message do |event|
    if event.voice
      sounds.keys.each do |kw|
        if event.text.include? kw.to_s
          timeout = rate_limiter.rate_limited?(:sound, event.channel)
          puts "#{Time.now}: #{event.user.name}: #{kw}, timeout: #{timeout}"
          unless Dir.exist?(sounds[kw])
            puts "#{Time.now}: #{sounds[kw]} NOT FOUND."
            break
          end
          event.voice.play_file(sounds[kw]) unless timeout or event.voice.playing?
          break
        end
      end
    end
  end

end