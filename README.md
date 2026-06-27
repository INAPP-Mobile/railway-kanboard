# Kanboard

> Open-source Kanban project management — lightweight, self-hosted, and built with PHP.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/kanboard)

Kanboard is a free and open source Kanban project management software. It focuses on simplicity, speed, and a minimalistic approach — no complexity, no external dependencies. Manage your projects, tasks, and team workflow visually with an intuitive Kanban board.

---

## Features

- **Visual Kanban Boards** — Drag-and-drop task management
- **Project Management** — Multiple projects with swimlanes and categories
- **Task Analytics** — Burndown charts, time tracking, and statistics
- **Authentication** — LDAP, OAuth, and local accounts
- **Notifications** — Email, webhooks, and Slack integration
- **Multi-language** — 50+ supported languages
- **REST API** — Full API for integrations and automation
- **Plugins** — Extend functionality via the plugin system
- **No External Database Required** — Uses SQLite by default (zero config)

---

## Environment Variables

Kanboard is pre-configured for SQLite — deploy and start using it immediately. For production setups with MySQL or PostgreSQL, use the variables below.

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `80` | Application port (Railway sets this automatically) |
| `DB_DRIVER` | `sqlite` | Database driver: `sqlite`, `mysql`, or `postgres` |
| `DB_HOSTNAME` | — | Database hostname (required for MySQL/Postgres) |
| `DB_NAME` | `kanboard` | Database name (required for MySQL/Postgres) |
| `DB_USERNAME` | — | Database username (required for MySQL/Postgres) |
| `DB_PASSWORD` | — | Database password (required for MySQL/Postgres) |
| `DB_PORT` | — | Database port (optional, defaults to driver default) |
| `MAIL_FROM` | — | From address for email notifications |
| `MAIL_TRANSPORT` | `mail` | Mail transport: `smtp`, `sendmail`, or `mail` |
| `MAIL_SMTP_HOSTNAME` | — | SMTP server hostname |
| `MAIL_SMTP_PORT` | `25` | SMTP server port |
| `MAIL_SMTP_USERNAME` | — | SMTP username |
| `MAIL_SMTP_PASSWORD` | — | SMTP password |
| `MAIL_SMTP_ENCRYPTION` | — | SMTP encryption: `tls` or `ssl` |
| `PLUGIN_INSTALLER` | `false` | Enable the plugin installer from the UI (`true`/`false`) |
| `DEBUG` | `false` | Enable debug mode (`true`/`false`) |

---

## Architecture

```
┌─────────────────────────────────────┐
│          Railway Edge               │
│     (TLS termination, routing)      │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│          Nginx (port $PORT)          │
│    Reverse proxy + static assets     │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│     PHP-FPM (Kanboard Application)  │
│   Kanban logic, REST API, Auth      │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│  Persistent Volume (kanboard-data)  │
│  /var/www/app/data                   │
│  └─── SQLite database               │
│  └─── File uploads                  │
│  └─── Cache                         │
└─────────────────────────────────────┘
```

### Persistence

Kanboard stores all data in `/var/www/app/data`:
- **SQLite database** (`sqlite` directory) — tasks, projects, users
- **File uploads** (`files` directory) — attached files and images
- **Cache** (`cache` directory) — application cache
- **Logs** (`debug.log`) — debug logging when enabled

This directory is mounted as a Railway persistent volume, so your data survives redeploys.

---

## Configuration

Kanboard's configuration is managed through environment variables. The application reads from `/var/www/app/config.php` at startup, which is populated with defaults from the Docker image.

### Using SQLite (Default — No Additional Setup)

1. Deploy the template
2. Access the web UI
3. Default credentials: `admin` / `admin` (change immediately!)

### Using MySQL or PostgreSQL

1. Create a Railway MySQL or PostgreSQL database service
2. Link it to your Kanboard service
3. Set the following environment variables on the Kanboard service:

```
DB_DRIVER=mysql
DB_HOSTNAME=${{YourDatabaseService.MYSQLHOST}}
DB_NAME=${{YourDatabaseService.MYSQLDATABASE}}
DB_USERNAME=${{YourDatabaseService.MYSQLUSER}}
DB_PASSWORD=${{YourDatabaseService.MYSQLPASSWORD}}
DB_PORT=${{YourDatabaseService.MYSQLPORT}}
```

For PostgreSQL, use `DB_DRIVER=postgres` with the corresponding `PG*` variables.

---

## Default Credentials

| Role | Username | Password |
|------|----------|----------|
| Administrator | `admin` | `admin` |

**Important:** Change the default password immediately after first login.

---

## Troubleshooting

### "502 Bad Gateway" or "Connection refused"

- Check that the `PORT` environment variable is set (Railway sets this automatically)
- Verify the health check is targeting `/` — it redirects to `/dashboard` if everything is working
- Check Railway logs for PHP-FPM startup errors

### Health Check Failing

If the container health check is failing intermittently:

1. Ensure the `PORT` environment variable is exposed to the service
2. The `/healthcheck.php` endpoint confirms the app and database are operational
3. During first startup, migrations may take a few seconds — the health check has a 15-second grace period

### Plugin Installer

The plugin installer is **disabled by default** for security reasons. To enable it from the UI:

```
PLUGIN_INSTALLER=true
```

Then restart the service. You can install plugins from the **Administration > Plugins** menu.

### Database Connection Issues

If using MySQL or PostgreSQL:

1. Verify the credentials and hostname are correct
2. Ensure the database service is in the same Railway project
3. Check that the database server is accepting connections
4. Kanboard will run database migrations automatically on startup

---

## Resources

- [Kanboard Official Website](https://kanboard.org/)
- [Kanboard Documentation](https://docs.kanboard.org/)
- [Kanboard GitHub Repository](https://github.com/kanboard/kanboard)
- [Kanboard Docker Image](https://hub.docker.com/r/kanboard/kanboard)
- [Railway Documentation](https://docs.railway.app/)

---

## License

This template is provided under the MIT License. Kanboard itself is licensed under the MIT License.
