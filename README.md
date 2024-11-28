# bloodhoundCEinstaller
Bloodhound CE install script


# BloodHound Community Edition (BHCE) Setup with Docker

## Overview

This guide explains how to set up BloodHound Community Edition (BHCE) in a lab environment using Docker and Docker Compose. It includes instructions for installation, running the application, and retrieving the generated password. The application is accessible via the web interface at [http://192.168.56.177:8080/ui/login](http://192.168.56.177:8080/ui/login).

---

## Prerequisites

Ensure the following are installed before proceeding:

- A Docker-compatible container runtime (e.g., Docker Desktop or Podman with Docker compatibility enabled)
- Docker Compose (included with Docker Desktop)

To simplify installation on Linux/Mac, use Docker's `apt` repository as described in the installation steps below.

---

## 1. Install Docker Engine and Docker Compose

Follow these steps to install Docker and Docker Compose on your system.

### Steps:

1. **Add Docker's official GPG key and apt repository:**
    
    ```bash
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    ```
    
2. **Install Docker Engine and Compose:**
    
    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```
    
3. **Verify the installation:**
    
    ```bash
    sudo docker run hello-world
    ```
    

---

## 2. Deploy BloodHound Community Edition

The simplest way to set up BHCE is to use the provided `docker-compose.yml` file.

### Quick Start (One-Liner)

For quick deployment, use the following one-line command:

```bash
curl -L https://ghst.ly/getbhce | docker compose -f - up
```

### Step-by-Step Deployment:

1. **Download the Docker Compose file:**
    
    ```bash
    curl -L https://ghst.ly/getbhce > docker-compose.yml
    ```
    
2. **Pull and start the containers:**
    
    ```bash
    docker compose pull
    docker compose up
    ```
    
3. **Retrieve the Admin Password:**
    
    - The admin password is **randomly generated** and displayed in the terminal output during the first run.
    - **Run without `-d` initially:** This allows you to see the password directly in the terminal.
        
        ```bash
        docker compose up
        ```
        
    - **If already started in detached mode (`-d`):** Use the following command to view the logs and locate the password:
        
        ```bash
        docker compose logs
        ```
        
4. **Optional: Start in Detached Mode** Once you have the password, you can start the containers in the background for future use:
    
    ```bash
    docker compose up -d
    ```
    

---

## 3. Resetting the Password

If the password is lost, it cannot be regenerated. To reset the password:

1. Stop and remove all containers and volumes:
    
    ```bash
    docker compose down -v
    ```
    
2. Restart the stack to generate a new password:
    
    ```bash
    docker compose up
    ```
    

---

## 4. Access the Application

1. Open a browser and navigate to: [http://192.168.56.177:8080/ui/login](http://192.168.56.177:8080/ui/login)
2. Log in with:
    - **Username:** `admin`
    - **Password:** The randomly generated password retrieved from the logs.

---

## 5. Systemd Auto-Start Configuration

To ensure the Docker Compose stack starts automatically on boot, configure a `systemd` service.

### One-Liner Setup:

Run the following to create the service file, reload systemd, and start the service:

```bash
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
EOF
systemctl daemon-reload && systemctl enable docker-compose-app.service && systemctl start docker-compose-app.service'
```

---

## 6. Additional Notes

- The provided Docker Compose file binds the application to `localhost`. To expose it to other devices on your network, modify the `docker-compose.yml` file and change the host binding (e.g., from `127.0.0.1` to `0.0.0.0`).
- Verify container status with:
    
    ```bash
    docker ps
    ```
    
- To manually stop and remove containers:
    
    ```bash
    docker compose down
    ```
    

---
