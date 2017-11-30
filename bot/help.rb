class Help < SlackRubyBot::Commands::Base
  HELP = <<-EOS.freeze

```
I am your friendly Karma bot, here to spread the love!

General
-------

help          - get this helpful message
add           - give good karma

```
EOS

  def self.call(client, data, _match)
    client.say(channel: data.channel, text: [HELP, SlackRubyBotServer::INFO].join('\n'))
    logger.info "HELP: #{client.owner}, user=#{data.user}"
  end
end
