#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration - USER INPUT REQUIRED --- #
REPO_URL="${repo_url}" # Replace with your backend repository URL
GIT_USER_EMAIL="cortesbuitragoisac@gmail.com"            # Replace with your Git email
GIT_USER_NAME="cbisac"                   # Replace with your Git username

# Environment Variables for the Node.js Application
# ** IMPORTANT: Replace these with your actual production values! **
# ** Consider using a .env file for production and adding it to .gitignore **
APP_NODE_ENV="production"
APP_PORT="3000" # Port your Node.js app will listen on
APP_CORS_ORIGIN=${app_cors_origin} # Your frontend URL for CORS
APP_SECRET_KEY="${app_secret_key}"     # Strong secret for JWT

# Database Connection Environment Variables
DB_HOST="${db_endpoint}"         # e.g., AWS RDS endpoint
DB_PORT="5432"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"
# DB_SSL="true" # Uncomment if you need to force SSL outside of NODE_ENV=production logic

# Attempt to instruct the application to disable SSL for the database connection.
# Your application's Sequelize configuration must be set up to recognize this variable.
export DB_SSL_MODE=disable

# Allow self-signed certificates from RDS in production mode for this specific deployment
# IMPORTANT: Review security implications for your environment.
export NODE_TLS_REJECT_UNAUTHORIZED=0

# --- Deployment Steps --- #
echo "Starting backend deployment process..."

# 1. Update package list
echo "Updating package list..."
sudo apt-get update -y

# 2. Install dependencies
echo "Installing Git, Node.js (18.x), and PostgreSQL client..."
sudo apt-get install -y postgresql-client

# Install Node.js (using NodeSource)
if ! command -v node > /dev/null || ! node -v | grep -q "v18"; then # Checks if node is not installed or not v18
    echo "Node.js 18.x not found, installing..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js 18.x is already installed."
fi

# 3. Configure Git
echo "Configuring Git globally..."
export HOME=/root # Explicitly set HOME for the root user
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
# If your repo is private and uses HTTPS with username/password or PAT:
# git config --global credential.helper store # This will store credentials in plain text. Use with caution or use SSH keys.

# 4. Clone or update the repository
REPO_DIR_NAME=$(basename "$REPO_URL" .git)
echo "Cloning/updating repository: $REPO_URL"
if [ -d "$REPO_DIR_NAME" ]; then
    echo "Repository directory exists. Pulling latest changes..."
    cd "$REPO_DIR_NAME"
    git pull
    cd ..
else
    echo "Cloning new repository..."
    git clone "$REPO_URL"
fi

# 5. Navigate to the backend directory
# Assuming your backend code is in a subdirectory like 'BackEnd' within the repo
# If your repo root IS the backend code, remove '/BackEnd' from the cd command.
if [ ! -d "$REPO_DIR_NAME/BackEnd" ]; then
    echo "Error: BackEnd directory not found in the repository."
    exit 1
fi
cd "$REPO_DIR_NAME/BackEnd"
chmod -R 777 .
echo "Current directory: $(pwd)"

# 6. Install application dependencies
echo "Installing npm dependencies..."
npm install --production # --production flag skips devDependencies

# 7. Set environment variables for the application
# These are exported for the current session. For long-running processes,
# using a .env file loaded by your app (e.g., with dotenv package) or
# a process manager's environment configuration is recommended.
echo "Exporting environment variables for the application..."
export NODE_ENV="$APP_NODE_ENV"
export PORT="$APP_PORT"
export CORS_ORIGIN="$APP_CORS_ORIGIN"
export SECRET_KEY="$APP_SECRET_KEY"
export DB_HOST="$DB_HOST"
export DB_PORT="$DB_PORT"
export DB_NAME="$DB_NAME"
export DB_USER="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"

echo "--- Verifying Environment Variables ---"
echo "NODE_ENV: $NODE_ENV"
echo "PORT: $PORT"
echo "CORS_ORIGIN: $CORS_ORIGIN"
echo "SECRET_KEY: $SECRET_KEY" # Be cautious with echoing sensitive keys in production logs
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"
echo "DB_PASSWORD: <hidden>" # Avoid printing actual password
echo "DB_SSL_MODE: $DB_SSL_MODE" # Verify it's set
echo "NODE_TLS_REJECT_UNAUTHORIZED: $NODE_TLS_REJECT_UNAUTHORIZED" # Verify it's set
echo "-------------------------------------"

echo "NODE_ENV is set to: $NODE_ENV"

# 8. Start the server
echo "Starting the Node.js server..."
# Basic start using node:
# node index.js &
# disown %1 # Detach from terminal, but this is not robust for production.

# ** RECOMMENDATION FOR PRODUCTION: Use a process manager like PM2 **
# If PM2 is installed, you can use it to manage your application:
# sudo npm install -g pm2 # Install PM2 globally if not already installed
# pm2 stop index --silent || true # Stop if already running
# pm2 delete index --silent || true # Delete if already exists
# pm2 start index.js --name "my-backend-app" --watch # Example PM2 start command
# pm2 startup # To make PM2 restart apps on server reboot
# pm2 save # Save current process list

# For this script, we'll use a simple direct start for now.
# Ensure you have a mechanism to keep it running (e.g., PM2, systemd, screen/tmux for testing).

# To run directly and see output (will stop if terminal closes):
# node index.js

# To run in background (very basic, not recommended for production without a process manager):
if pgrep -f "node src/index.js" > /dev/null; then
    echo "Server seems to be already running. Killing existing process..."
    pkill -f "node src/index.js"
fi

# Ensure the critical environment variables are passed directly to the node process started by nohup
echo "Starting server with: nohup env NODE_TLS_REJECT_UNAUTHORIZED=$NODE_TLS_REJECT_UNAUTHORIZED DB_SSL_MODE=$DB_SSL_MODE node src/index.js"
nohup env NODE_TLS_REJECT_UNAUTHORIZED=$NODE_TLS_REJECT_UNAUTHORIZED DB_SSL_MODE=$DB_SSL_MODE node src/index.js > app.log 2>&1 &
echo "Server started with nohup. Output is in app.log. PID: $!"

echo "--------------------------------------------------------------------"
echo "Backend deployment script finished."
echo "Application should be running on port $APP_PORT (if configured)."
echo "Access logs (if using nohup): cat app.log"
echo "Consider using PM2 for production process management."
echo "Ensure firewall (e.g., ufw) allows traffic on port $APP_PORT."
echo "--------------------------------------------------------------------"
