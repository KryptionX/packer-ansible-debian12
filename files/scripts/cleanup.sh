#!/bin/sh -eux

echo "remove linux-headers"
dpkg-query -W -f='${binary:Package}\n' | grep 'linux-headers' | xargs apt-get -y purge

echo "remove specific Linux kernels, such as linux-image-4.9.0-13-amd64 but keeps the current kernel and does not touch the virtual packages"
dpkg-query -W -f='${binary:Package}\n' | grep 'linux-image-[2345].*' | grep -v $(uname -r) | xargs apt-get -y purge

echo "remove linux-source package"
dpkg-query -W -f='${binary:Package}\n' | grep linux-source | xargs apt-get -y purge

echo "remove all development packages"
dpkg-query -W -f='${binary:Package}\n' | grep -- '-dev\(:[a-z0-9]\+\)\?$' | xargs apt-get -y purge

# Remove unneeded packages
echo "Removing unneeded packages..."
apt -y autoremove

# Clean up APT cache
echo "Cleaning up APT cache..."
apt -y clean

# Remove APT lists
echo "Removing APT lists..."
rm -rf /var/lib/apt/lists/*

# Remove all logs
echo "Removing all logs..."
find /var/log -type f -exec truncate --size=0 {} \;

# Remove machine-id
echo "Removing machine-id..."
truncate -s 0 /etc/machine-id

# Remove the contents of /tmp and /var/tmp
echo "Removing the contents of /tmp and /var/tmp..."
rm -rf /tmp/* /var/tmp/*

# Force a new random seed to be generated
echo "Forcing a new random seed to be generated..."
rm -f /var/lib/systemd/random-seed

# Clear the history
echo "Clearing the history..."
rm -f /root/.wget-hsts
export HISTSIZE=0

# Clean up /var/cache
echo "Cleaning up /var/cache..."
find /var/cache -type f -exec rm -rf {} \;

echo "Cleanup completed successfully!"
