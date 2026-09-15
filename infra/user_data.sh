#!/bin/bash
set -e

# Install Node.js 20 (matches our CI matrix) and the SSM agent (usually preinstalled on AL2023, but ensure it's running)
dnf install -y nodejs20 nodejs20-npm
alternatives --install /usr/bin/node node /usr/bin/node-20 20 2>/dev/null || true

systemctl enable amazon-ssm-agent --now 2>/dev/null || true

mkdir -p /opt/app
chown ec2-user:ec2-user /opt/app

cat > /etc/systemd/system/gha-app.service <<'EOF'
[Unit]
Description=gha-node-ci-pipeline app
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node /opt/app/src/index.js
Restart=always
User=ec2-user
Environment=PORT=80

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable gha-app.service