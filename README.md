# XCancel Bot

Discord bot that converts twitter.com and x.com links to xcancel.com.

## Server Management

SSH into server:
```bash
ssh deploy@your-server-ip
cd ~/xcant
```

### Systemctl Commands

```bash
# Check status
sudo systemctl status xcancel-bot

# Start / Stop / Restart
sudo systemctl start xcancel-bot
sudo systemctl stop xcancel-bot
sudo systemctl restart xcancel-bot

# View logs (live)
sudo journalctl -u xcancel-bot -f

# View last 100 log lines
sudo journalctl -u xcancel-bot -n 100

# Enable/disable start on boot
sudo systemctl enable xcancel-bot
sudo systemctl disable xcancel-bot
```

### After Updating Code

```bash
cd ~/xcant
git pull
bundle install
sudo systemctl restart xcancel-bot
```

### After Updating Service File

```bash
sudo cp xcancel-bot.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart xcancel-bot
```

## Local Development

```bash
bundle install
cp .env.example .env  # add your DISCORD_TOKEN
bundle exec ruby bot.rb
```

## Setup

1. Create Discord app at https://discord.com/developers/applications
2. Bot > Enable "Message Content Intent"
3. OAuth2 > URL Generator > Select `bot` scope
4. Bot Permissions: `Send Messages`, `Read Message History`
5. Use generated URL to invite bot to server
