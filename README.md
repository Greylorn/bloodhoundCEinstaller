# BloodHound Community Edition (BHCE) Installer

## Overview

This repository provides a script, `bloodhound.sh`, that automates the setup of **BloodHound Community Edition (BHCE)** in a lab environment using Docker and Docker Compose. The script handles the installation of required components, deployment of BHCE, and configuration to expose the application on your network.

**Caution:** The script will open BloodHound to the network, making it accessible to other devices. Please use it carefully and ensure you're operating in a secure, controlled environment.

---

## Prerequisites

Before running the script, ensure you have:

- **A Linux-based operating system** (Tested on Ubuntu)
- **Administrative privileges** (sudo access)

---

## What the Script Does

The `bloodhound.sh` script automates the following steps:

1. **Installs Docker Engine and Docker Compose**
2. **Downloads the `docker-compose.yml` file for BHCE**
3. **Modifies the configuration to expose BHCE on all network interfaces (`0.0.0.0`)**
4. **Deploys the Docker stack**
5. **Waits for the BHCE service to become available**
6. **Retrieves the randomly generated admin password**
7. **Sets up a `systemd` service for auto-start on boot**

---

## Usage

### 1. Clone the Repository

```bash
git clone https://github.com/Greylorn/bloodhoundCEinstaller.git
```

### 2. Navigate to the Repository Directory

```bash
cd bloodhoundCEinstaller
```

### 3. Make the Script Executable

```bash
chmod +x bloodhound.sh
```

### 4. Run the Script with Administrative Privileges

```bash
sudo ./bloodhound.sh
```

---

## Accessing BloodHound

1. **Retrieve the Local IP Address**

   The script will display your local IP address upon completion. If needed, you can manually find it using:

   ```bash
   hostname -I | awk '{print $1}'
   ```

2. **Open a Browser and Navigate to:**

   ```
   http://[your-server-ip]:8080/ui/login
   ```

3. **Log in with:**

   - **Username:** `admin`
   - **Password:** The randomly generated password displayed by the script.

---

## Important Notes

- **Network Exposure:**

  - The script modifies the `docker-compose.yml` file to bind BHCE to `0.0.0.0`, exposing it on all network interfaces. Ensure that your environment is secure and that you understand the implications of exposing BHCE on your network.

- **Password Retrieval:**

  - The admin password is **randomly generated** and displayed by the script. Make sure to save this password securely.

- **Systemd Service:**

  - A `systemd` service named `docker-compose-app.service` is created to ensure BHCE starts automatically on boot.

---

## Manual Installation Steps (Optional)

If you prefer to install and configure BHCE manually, you can follow these steps:

### 1. Install Docker Engine and Docker Compose

Follow these commands to install Docker and Docker Compose:

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
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world
```

### 2. Deploy BloodHound Community Edition

#### Download the Docker Compose File:

```bash
curl -L https://ghst.ly/getbhce > docker-compose.yml
```

#### Modify the Configuration to Expose BHCE:

Edit the `docker-compose.yml` file and change the host binding from `127.0.0.1` to `0.0.0.0`:

```yaml
services:
  bloodhound:
    ports:
      - "8080:8080"
```

#### Pull and Start the Containers:

```bash
docker compose pull
docker compose up
```

#### Retrieve the Admin Password:

- The admin password is **randomly generated** and displayed in the terminal output during the first run.

#### Start in Detached Mode (Optional):

```bash
docker compose up -d
```

---

## Resetting the Password

If you lose the password, it cannot be regenerated. To reset the password:

1. **Stop and Remove All Containers and Volumes:**

   ```bash
   docker compose down -v
   ```

2. **Restart the Stack to Generate a New Password:**

   ```bash
   docker compose up
   ```

---

## Verifying Installation

- **Check Container Status:**

  ```bash
  docker ps
  ```

- **View Logs:**

  ```bash
  docker compose logs
  ```

- **Manually Stop and Remove Containers:**

  ```bash
  docker compose down -v
  ```

---

**Disclaimer:** This setup is intended for educational and testing purposes in a controlled lab environment. Always ensure you have proper authorization before deploying or testing in a production environment.