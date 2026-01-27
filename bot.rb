require 'dotenv/load'
require_relative 'lib/discord_gateway'
require_relative 'lib/discord_client'
require_relative 'lib/url_converter'

token = ENV.fetch('DISCORD_TOKEN', nil)

if token.nil? || token.empty?
  puts 'DISCORD_TOKEN is not set in environment variables'
  exit 1
end

client = DiscordClient.new(token)
gateway = DiscordGateway.new(token)

gateway.on_message do |message|
  # Skip bot messages
  next if message.dig('author', 'bot')

  content = message['content']
  channel_id = message['channel_id']

  puts "[Bot] Message received: #{content.inspect}"

  converted_urls = UrlConverter.extract_and_convert(content)

  if converted_urls&.any?
    response = converted_urls.join("\n")
    result = client.send_message(channel_id, response)

    if result.success?
      puts "[Bot] Converted #{converted_urls.length} URL(s) in channel #{channel_id}"
    else
      puts "[Bot] Failed to send message: #{result.code}"
    end
  end
end

puts 'Starting bot...'
gateway.run
