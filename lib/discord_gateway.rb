require 'faye/websocket'
require 'eventmachine'
require 'json'

class DiscordGateway
  GATEWAY_URL = 'wss://gateway.discord.gg/?v=10&encoding=json'.freeze

  # Intents: GUILDS (1) + GUILD_MESSAGES (512) + MESSAGE_CONTENT (32768) = 33281
  def initialize(token, intents: 33_281)
    @token = token
    @intents = intents
    @heartbeat_interval = nil
    @sequence = nil
    @on_message = nil
    @on_ready = nil
  end

  def on_message(&block)
    @on_message = block
  end

  def on_ready(&block)
    @on_ready = block
  end

  def run
    EM.run do
      @ws = Faye::WebSocket::Client.new(GATEWAY_URL)

      @ws.on :open do |_event|
        puts '[Gateway] Connected'
      end

      @ws.on :message do |event|
        handle_message(JSON.parse(event.data))
      end

      @ws.on :close do |event|
        puts "[Gateway] Closed: #{event.code} - #{event.reason}"
        EM.stop
      end

      @ws.on :error do |event|
        puts "[Gateway] Error: #{event.message}"
      end
    end
  end

  private

  def handle_message(data)
    op = data['op']
    event_type = data['t']
    payload = data['d']
    @sequence = data['s'] if data['s']

    case op
    when 10 # Hello
      @heartbeat_interval = payload['heartbeat_interval']
      start_heartbeat
      identify
    when 11 # Heartbeat ACK
      # Connection is healthy
    when 0 # Dispatch
      handle_dispatch(event_type, payload)
    end
  end

  def handle_dispatch(event_type, payload)
    case event_type
    when 'READY'
      puts "[Gateway] Logged in as #{payload['user']['username']}"
      @on_ready&.call(payload)
    when 'MESSAGE_CREATE'
      @on_message&.call(payload)
    end
  end

  def identify
    send_payload(2, {
                   token: @token,
                   intents: @intents,
                   properties: {
                     os: RUBY_PLATFORM,
                     browser: 'xcancel-bot',
                     device: 'xcancel-bot'
                   },
                   presence: {
                     status: 'online',
                     activities: [{
                       name: 'for Twitter links',
                       type: 3 # "Watching"
                     }]
                   }
                 })
  end

  def start_heartbeat
    EM.add_periodic_timer(@heartbeat_interval / 1000.0) do
      send_payload(1, @sequence)
    end
  end

  # rubocop:disable Naming/MethodParameterName
  def send_payload(op, data)
    @ws.send({ op: op, d: data }.to_json)
  end
  # rubocop:enable Naming/MethodParameterName
end
