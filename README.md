# Discord Soundmoji

### What does this bot do?
It adds sounds to your emojis (**including the custom ones**) and words.

### Really? How does it work?
The users have to connect to a voice channel. If they type a *keyword*, it'll be caught by the bot and a specified sound will be played.
The keywords are specified with [regular expressions](https://en.wikipedia.org/wiki/Regular_expression), **so you can have a couple of words for one sound.** The possibilities are endless.
For example: `/lol|haha|heh/i` will be triggered if an user writes `lol`, `haha` or `heh` (and it's case insensitive, so `LOL` will also work).
**You can also have a couple of sounds specified.**
For example `lol` can play back either `laugh1.mp3` or `laugh2.mp3`, chosen randomly.

### (Current) limitations
- The bot won't play a couple sounds at once. It can stop playing a sound that's currently being played and play another sound.
- The bot plays only one sound from a message. Messages like `first_keyword another_keyword` won't queue two sounds.
- Sounds aren't being queued.
- The bot can be connected to many servers, but only one voice channel, which means every server will have to set up their own bot.

### Adding your own sounds

#### Directory structure
You have to create a file named `snd.yml`. In this file you should define the directories, which contain sound files. Each of these directories has to contain a `snd_pack.yml` file with keywords and the appropriate sound files.
Example:
- `snd.yml`:
```yaml
general: "snd"
mgs: "snd/mgs"
pokemon: "snd/pokemon"
```
- `snd/mgs/snd_pack.yml`
```yaml
/alert/: ["mgs_alert.mp3"]
/codec/: ["mgs_codec.mp3"]
```
Output of `tree --dirsfirst`:
```
.
├── snd
│   ├── mgs
│   │   ├── mgs_alert.mp3
│   │   ├── mgs_codec.mp3
│   │   └── snd_pack.yml
│   ├── pokemon
│   │   ├── battle.mp3
│   │   └── snd_pack.yml
│   ├── deja_vu.mp3
│   └── snd_pack.yml
└── snd.yml
```

#### `snd.yml` syntax
Each line of the `snd.yml` file has to contain the name of the sound collection and a path to the directory with a `snd_pack.yml` file and the sound files. **Please note there's no trailing slash.**

#### `snd_pack.yml` syntax
Each line of the `snd_pack.yml` file has to have the *keyword(s)* specified as a [regular expression](https://en.wikipedia.org/wiki/Regular_expression) and an array of sound(s) for that/these keyword(s). Look below for a Regex crash course.

### Regex crash course
Some typical use cases are listed below, with explanations.

- `/lol/i: ["laugh1.mp3", "laugh2.mp3"]`
This will play either `laugh1.mp3` or `laugh2.mp3` (chosen randomly). Note the `i` at the end - it makes the keyword case insensitive. This means that the sound will be played whenever someone posts a word or an emoji that contains `lol`, `LOL`, `lOL`, `loL`, `LoL` and so on.
- `/fail|sad/: ["sad_trombone.mp3"]`
This will play `sad_trombone.mp3` whenever someone posts a word or an emoji that contains `fail` or `sad` (so also `failure` and `sadness`).
- `/kappa/: ["kappa.mp3"]`
This will play `kappa.mp3` for any occurence of `kappa`. It will also work for a server emoji named `kappa`.
- `/\:kappa\:/: ["kappa.mp3"]`
The server emoji `:kappa:` (and nothing else) will now play out `kappa.mp3`.
- `/😂/: ["heavy_laugh.mp3"]`
This will play `heavy_laugh.mp3` for the infamous [laughing crying emoticon](https://emojipedia.org/face-with-tears-of-joy/). You can add sounds to the standard Discord/Unicode emoticons this way.

### Controlling the bot
The bot has a couple of commands. You need a "Manage Channels" permissions (or higher) to use them.
**The default prefix is "!".**

- `!soundmoji connect`

Makes the bot connect to a voice channel you're in. **You have to be in a voice channel in order to use this command.**

- `!soundmoji set_channels <channel1> <channel2> <...>`

By default the bot listens for the keywords on all channels. You can, however, specify certain channel(s) for the bot to listen to.
Example: `!soundmoji set_channels general` will make the bot listen to the messages on the `#general` channel. `!soundmoji set_channels general soundmoji` will make the bot listen to the messages on both the `#general` and `#soundmoji` channels.

- `!soundmoji toggle_blocking`

By default an user can change a sound which is already playing to another sound by posting a message with a keyword. You can toggle this behavior (if you do, keywords won't be accepted until the sound that was played out has finished playing).

- `!soundmoji set_rate_limit_delay <new_rate_limit_in_seconds>`

By default the bot will permit playing a sound every 3 seconds per channel. You can change this delay with this command. Example: `!soundmoji set_rate_limit_delay 10` means that each channel will have to wait 10 seconds between playing a sound.

### Setting up your own bot
#### Requirements
You require Ruby, [libsodium](https://github.com/meew0/discordrb/wiki/Installing-libsodium),  [libopus](https://github.com/meew0/discordrb/wiki/Installing-libopus) and a couple of gems installed on your system.
You also need to have a Discord Bot token and ID, [see here for tips](https://github.com/reactiflux/discord-irc/wiki/Creating-a-discord-bot-&-getting-a-token). You will need to enter them as environment variables `SOUNDMOJI_BOT_ID` and `SOUNDMOJI_BOT_TOKEN`, as appropriate.

Typical usage:
```sh
export SOUNDMOJI_BOT_ID=<discord_bot_id>
export SOUNDMOJI_BOT_TOKEN=<discord_bot_token>
```

#### Instructions
1. Clone this repository.
2. Go into the bot's directory.
3. Run `bundle install`
4. Create the directories with sounds as explained before. You can create them in the bot's directory or somewhere else. In the latter case, you'll need to pass the location of the directory structure as an argument.
5. Run the bot with `ruby bot.rb`. If your sound files are somewhere else, you need to pass the location of the `snd.yml` file and the subsequent folders as an argument, for example `ruby bot.rb /home/my-discord-sounds`.
6. Invite the bot to your server with the link it displays.
7. 

### License
GNU GPLv3.