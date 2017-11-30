class Add < SlackRubyBot::Commands::Base
  ADD = "You gave good karma!"

  def self.call(client, data, _match)
    client.say(channel: data.channel, text: [ADD])
    logger.info "ADD: #{client.owner}, user=#{data.user}"
  end
end
