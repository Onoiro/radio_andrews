# 🎵 Radio Andrews

Simple internet radio station built with Python, Flask, Icecast, and Liquidsoap.

![Python](https://img.shields.io/badge/python-3.11+-blue.svg)
![Flask](https://img.shields.io/badge/flask-3.0+-green.svg)
![Docker](https://img.shields.io/badge/docker-compose-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

- 🎶 **Live streaming** — 24/7 internet radio with MP3 support
- 📡 **Real-time metadata** — current track info via REST API
- 📱 **Responsive design** — works on desktop and mobile
- 🗃️ **Track database** — SQLite with automatic MP3 tag scanning
- 🐳 **Docker ready** — easy deployment with Docker Compose

## Live Demo

🔊 **Listen now:** [https://radio.2-way.ru](https://radio.2-way.ru)

## Tech Stack

| Component | Technology |
|-----------|------------|
| Streaming server | [Icecast 2.4](https://icecast.org/) |
| Audio source | [Liquidsoap 2.2](https://www.liquidsoap.info/) |
| Backend API | [Flask 3.0](https://flask.palletsprojects.com/) |
| Database | SQLite + SQLAlchemy |
| Frontend | Vanilla HTML/CSS/JS |
| Package manager | [uv](https://github.com/astral-sh/uv) |
| Containerization | Docker Compose |

## Quick Start

### Prerequisites

- Python 3.11+
- Docker & Docker Compose
- [uv](https://github.com/astral-sh/uv) (Python package manager)

### Local Development

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/radio_andrews.git
cd radio_andrews

# Install dependencies
uv sync

# Add MP3 files to music folder
cp /path/to/your/*.mp3 music/

# Create shared directory
mkdir -p shared
chmod 777 shared

# Start services
make up

# Scan music files
make db-scan

# Open player
make serve
# Visit http://localhost:8080

Available Endpoints
URL	Description
http://localhost:8080	Web player
http://localhost:8000/stream	Direct audio stream
http://localhost:5000/api/current	Current track info
http://localhost:5000/api/tracks	All tracks list
http://localhost:5000/api/health	Health check
Project Structure

text

radio_andrews/
├── src/radio_andrews/     # Python source code
│   ├── api/               # Flask API endpoints
│   ├── services/          # Business logic
│   ├── app.py             # Flask application factory
│   ├── config.py          # Configuration
│   └── models.py          # SQLAlchemy models
├── config/                # Icecast & Liquidsoap configs
├── static/                # Frontend files
├── music/                 # MP3 files (not in git)
├── tests/                 # Pytest tests
├── docker-compose.yml     # Local development
└── docker-compose.prod.yml # Production

Production Deployment
1. Server Setup

Bash

# Clone on server
git clone https://github.com/YOUR_USERNAME/radio_andrews.git
cd radio_andrews

# Create environment file
cp .env.example .env
nano .env  # Edit with your passwords

# Create directories
mkdir -p shared data music
chmod 777 shared

2. SSH Configuration (local machine)

Add to ~/.ssh/config:

text

Host radio-prod
    HostName YOUR_SERVER_IP
    User YOUR_USERNAME
    Port YOUR_SSH_PORT

3. Upload Music

Bash

# From local machine
scp music/*.mp3 radio-prod:~/radio_andrews/music/

4. Start Services

Bash

# On server
make deploy
make deploy-scan

5. Nginx Configuration

Create /etc/nginx/conf.d/radio.example.com.conf:

nginx

server {
    listen 80;
    server_name radio.example.com;

    location / {
        root /path/to/radio_andrews/static;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:5001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /stream {
        proxy_pass http://127.0.0.1:8002/stream;
        proxy_buffering off;
        proxy_read_timeout 24h;
    }
}

6. SSL Certificate

Bash

sudo certbot --nginx -d radio.example.com

Development Commands

Bash

# Local development
make up              # Start containers
make down            # Stop containers
make logs            # View logs
make serve           # Start frontend dev server

# Database
make db-scan         # Scan music folder
make db-tracks       # List all tracks

# Code quality
make lint            # Run linter
make test            # Run tests
make format          # Format code

# Production (run on server)
make deploy          # Build and start
make deploy-logs     # View logs
make deploy-scan     # Scan music

API Examples
Get Current Track

Bash

curl https://radio.example.com/api/current

JSON

{
  "title": "Song Title",
  "artist": "Artist Name",
  "elapsed": 125,
  "duration": 240
}

Configuration
Environment Variables
Variable	Description	Default
FLASK_ENV	Environment (development/production)	production
DATABASE_URL	SQLite database path	sqlite:///data/radio.db
CURRENT_TRACK_FILE	Track metadata file	/shared/current_track.json
MUSIC_FOLDER	Path to MP3 files	/music
ICECAST_URL	Icecast server URL	http://icecast:8000
Icecast Passwords

Set in .env file:

text

ICECAST_SOURCE_PASSWORD=your_source_password
ICECAST_ADMIN_PASSWORD=your_admin_password
ICECAST_RELAY_PASSWORD=your_relay_password

Contributing

    Fork the repository
    Create your feature branch (git checkout -b feature/amazing-feature)
    Run tests (make test)
    Commit your changes (git commit -m 'Add amazing feature')
    Push to the branch (git push origin feature/amazing-feature)
    Open a Pull Request

License

This project is licensed under the MIT License - see the LICENSE file for details.
Author

Andrews — radio.2-way.ru


---

## LICENSE файл

```bash
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Andrews

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
