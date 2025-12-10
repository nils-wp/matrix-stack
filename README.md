# Matrix Stack für Coolify

Komplettes Matrix-Setup mit Synapse, Element Web und drei Bridges (WhatsApp, Telegram, Slack) für Coolify.

## Komponenten

| Service | Image | Port | Funktion |
|---------|-------|------|----------|
| Synapse | matrixdotorg/synapse | 8008 | Matrix Homeserver |
| Element | vectorim/element-web | 80 | Web Client |
| PostgreSQL | postgres:15-alpine | 5432 | Datenbank |
| mautrix-whatsapp | dock.mau.dev/mautrix/whatsapp | 29318 | WhatsApp Bridge |
| mautrix-telegram | dock.mau.dev/mautrix/telegram | 29317 | Telegram Bridge |
| Matterbridge | 42wim/matterbridge | - | Slack Bridge |
| Nginx | nginx:alpine | 80 | .well-known Delegation |

## Voraussetzungen

- Hetzner CX31 (8GB RAM) oder besser
- Coolify installiert
- 3 Subdomains:
  - `ng-automation.de` (Basis für User-IDs)
  - `matrix.ng-automation.de` (Synapse API)
  - `chat.ng-automation.de` (Element Web)

## Setup in 6 Schritten

### 1. Repository forken

Fork dieses Repo auf deinen GitHub Account.

### 2. Secrets generieren

```bash
chmod +x setup.sh
./setup.sh
```

Kopiere die generierten Secrets in `.env`.

### 3. Externe Credentials holen

**Telegram:**
1. https://my.telegram.org → API development tools
2. App erstellen → API_ID und API_HASH kopieren
3. @BotFather → /newbot → Bot Token kopieren

**Slack:**
1. https://api.slack.com/apps → Create New App
2. OAuth & Permissions → Bot Token Scopes hinzufügen:
   - `channels:history`
   - `channels:read`
   - `chat:write`
   - `users:read`
3. Install to Workspace → Bot Token (xoxb-...) kopieren

### 4. DNS Records anlegen

Bei IONOS (oder deinem DNS-Provider):

| Typ | Host | Ziel |
|-----|------|------|
| A | @ | SERVER_IP |
| A | matrix | SERVER_IP |
| A | chat | SERVER_IP |

### 5. In Coolify deployen

1. **Projekt erstellen** → "Matrix" oder ähnlich
2. **Resource hinzufügen** → GitHub Repository
3. **Build Type**: Docker Compose
4. **Environment Variables**: Developer View → .env Inhalt einfügen
5. **Deploy**

### 6. Post-Deployment

Nach erfolgreichem Deployment:

```bash
# Admin-User anlegen
docker exec -it matrix-synapse register_new_matrix_user \
  -u admin \
  -p SICHERES_PASSWORT \
  -a \
  -c /data/homeserver.yaml \
  http://localhost:8008

# Matterbridge User für Slack-Bridge anlegen
docker exec -it matrix-synapse register_new_matrix_user \
  -u matterbridge \
  -p MATTERBRIDGE_PASSWORD_AUS_ENV \
  -c /data/homeserver.yaml \
  http://localhost:8008
```

## Bridge-Nutzung

### WhatsApp

1. Element öffnen → Chat mit `@whatsappbot:ng-automation.de` starten
2. `login` eingeben
3. QR-Code scannen mit WhatsApp auf dem Handy
4. Fertig - alle WhatsApp Chats erscheinen als Matrix Räume

### Telegram

1. Element öffnen → Chat mit `@telegrambot:ng-automation.de` starten
2. `login` eingeben
3. Telegram-Nummer eingeben → Code bestätigen
4. Fertig - Telegram Chats werden synchronisiert

### Slack (via Matterbridge)

Matterbridge verbindet konfigurierte Channels automatisch. Anpassungen in `bridges/matterbridge/matterbridge.toml`:

```toml
[[gateway]]
name = "kunden-bridge"
enable = true

[[gateway.inout]]
account = "slack.ng-slack"
channel = "extern-kunden"

[[gateway.inout]]
account = "matrix.ng-matrix"
channel = "#kunden:ng-automation.de"
```

## Backup

Kritische Daten:
- `/data/signing.key` - **NIEMALS VERLIEREN** (Federation-Identität)
- PostgreSQL Datenbank
- Bridge Datenbanken in `/data/`

```bash
# Backup Script
docker exec matrix-postgres pg_dump -U synapse synapse > backup.sql
docker cp matrix-synapse:/data/signing.key ./signing.key.backup
```

## Troubleshooting

### Federation testen
https://federationtester.matrix.org/?server=ng-automation.de

### Logs prüfen
```bash
docker logs matrix-synapse -f
docker logs matrix-whatsapp -f
docker logs matrix-telegram -f
```

### Synapse Health Check
```bash
curl https://matrix.ng-automation.de/health
```

## Ressourcen

- [Synapse Admin API](https://element-hq.github.io/synapse/latest/usage/administration/admin_api/)
- [mautrix-whatsapp Docs](https://docs.mau.fi/bridges/go/whatsapp/)
- [mautrix-telegram Docs](https://docs.mau.fi/bridges/python/telegram/)
- [Matterbridge Wiki](https://github.com/42wim/matterbridge/wiki)
