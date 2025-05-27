#!/bin/bash

# Exit on any error
set -e

echo "Starting frontend deployment process..."

# Update package list
echo "Updating package list..."
sudo apt-get update

# Configure Git globally
echo "Configuring Git..."
export HOME=/root # Explicitly set HOME for the root user
git config --global user.email "cortesbuitragoisac@gmail.com"
git config --global user.name "cbisac"

# Clone the repository
echo "Cloning the repository..."
# Replace with your repository URL
REPO_URL="${repo_url}"
REPO_NAME=$(basename $REPO_URL .git)

# Remove existing directory if it exists
if [ -d "$REPO_NAME" ]; then
    echo "Removing existing repository directory..."
    rm -rf "$REPO_NAME"
fi

git clone $REPO_URL
cd $REPO_NAME/FrontEnd

# Install Node.js and npm using nvm
echo "Installing Node.js and npm via nvm..."
if ! command -v nvm &> /dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
# Source nvm again to ensure it's available in this script session
\. "$NVM_DIR/nvm.sh"

nvm install 20.12.0
nvm use 20.12.0
nvm alias default 20.12.0 # Make this the default version

# Verify Node.js and npm versions
echo "Node.js version:"
node -v
echo "npm version:"
npm -v

# Install Apache if not installed
echo "Installing Apache..."
sudo apt-get install -y apache2

# Install required global npm packages
#echo "Installing specific Angular CLI version..."
#npm install -g @angular/cli@19.2.6

# Verify Angular CLI version
#echo "Angular CLI version:"
#ng version

# Set environment variables for production
# echo "Setting up environment variables..."
# export NODE_ENV=production
# export BACKEND_URL="${backend_app_url}"

# Navigate to the frontend directory (already done, but good to be clear)
# cd $REPO_NAME/FrontEnd # This was done earlier

#echo "Current directory for npm install: $(pwd)"
#ls -al # List files to ensure package.json is there and looks reasonable

#echo "Contents of package.json:"
#cat package.json # Output the package.json to see what npm is working with

# Clean up old dependencies and ensure correct permissions for the current directory
#echo "Cleaning up old dependencies (if any)..."
#rm -rf node_modules
#rm -f package-lock.json

# echo "Running npm cache clean --force (for extreme debugging)..."
# npm cache clean --force # Drastic step, usually not needed, but let's try

# echo "Installing project dependencies from $(pwd) with --dry-run first..."
# npm install --dry-run --verbose --legacy-peer-deps # See what npm WOULD do

# echo "Actually installing project dependencies from $(pwd)..."
# npm install --verbose --legacy-peer-deps # Keep verbose for now

# echo "Listing top-level contents of node_modules to check major Angular packages:"
# ls -al node_modules/@angular # Check if Angular core packages are present
# ls -al node_modules/@angular-devkit # Check if devkit packages are present

# # Build the Angular app for production
# echo "Building the application..."
# # Ensure nvm context for ng build and disable prompts
# . "$NVM_DIR/nvm.sh"
# export NG_CLI_ANALYTICS=ci # Ensure this is set before ng build
# nvm exec ng build --configuration=production

# Configure Apache
# echo "Configuring Apache..."

# # Create Apache virtual host configuration
# sudo tee /etc/apache2/sites-available/angular-app.conf << EOF
# <VirtualHost *:80>
#     ServerAdmin webmaster@localhost
#     DocumentRoot /var/www/html/angular-app

#     ErrorLog $${APACHE_LOG_DIR}/error.log
#     CustomLog $${APACHE_LOG_DIR}/access.log combined

#     <Directory /var/www/html/angular-app>
#         Options Indexes FollowSymLinks
#         AllowOverride All
#         Require all granted
#     </Directory>

#     # Angular routing configuration
#     <IfModule mod_rewrite.c>
#         RewriteEngine On
#         RewriteBase /
#         RewriteRule ^index\.html$ - [L]
#         RewriteCond %%{REQUEST_FILENAME} !-f
#         RewriteCond %%{REQUEST_FILENAME} !-d
#         RewriteRule . /index.html [L]
#     </IfModule>
# </VirtualHost>
# EOF

# # Enable required Apache modules
# echo "Enabling Apache modules..."
# sudo a2enmod rewrite
# sudo a2enmod headers

# # Create directory for the Angular app
# sudo mkdir -p /var/www/html/angular-app

# Copy built files to Apache directory
#echo "Copying built files to Apache directory..."
#sudo cp -r dist/front-end/browser/* /var/www/html/angular-app/

# Set proper permissions
echo "Setting proper permissions..."
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 777 /var/www/html/

# Enable the site and disable the default site
# echo "Enabling the site..."
# sudo a2dissite 000-default.conf
# sudo a2ensite angular-app.conf

# # Test Apache configuration
# echo "Testing Apache configuration..."
# sudo apache2ctl configtest

# # Restart Apache
# echo "Restarting Apache..."
# sudo systemctl restart apache2

echo "Deployment completed successfully!"
echo "Your application should now be accessible at http://your-server-ip"

# Add some basic error checking
if [ $? -eq 0 ]; then
    echo "Deployment successful! 🚀"
else
    echo "Deployment failed! Please check the logs for more information."
    exit 1
fi