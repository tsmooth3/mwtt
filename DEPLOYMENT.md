# Deployment Options for MWTT

This guide covers deployment options for both Docker host and LXC container environments.

## Option 1: Kamal Deployment (Recommended) 🚀

**Best for:** Docker host or LXC container with Docker installed

Kamal is Rails 8's modern deployment tool. It handles:
- Docker image building and pushing
- Zero-downtime deployments
- SSL certificates (Let's Encrypt)
- Environment variables and secrets
- Health checks and rollbacks

### Setup Steps:

1. **Install Docker on your host/LXC container:**
   ```bash
   # On Ubuntu/Debian
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

2. **Configure `config/deploy.yml`:**
   - Update `servers.web` with your server IP
   - Update `image` with your Docker registry (or use local registry)
   - Update `proxy.host` with your domain
   - Configure database connection

3. **Set up secrets:**
   ```bash
   mkdir -p .kamal
   echo "your_rails_master_key_here" > .kamal/secrets/RAILS_MASTER_KEY
   echo "your_registry_password" > .kamal/secrets/KAMAL_REGISTRY_PASSWORD
   ```

4. **Deploy:**
   ```bash
   bin/kamal setup    # First time setup
   bin/kamal deploy   # Deploy updates
   ```

### For LXC with Docker:
- Install Docker inside the LXC container
- Configure LXC to allow Docker (may need privileged container or nested containers)
- Follow Kamal setup as above

---

## Option 2: Docker Compose

**Best for:** Simple single-server deployments

### Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: mwtt_production
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"

  web:
    build: .
    command: ./bin/thrust ./bin/rails server
    environment:
      RAILS_ENV: production
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY}
      DATABASE_URL: postgresql://${DB_USERNAME}:${DB_PASSWORD}@db:5432/mwtt_production
    volumes:
      - storage_data:/rails/storage
    ports:
      - "80:80"
    depends_on:
      - db

volumes:
  postgres_data:
  storage_data:
```

### Deploy:
```bash
# Build and start
docker-compose up -d

# Run migrations
docker-compose exec web bin/rails db:migrate

# View logs
docker-compose logs -f web
```

---

## Option 3: Direct LXC Deployment (No Docker)

**Best for:** LXC containers without Docker, or if you prefer native deployment

### Setup Steps:

1. **Create LXC container:**
   ```bash
   lxc launch ubuntu:22.04 mwtt-app
   lxc exec mwtt-app -- bash
   ```

2. **Install dependencies:**
   ```bash
   apt update
   apt install -y ruby-full postgresql postgresql-contrib nginx nodejs npm
   gem install bundler
   ```

3. **Clone and setup app:**
   ```bash
   git clone your-repo-url /var/www/mwtt
   cd /var/www/mwtt
   bundle install
   ```

4. **Configure database:**
   ```bash
   # Edit /etc/postgresql/14/main/pg_hba.conf if needed
   sudo -u postgres createuser -s mwtt
   sudo -u postgres createdb mwtt_production
   ```

5. **Setup Rails:**
   ```bash
   RAILS_ENV=production bin/rails db:create db:migrate
   RAILS_ENV=production bin/rails assets:precompile
   ```

6. **Configure systemd service:**
   Create `/etc/systemd/system/mwtt.service`:
   ```ini
   [Unit]
   Description=MWTT Rails App
   After=network.target postgresql.service

   [Service]
   Type=simple
   User=www-data
   WorkingDirectory=/var/www/mwtt
   Environment="RAILS_ENV=production"
   Environment="RAILS_MASTER_KEY=your_master_key"
   ExecStart=/usr/local/bin/bundle exec puma -C config/puma.rb
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

7. **Start service:**
   ```bash
   systemctl enable mwtt
   systemctl start mwtt
   ```

8. **Configure Nginx reverse proxy:**
   Create `/etc/nginx/sites-available/mwtt`:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://127.0.0.1:3000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

---

## Database Options

### Option A: PostgreSQL in Docker (with Kamal/Docker Compose)
Use Kamal's `accessories` section or Docker Compose service.

### Option B: External PostgreSQL
- Install PostgreSQL on host or separate LXC container
- Update `config/database.yml` with connection details
- Use Rails credentials for passwords

### Option C: Managed Database
- Use a managed PostgreSQL service (AWS RDS, DigitalOcean, etc.)
- Update connection string in credentials

---

## SSL/HTTPS Setup

### With Kamal:
- Automatic via Let's Encrypt (configure `proxy.ssl: true`)

### With Docker Compose or LXC:
- Use Nginx with Let's Encrypt (Certbot)
- Or use Cloudflare for SSL termination

---

## Recommendations

1. **Docker Host:** Use **Kamal** - it's the most modern and feature-complete
2. **LXC Container:** 
   - If Docker is available: Use **Kamal**
   - If no Docker: Use **Direct LXC** deployment
   - For simplicity: Use **Docker Compose** if you can install Docker

---

## Quick Start with Kamal

1. Update `config/deploy.yml`:
   ```yaml
   servers:
     web:
       - your-server-ip-or-hostname
   
   proxy:
     ssl: true
     host: your-domain.com
   ```

2. Set secrets:
   ```bash
   mkdir -p .kamal/secrets
   echo "$(cat config/master.key)" > .kamal/secrets/RAILS_MASTER_KEY
   ```

3. Deploy:
   ```bash
   bin/kamal setup
   bin/kamal deploy
   ```

For more details, see: https://kamal-deploy.org
