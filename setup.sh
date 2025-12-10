#!/bin/bash
# =============================================================================
# MATRIX STACK SETUP SCRIPT
# Generiert alle benötigten Secrets und bereitet die Konfiguration vor
# =============================================================================

set -e

echo "🚀 Matrix Stack Setup"
echo "===================="

# Prüfe ob .env existiert
if [ ! -f .env ]; then
    echo "📋 Kopiere .env.example nach .env..."
    cp .env.example .env
fi

# Funktion zum Generieren von Secrets
generate_secret() {
    openssl rand -hex 32
}

echo ""
echo "🔐 Generiere Secrets..."
echo ""

# Secrets generieren und ausgeben
echo "Kopiere diese Werte in deine .env Datei:"
echo ""
echo "DB_PASSWORD=$(generate_secret)"
echo "REGISTRATION_SECRET=$(generate_secret)"
echo "MACAROON_SECRET=$(generate_secret)"
echo "FORM_SECRET=$(generate_secret)"
echo "WHATSAPP_AS_TOKEN=$(generate_secret)"
echo "WHATSAPP_HS_TOKEN=$(generate_secret)"
echo "TELEGRAM_AS_TOKEN=$(generate_secret)"
echo "TELEGRAM_HS_TOKEN=$(generate_secret)"

echo ""
echo "===================="
echo "📝 NÄCHSTE SCHRITTE:"
echo "===================="
echo ""
echo "1. Kopiere die obigen Secrets in deine .env Datei"
echo ""
echo "2. Telegram API Credentials holen:"
echo "   → https://my.telegram.org → API development tools"
echo "   → TELEGRAM_API_ID und TELEGRAM_API_HASH eintragen"
echo ""
echo "3. Telegram Bot erstellen:"
echo "   → @BotFather auf Telegram → /newbot"
echo "   → TELEGRAM_BOT_TOKEN eintragen"
echo ""
echo "4. Slack App erstellen:"
echo "   → https://api.slack.com/apps → Create New App"
echo "   → Bot Token Scopes: channels:history, channels:read, chat:write, users:read"
echo "   → SLACK_BOT_TOKEN (xoxb-...) eintragen"
echo ""
echo "5. DNS Records anlegen (alle auf Server-IP):"
echo "   → ng-automation.de (für .well-known)"
echo "   → matrix.ng-automation.de (Synapse)"
echo "   → chat.ng-automation.de (Element)"
echo ""
echo "6. In Coolify deployen!"
echo ""
