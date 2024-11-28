#Bloodhound CE Install Script
#!/bin/bash

# Variables
COMPOSE_FILE="/root/docker-compose.yml"
PASSWORD_REGEX="Initial Password Set To:\s+([A-Za-z0-9]+)"
MAX_WAIT=300  # Maximum wait time in seconds for service to become available
CHECK_INTERVAL=5  # Time interval between service availability checks

# Function to check command availability
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: $1 is not installed. Installing..."
        sudo apt-get install -y "$1"
    fi
}

# Step 1: Install Docker and Docker Compose
install_docker() {
    echo "Updating package lists and installing required packages..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl apt-transport-https software-properties-common

    echo "Installing Docker and Docker Compose..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "Docker installation completed."
}

# Step 2: Download the docker-compose.yml file
download_compose_file() {
    echo "Downloading BloodHound docker-compose.yml file..."
    curl -L https://ghst.ly/getbhce -o "$COMPOSE_FILE"
    echo "docker-compose.yml downloaded to $COMPOSE_FILE."
}

# Step 3: Modify the docker-compose.yml file to expose BloodHound on 0.0.0.0
update_compose_file() {
    echo "Updating docker-compose.yml to expose BloodHound on 0.0.0.0..."
    sed -i 's/${BLOODHOUND_HOST:-127.0.0.1}/${BLOODHOUND_HOST:-0.0.0.0}/g' "$COMPOSE_FILE"
    echo "docker-compose.yml updated."
}

# Step 4: Deploy the Docker Compose stack
deploy_stack() {
    echo "Deploying the BloodHound stack..."
    docker compose -f "$COMPOSE_FILE" pull
    docker compose -f "$COMPOSE_FILE" up -d
}

# Step 5: Wait for BloodHound service to become available on port 8080
wait_for_service() {
    echo "Waiting for BloodHound service to become available on port 8080..."
    local_ip=$(hostname -I | awk '{print $1}')
    elapsed=0
    while [[ $elapsed -lt $MAX_WAIT ]]; do
        if nc -z "$local_ip" 8080; then
            echo "BloodHound service is now available on http://$local_ip:8080"
            return 0
        fi
        echo "Waiting... Elapsed: ${elapsed}s"
        sleep $CHECK_INTERVAL
        elapsed=$((elapsed + CHECK_INTERVAL))
    done

    echo "Error: BloodHound service did not become available within $MAX_WAIT seconds. Check the logs for more details."
    docker compose -f "$COMPOSE_FILE" logs
    exit 1
}

# Step 6: Retrieve the initial password from logs
get_initial_password() {
    echo "Retrieving the initial password from logs..."
    password=$(docker compose -f "$COMPOSE_FILE" logs | grep -oP "$PASSWORD_REGEX" | awk '{print $NF}')
    if [[ -z "$password" ]]; then
        echo "Error: Could not retrieve the initial password. Check the logs manually."
        docker compose -f "$COMPOSE_FILE" logs
        exit 1
    fi
    echo "Initial Password: $password"
}

# Step 7: Create a systemd service for auto-start
setup_systemd_service() {
    echo "Setting up systemd service for auto-start..."
    sudo bash -c 'cat > /etc/systemd/system/docker-compose-app.service <<EOF
[Unit]
Description=Docker Compose Application Service
Documentation=https://docs.docker.com/compose/
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/root
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF'

    sudo systemctl daemon-reload
    sudo systemctl enable docker-compose-app.service
    sudo systemctl start docker-compose-app.service
    echo "Systemd service created and started."
}

# Main execution flow
main() {
    echo "Starting BloodHound Community Edition setup..."

    # Ensure prerequisites are installed
    sudo apt-get update
    check_command "curl"
    check_command "nc"  # Ensure netcat is available for port checks

    # Perform setup steps
    install_docker
    download_compose_file
    update_compose_file
    deploy_stack
    wait_for_service
    get_initial_password
    setup_systemd_service

    # Retrieve and display the local IP
    local_ip=$(hostname -I | awk '{print $1}')
    echo "Setup completed. Access BloodHound at http://$local_ip:8080/ui/login"
    echo "Use the initial password displayed above for the admin account."
}

main