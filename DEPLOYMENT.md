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

The `docker-compose.yml` file is already created in the repository. The Dockerfile copies your code into the Docker image during the build process, so you need to clone the repo on your Docker server.

### Deployment Workflow:

**1. On your Docker server, clone the repository:**
```bash
# SSH into your Docker server
ssh user@your-docker-server

# Clone the repo (or navigate to existing clone)
git clone git@github.com:tsmooth3/mwtt.git
cd mwtt

# Pull latest changes (for updates)
git pull origin main
```

**2. Set up Rails credentials:**

Rails credentials work in production! The encrypted file (`config/credentials.yml.enc`) is already in the repo. You just need to copy the master key to decrypt it.

**Option A: Copy master.key file (recommended)**
```bash
# On your local machine, securely copy the master key to the server
scp config/master.key user@your-docker-server:/path/to/mwtt/config/master.key

# On the server, set proper permissions
chmod 600 config/master.key
```

**Option B: Use RAILS_MASTER_KEY environment variable**
```bash
# On your local machine, get the master key value
cat config/master.key

# On the server, create .env file with the master key
cat > .env << EOF
RAILS_MASTER_KEY=<paste_the_master_key_value_here>
DB_USERNAME=mwtt
DB_PASSWORD=your_secure_password_here
EOF

chmod 600 .env
```

**Note:** The `docker-compose.yml` uses `RAILS_MASTER_KEY` from the `.env` file, so Option B works automatically. If you use Option A (copy the file), you can still set `RAILS_MASTER_KEY` in `.env` as a backup, or mount the file as a volume.

**3. Configure external PostgreSQL connection:**

The `docker-compose.yml` is configured to use an **external PostgreSQL server** on your host (not a container). This avoids port conflicts.

**Option A: Using host.docker.internal (recommended)**
```bash
# Create .env file with database connection
cat > .env << EOF
RAILS_MASTER_KEY=$(cat config/master.key)
DB_HOST=host.docker.internal
DB_USERNAME=mwtt
DB_PASSWORD=your_secure_password_here
DB_PORT=5432
EOF

chmod 600 .env
```

**Option B: Using host's IP address**
```bash
# Find your host's Docker bridge IP (usually 172.17.0.1)
ip addr show docker0 | grep inet

# Or use your server's actual IP
cat > .env << EOF
RAILS_MASTER_KEY=$(cat config/master.key)
DB_HOST=172.17.0.1  # or your server's IP
DB_USERNAME=mwtt
DB_PASSWORD=your_secure_password_here
DB_PORT=5432
EOF

chmod 600 .env
```

**Option C: Using network_mode: host**
If `host.docker.internal` doesn't work, you can use host networking:
```bash
# Edit docker-compose.yml and uncomment: network_mode: host
# Then use localhost in .env
cat > .env << EOF
RAILS_MASTER_KEY=$(cat config/master.key)
DB_HOST=localhost
DB_USERNAME=mwtt
DB_PASSWORD=your_secure_password_here
DB_PORT=5432
EOF
```

**Important:** Make sure your PostgreSQL server allows connections from Docker:
```bash
# Edit PostgreSQL config (usually /etc/postgresql/*/main/pg_hba.conf)
# Add line to allow Docker network:
host    all    all    172.17.0.0/16    md5

# Or if using network_mode: host, ensure localhost is allowed:
host    all    all    127.0.0.1/32    md5

# Restart PostgreSQL
sudo systemctl restart postgresql
```

**4. Edit Rails credentials (optional - if you prefer credentials over .env):**
```bash
# On the server, edit credentials to add production database settings
EDITOR="nano" bin/rails credentials:edit

# Add production database credentials:
# database:
#   username: mwtt
#   password: your_secure_password_here
#   host: host.docker.internal  # or localhost if using network_mode: host
#   port: 5432
```

**5. Build and start services:**
```bash
# Build the Docker images (this copies code into the image)
docker-compose build

# Start services in background
docker-compose up -d

# Check status
docker-compose ps
```

**6. Prepare external PostgreSQL database:**
```bash
# On the host (not in Docker), create database and user
sudo -u postgres psql

# In PostgreSQL console:
CREATE DATABASE mwtt_production;
CREATE USER mwtt WITH PASSWORD 'your_secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE mwtt_production TO mwtt;
\q
```

**7. Run database setup in container:**
```bash
# Create database and run migrations (from Docker container)
docker-compose exec web bin/rails db:create
docker-compose exec web bin/rails db:migrate

# (Optional) Seed database
docker-compose exec web bin/rails db:seed
```

**8. View logs:**
```bash
# View all logs
docker-compose logs -f

# View only web logs
docker-compose logs -f web

# View only database logs
docker-compose logs -f db
```

### Testing Database Connection:

Before starting the web service, test the connection:
```bash
# Test connection from container to host PostgreSQL
docker-compose run --rm web bin/rails db:version

# Or test with psql from container (if installed)
docker-compose run --rm web sh -c "PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -U \$DB_USERNAME -d postgres -c 'SELECT version();'"
```

### Troubleshooting Database Connection:

**If connection fails:**
1. **Check PostgreSQL is listening on the right interface:**
   ```bash
   sudo netstat -tlnp | grep 5432
   # Should show 0.0.0.0:5432 or 127.0.0.1:5432
   ```

2. **Check PostgreSQL config (`postgresql.conf`):**
   ```bash
   # Should have: listen_addresses = '*' or 'localhost'
   grep listen_addresses /etc/postgresql/*/main/postgresql.conf
   ```

3. **Check pg_hba.conf allows Docker network:**
   ```bash
   # Add this line if missing:
   host    all    all    172.17.0.0/16    md5
   ```

4. **Try different DB_HOST values:**
   - `host.docker.internal` (Docker Desktop, newer Docker)
   - `172.17.0.1` (default Docker bridge IP)
   - Your server's actual IP address
   - `localhost` (if using `network_mode: host`)

5. **Check firewall rules:**
   ```bash
   # Allow Docker network to access PostgreSQL
   sudo ufw allow from 172.17.0.0/16 to any port 5432
   ```

### Updating the Application:

When you make changes and push to git:

```bash
# On your Docker server
cd /path/to/mwtt
git pull origin main

# Rebuild the image (includes new code)
docker-compose build web

# Restart the web service
docker-compose up -d web

# Run migrations if needed
docker-compose exec web bin/rails db:migrate
```

### Useful Commands:

```bash
# Stop services
docker-compose down

# Stop and remove volumes (⚠️ deletes database!)
docker-compose down -v

# Restart a service
docker-compose restart web

# Execute Rails console
docker-compose exec web bin/rails console

# Execute bash shell in container
docker-compose exec web bash

# View resource usage
docker-compose stats
```

### Notes:

- The code is **baked into the Docker image** during `docker-compose build`
- You need to **rebuild the image** after pulling code changes
- Database data persists in Docker volumes (`postgres_data`, `storage_data`)
- The `.env` file stores secrets (make sure it's in `.gitignore`)

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
