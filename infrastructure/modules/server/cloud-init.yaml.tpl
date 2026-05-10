#cloud-config
users:
  - name: deploy
    groups: [docker, sudo]
    shell: /bin/bash
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    ssh_authorized_keys:
      - ${deploy_public_key}

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - nginx
  - certbot
  - python3-certbot-nginx

runcmd:
  # Instalar Docker
  - install -m 0755 -d /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  - chmod a+r /etc/apt/keyrings/docker.asc
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  - systemctl enable docker
  - systemctl start docker
  # Criar diretórios da aplicação
  - mkdir -p /opt/watchlist/prod /opt/watchlist/staging
  - chown -R deploy:deploy /opt/watchlist
