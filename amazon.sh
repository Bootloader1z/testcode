#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install dependencies for Docker
echo "Installing dependencies for Docker..."
sudo amazon-linux-extras install docker -y

# Start and enable Docker service
echo "Starting and enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version

# Install Nginx
echo "Installing Nginx..."
sudo yum install -y nginx

# Start and enable Nginx service
echo "Starting and enabling Nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Create a basic Nginx configuration file
echo "Creating Nginx config file..."
sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF
user nginx;
worker_processes auto;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name _;

        root /usr/share/nginx/html;
        index index.html index.htm;

        location / {
            try_files \$uri \$uri/ =404;
        }
    }
}
EOF

# Restart Nginx to apply configuration changes
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Set up a Docker container with Nginx
echo "Pulling latest Nginx Docker image..."
docker pull nginx:latest

# Run Docker container with Nginx
echo "Running Nginx Docker container..."
docker run -d -p 8080:80 --name nginx-container nginx

# Verify Docker container is running
echo "Verifying Docker container..."
docker ps

# Create a custom index.html to serve on Nginx (via Docker)
echo "Creating a custom index.html to serve from Nginx Docker container..."
echo "<html><body><h1>Hello from Docker Nginx!</h1></body></html>" | sudo tee /usr/share/nginx/html/index.html

# Set permissions for index.html file
sudo chmod 755 /usr/share/nginx/html/index.html

# Restart the Nginx Docker container to apply custom HTML
echo "Restarting Docker container to apply custom index.html..."
docker restart nginx-container

# Display the IP address of the VPS
ip_address=$(hostname -I | awk '{print $1}')
echo "Your VPS IP address is: $ip_address"

# Display final message
echo "Setup completed! You can access your Nginx server via http://$ip_address:8080"
echo "Docker is running the Nginx container, and Nginx is serving a custom index page."

# End of setup
echo "Setup script completed successfully!"
