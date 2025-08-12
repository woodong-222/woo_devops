#!/bin/bash

echo "Resetting secret configurations..."

if [ -f "setup.conf" ]; then
    echo "Resetting setup.conf..."
    
    sed -i 's/GITHUB_TOKEN=.*/GITHUB_TOKEN=YOUR_GITHUB_TOKEN_HERE/' setup.conf
    sed -i 's|DISCORD_WEBHOOK=https://discord.com/api/webhooks/.*|DISCORD_WEBHOOK=YOUR_DISCORD_WEBHOOK_URL_HERE|' setup.conf
    sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=your_password_here/' setup.conf
    sed -i 's/DB_ROOT_PASSWORD=.*/DB_ROOT_PASSWORD=your_root_password_here/' setup.conf
    sed -i 's/JENKINS_PASSWORD=.*/JENKINS_PASSWORD=your_jenkins_password_here/' setup.conf
    
    echo "setup.conf reset complete"
fi

for env_file in .env .env.local .env.production; do
    if [ -f "$env_file" ]; then
        echo "Resetting $env_file..."
        
        sed -i 's/API_KEY=.*/API_KEY=your_api_key_here/' "$env_file"
        sed -i 's/SECRET_KEY=.*/SECRET_KEY=your_secret_key_here/' "$env_file"
        sed -i 's/DATABASE_URL=.*/DATABASE_URL=your_database_url_here/' "$env_file"
        sed -i 's/JWT_SECRET=.*/JWT_SECRET=your_jwt_secret_here/' "$env_file"
        sed -i 's/GITHUB_TOKEN=.*/GITHUB_TOKEN=your_github_token_here/' "$env_file"
        
        echo "$env_file reset complete"
    fi
done

echo ""
echo "All secret configurations have been safely reset!"
echo ""
echo "Please configure the actual values:"
echo "   - GitHub Personal Access Token"
echo "   - Database passwords"
echo "   - Jenkins password"
echo "   - Discord Webhook URL (optional)"
echo ""