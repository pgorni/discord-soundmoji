require 'discordrb'
require 'to_regexp'
require 'yaml'

class Soundmoji
  extend Discordrb::EventContainer
  extend Discordrb::Commands::CommandContainer

  rate_limiter = Discordrb::Commands::SimpleRateLimiter.new 

  ready do |event|
    @all_sounds = {}
    puts "[INFO] Loading sounds..."
    load_sounds
    event.bot.game = "#{@all_sounds.count} sounds | #{event.bot.prefix}soundmoji help"
    @options = {
      blocking: false,
      channels: nil,
      rate_limit_delay: 3,
      required_permission: :manage_channels
    }
    rate_limiter.bucket :sound, delay: @options[:rate_limit_delay]
  end

  command(:soundmoji) do |event, command, *args|
    next unless event.author.permission? @options[:required_permission]
    next if event.channel.pm?

    case command
    when "connect"
      channel = event.user.voice_channel
      next event.user.pm("You aren't connected to a voice channel.") unless channel
      event.bot.voice_connect(channel)
      event.user.pm("Connected to voice channel: #{channel.name}")
      puts "[INFO] #{Time.now}: connected to voice channel #{channel.name}"
    when "disconnect"
      # This should disconnect from a voice channel only on the server where it's called.
      event.voice.destroy
      puts "[INFO] #{Time.now}: Disconnected from server #{event.server.name} (#{event.server.id})"
    when "set_channels"
      if args.first == "any" or args.first == "*"
        @options[:channels] = nil
        event.user.pm("⭕ listening on any channel")
      else
        @options[:channels] = args
        event.user.pm("⭕ listening on: #{@options[:channels].join(", ")}")
      end
    when "toggle_blocking"
      @options[:blocking] = !@options[:blocking]
      event.user.pm("⭕ blocking behavior set to #{@options[:blocking]}")
    when "set_rate_limit_delay"
      delay = args.first.to_i 
      if delay == 0
        event.user.pm("❌ not a number")
      else
        @options[:rate_limit_delay] = delay
        rate_limiter.bucket :sound, delay: @options[:rate_limit_delay]
        event.user.pm("⭕ rate limiting set to #{@options[:rate_limit_delay]}")
      end
    when "list_sounds"
      # XXX this works for now
      if @all_sounds.count >= (60 * 5)
        event.user.pm("There are too many sounds loaded. Look for the sound listing on the server.")
        next
      end

      @all_sounds.keys.map { |kw| kw.inspect }.each_slice(60).with_index do |kw, i|
        event.user.pm.send_embed do |embed|
          embed.title = "discord-soundmoji"
          embed.description = "Sound listing, part #{i + 1}"
          embed.colour = "#FFFF00"
          kw.each do |kw|
            embed.add_field(name: kw.to_s, value: "---")
          end
        end
        sleep(5)
      end
    when "help"
      event.channel.send_embed do |embed|
        embed.title = 'discord-soundmoji'
        embed.description = "A simple bot for adding sounds to emoji or words."
        embed.colour = "#FFFF00"
        embed.add_field(
          name: "Usage", 
          value: [
            "In order to hear sounds, you have to connect to a voice channel the bot's in.\n",
            "Then, typing a keyword or using a specific emoji will trigger sound playback.\n",
            "You can get the list of sounds by typing `#{event.bot.prefix}soundmoji list_sounds`.\n",
            "**WARNING!** The server may have lots of sounds, so you may (and probably will) get a lot of messages.\n",
            "It's usually better to find the sound listing somewhere on the server you're in."
          ].join("")
        )
        embed.add_field(
          name: "Config", 
          value: [
            "You have to have the `#{@options[:required_permission]}` permission to be able to use these commands.\n",
            "\n",
            "`#{event.bot.prefix}soundmoji connect`: make the bot connect to a voice channel you're in\n",
            "`#{event.bot.prefix}soundmoji disconnect`: disconnect the bot from a voice channel\n",
            "`#{event.bot.prefix}soundmoji set_channels <channel(s) (divided by spaces) OR any>`: make the bot search for emoji or keywords in the specified channel(s)\n",
            "`#{event.bot.prefix}soundmoji toggle_blocking`: set whether new emoji or keyword trigger should stop the sound that's already being played\n",
            "`#{event.bot.prefix}soundmoji set_rate_limit_delay <seconds>`: stop the users from spamming sounds\n"
          ].join("")
        )
        embed.add_field(
          name: "Donations",
          value: "Like the bot? [Support it on Patreon!](https://patreon.com/zanbots)"
        )
      end
    end
  end

  message do |event|
    if event.voice

      if @options[:channels]
        next unless @options[:channels].include? event.channel.name 
      end

      @all_sounds.each do |kw, file_paths|
        if event.text.match(kw)
          # TODO: per-user/per-channel rate limiting
          timeout = rate_limiter.rate_limited?(:sound, event.channel)
          puts "[TRG]: #{Time.now}: #{event.user.name}: #{kw.inspect}, channel: #{event.channel.name}, timeout: #{timeout}"
          sound = file_paths.sample
          puts "[WARN]: #{Time.now}: the file(s) for #{kw.inspect} haven't been found." if !sound

          if @options[:blocking]
            event.voice.play_file(sound) unless timeout or event.voice.playing? or !sound
          else
            event.voice.play_file(sound) unless timeout or !sound
          end

          break
        end
      end
    end
  end

  private 

  def self.load_sounds
    soundfile_path = ENV['SOUNDMOJI_SOUNDS_PATH'] || ARGV.shift
    Dir.chdir(soundfile_path) if soundfile_path
    puts "[INFO] Executing at #{Dir.pwd}"
    unless File.exist?("snd.yml")
      puts "[ERR] snd.yml not found!"
      exit
    end
    soundpacks = YAML.load_file("snd.yml")
    soundpacks.each do |name, path|
      puts "Loading soundpack #{name} at #{path + "/snd_pack.yml"}."
      unless File.exist?(path + "/snd_pack.yml")
        puts "Soundpack file #{path + "/snd_pack.yml"} not found."
      end
      sounds = YAML.load_file(path + "/snd_pack.yml")

      # "/keyword/i" => ["file1.mp3", "file2.mp3"] or "/keyword/i" => []
      sounds.each do |kw, snd_filenames|
        snd_file_paths = snd_filenames.map do |fname|
          fpath = path + "/" + fname
          unless File.exist?(fpath)
            puts "[WARN] #{Time.now}: #{fpath} NOT FOUND."
            fpath = nil
          end
          fname = fpath
        end.compact        
        @all_sounds[kw.to_regexp] = snd_file_paths # I could also not add the key if snd_file_path is nil
      end
    end
  end

end