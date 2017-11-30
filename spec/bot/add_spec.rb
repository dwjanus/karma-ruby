require 'spec_helper'
require 'bot/add'

describe Add do
  let!(:team) { Fabricate(:team) }
  let(:app) { SlackRubyBotServer::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_hook) { SlackRubyBot::Hooks::Message.new }
  it 'default' do
    expect(client).to receive(:say).with(channel: 'channel', text: [Add::ADD])
    message_hook.call(client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} gave good karma!"))
  end
end
