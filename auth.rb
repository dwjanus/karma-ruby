require 'sinatra/base'
require 'slack-ruby-client'

# Load Slack App info into hash called 'config' from env variables assigned during setup
SLACK_CONFIG = {
  slack_client_id: ENV['SLACK_CLIENT_ID'],
  slack_api_secret: ENV['SLACK_API_SECRET'],
  slack_redirect_uri: ENV['SLACK_REDIRECT_URI'],
  slack_verification_token: ENV['SLACK_VERIFICATION_TOKEN']
}

# Check to see if the required variables were provided, raise exception if any are missing
missing_params = SLACK_CONFIG.select { |key, value| value.nil? }
if missing_params.any?
  error_msg = missing_params.keys.join(", ").upcase
  raise "Missing Slack config variables: #{error_msg}"
end

# set the Oauth scope of the bot
BOT_SCOPE = 'bot'

$teams = {}

# Since we create a Slack client object for each team, this helps keep that logic in one place
def create_slack_client(slack_api_secret)
  Slack.configure do |config|
    config.token = slack_api_secret
    fail 'Missing API token' unless config.token
  end
  Slack::Web::Client.new
end

# Oauth
class Auth < Sinatra::Base
  add_to_slack_button = %(
    <a href=\"https://slack.com/oauth/authorize?scope=#{BOT_SCOPE}&client_id=#{SLACK_CONFIG[:slack_client_id]}&redirect_uri=#{SLACK_CONFIG[:redirect_uri]}\">
      <img alt=\"Add to Slack\" height=\"40\" width=\"139\" src=\"https://platform.slack-edge.com/img/add_to_slack.png\"/>
    </a>
  )

  # if a user tries to access index page redirect them to the auth start page
  get '/' do
    redirect '/begin_auth'
  end

  # Oauth Step 1: Show the "Add to Slack" button
  get '/begin_auth' do
    status 200
    body add_to_slack_button
  end

  # Oauth Step 2: (User clicked button and accepted) Slack sends code to process as request token
  get '/finish_auth' do
    client = Slack::Web::Client.new

    # Oauth Step 3: Success/Failure
    begin
      response = client.oauth_access(
        {
          client_id: SLACK_CONFIG[:slack_client_id],
          client_secret: SLACK_CONFIG[:slack_api_secret],
          redirect_uri: SLACK_CONFIG[:slack_redirect_uri],
          code: params[:code]
        }
      )

      # Success...
      team_id = response['team_id']
      $teams[team_id] = {
        user_access_token: response['acces_token'],
        bot_user_id: response['bot']['bot_user_id'],
        bot_access_token: response['bot']['bot_access_token']
      }

      $teams[team_id]['client'] = create_slack_client(response['bot']['bot_access_token'])
      status 200
      body "Authentication Success! Your team can now Karma!"
    rescue Slack::Web::Api::Error => e
      # Failure...
      status 403
      body "Authentication Failed! Reason: #{e.message}<br/>#{add_to_slack_button}"
    end
  end
end
