# Nagios Monitoring Setup for SMS Application

This directory contains the configuration files and setup instructions for Nagios Core monitoring.

## Overview

Nagios monitors:
- **Application Server**: Backend API (8080), Frontend (5173), SSH, CPU, Disk
- **Monitoring Server**: Self-monitoring (CPU, Disk, Ping)

## Installation

The Nagios setup is automated via Ansible. Run:

```bash
cd ../ansible
ansible-playbook -i inventory/hosts.yml playbooks/setup-nagios.yml
```

## Manual Installation (if needed)

If you prefer manual setup on the monitoring VM:

### 1. SSH to Monitoring VM
```bash
ssh azureuser@<MONITOR_VM_IP>
```

### 2. Install Prerequisites
```bash
sudo apt update
sudo apt install -y autoconf gcc libc6 make wget unzip apache2 php \
  libapache2-mod-php libgd-dev openssl libssl-dev apache2-utils
```

### 3. Download and Install Nagios Core
```bash
cd /tmp
wget https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.14.tar.gz
tar xzf nagios-4.4.14.tar.gz
cd nagioscore-nagios-4.4.14

./configure --with-command-group=nagcmd
make all
sudo make install
sudo make install-init
sudo make install-config
sudo make install-commandmode
sudo make install-webconf
```

### 4. Create Nagios Admin User
```bash
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
# Enter password: Admin123! (or your choice)
```

### 5. Download and Install Nagios Plugins
```bash
cd /tmp
wget https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.6.tar.gz
tar xzf release-2.4.6.tar.gz
cd nagios-plugins-release-2.4.6

./tools/setup
./configure
make
sudo make install
```

### 6. Configure Nagios

Copy the configuration files from this directory to `/usr/local/nagios/etc/`:

```bash
# Copy from your local machine
scp -r nagios/config/* azureuser@<MONITOR_VM_IP>:/tmp/

# On the monitoring VM
sudo cp /tmp/nagios.cfg /usr/local/nagios/etc/
sudo cp /tmp/hosts.cfg /usr/local/nagios/etc/objects/
sudo cp /tmp/services.cfg /usr/local/nagios/etc/objects/
sudo chown -R nagios:nagcmd /usr/local/nagios/etc/
```

### 7. Start Nagios
```bash
sudo systemctl start nagios
sudo systemctl enable nagios
sudo systemctl restart apache2
```

## Access Nagios Web Interface

URL: `http://<MONITOR_VM_IP>/nagios`

Default credentials:
- Username: `nagiosadmin`
- Password: `Admin123!` (or what you set)

## Configuration Files

### `nagios.cfg`
Main Nagios configuration file with:
- Log settings
- Object configuration file locations
- Check intervals and timeouts
- Performance settings

### `hosts.cfg`
Defines monitored hosts:
- **sms-app-server**: Your application VM
- **localhost**: Nagios server itself

### `services.cfg`
Defines monitored services:
- PING checks
- SSH availability
- HTTP services (Backend 8080, Frontend 5173)
- System resources (CPU, Disk)

## Monitoring Checks Explained

### For Application Server:
1. **PING** - Basic connectivity (every 5 min)
2. **SSH** - Remote access availability
3. **Backend API** - HTTP check on port 8080
4. **Frontend** - TCP check on port 5173
5. **CPU Load** - System performance
6. **Disk Usage** - Storage capacity

### Alert Thresholds:
- **WARNING**: CPU load > 4.0, Disk > 80%
- **CRITICAL**: CPU load > 6.0, Disk > 90%

## Troubleshooting

### Check Nagios Configuration
```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

### View Nagios Logs
```bash
sudo tail -f /usr/local/nagios/var/nagios.log
```

### Restart Nagios
```bash
sudo systemctl restart nagios
```

### Check Apache Status
```bash
sudo systemctl status apache2
```

### Verify Plugins
```bash
/usr/local/nagios/libexec/check_http -H <APP_VM_IP> -p 8080
/usr/local/nagios/libexec/check_ssh <APP_VM_IP>
```

## Customization

### Add More Hosts
Edit `/usr/local/nagios/etc/objects/hosts.cfg`:

```nagios
define host {
    use                     linux-server
    host_name               my-new-server
    alias                   My New Server
    address                 10.0.1.100
    check_command           check-host-alive
}
```

### Add More Services
Edit `/usr/local/nagios/etc/objects/services.cfg`:

```nagios
define service {
    use                     generic-service
    host_name               my-new-server
    service_description     My Custom Check
    check_command           check_tcp!9000
}
```

After any configuration change:
```bash
sudo systemctl restart nagios
```

## Integration with CI/CD

The GitHub Actions workflow includes a step to notify this Nagios server about deployments. Ensure the monitoring VM is accessible from GitHub Actions runners (or configure a webhook endpoint).

## Classroom Demonstration Points

1. **Show the Dashboard**: Navigate through hosts and services
2. **Explain Status Indicators**: OK (green), WARNING (yellow), CRITICAL (red)
3. **Demonstrate Alerts**: Stop a service and watch it turn red
4. **View Historical Data**: Show service state history
5. **Configuration as Code**: Explain how configs are version-controlled

## Security Note

⚠️ **For Production**: 
- Change default passwords
- Restrict access via firewall rules
- Use HTTPS with SSL certificates
- Implement proper authentication (LDAP/AD)

This setup is simplified for classroom demonstration purposes.
