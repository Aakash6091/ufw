#!/bin/bash
# Fedora Lockdown Script Using UFW and RKHunter
# This script configures and locks down Fedora 31 for Dovecot, Postfix, Roundcube, and SSH.

# Ensure the UFW package is installed
echo "Installing UFW if not already installed..."
sudo dnf install -y ufw

# Enable UFW service
echo "Enabling and starting UFW..."
sudo systemctl enable ufw
sudo systemctl start ufw

# Default deny all incoming traffic and allow outgoing traffic
echo "Setting default UFW policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow essential services for the webmail server
echo "Allowing essential services..."
sudo ufw allow ssh        # SSH for remote management
sudo ufw allow 25         # SMTP for Postfix
sudo ufw allow 143        # IMAP for Dovecot
sudo ufw allow 587        # SMTP with STARTTLS for Postfix
sudo ufw allow 993        # IMAP over SSL/TLS for Dovecot
sudo ufw allow 443        # HTTPS for Roundcube webmail access
sudo ufw allow 80         # HTTP for Roundcube webmail access

# Enforce logging to monitor any unusual activity
echo "Enabling logging..."
sudo ufw logging on

# Enable the firewall
echo "Enabling UFW..."
sudo ufw enable

# Show final UFW status and rules
echo "Firewall configuration completed. Current status:"
sudo ufw status verbose

# Install and Configure RKHunter
echo "Installing RKHunter..."
sudo dnf install -y rkhunter

# Update RKHunter's database
echo "Updating RKHunter database..."
sudo rkhunter --update

# Run RKHunter to check for rootkits
echo "Running RKHunter scan..."
sudo rkhunter --check --skip-keypress

# Schedule Daily RKHunter Scans (optional)
echo "Scheduling daily RKHunter scans..."
echo "0 3 * * * root /usr/bin/rkhunter --check --quiet" | sudo tee -a /etc/crontab

# Optional: Additional lockdown configurations (comment/uncomment as needed)
# Disable root SSH login:
# echo "Disabling root SSH login..."
# sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
# sudo systemctl restart sshd

# Ensure SELinux is enforcing (Fedora default)
echo "Ensuring SELinux is enforcing..."
sudo setenforce 1
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

# Script complete
echo "Lockdown complete! Fedora system secured with UFW and RKHunter configured for Dovecot, Postfix, Roundcube, and SSH."
