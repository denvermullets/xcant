require 'httparty'

class DiscordClient
  include HTTParty

  base_uri 'https://discord.com/api/v10'

  def initialize(token)
    @token = token
    @headers = {
      'Authorization' => "Bot #{token}",
      'Content-Type' => 'application/json'
    }
  end

  def send_message(channel_id, content)
    self.class.post(
      "/channels/#{channel_id}/messages",
      headers: @headers,
      body: { content: content }.to_json
    )
  end
end
