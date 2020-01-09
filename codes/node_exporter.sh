echo "Installing node exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz -O /tmp/node_exporter-0.18.1.linux-amd64.tar.gz
[ -d /opt/prometheus ] || mkdir -p /opt/prometheus
[ -d /opt/prometheus/proms ] || mkdir /opt/prometheus/proms
tar zxvf /tmp/node_exporter-0.18.1.linux-amd64.tar.gz -C /opt/prometheus/
mv /opt/prometheus/node_exporter-* /opt/prometheus/ne_node_exporter
chmod 755 /opt/prometheus/ne_node_exporter && chown root: $_

echo "Disable HWMON if HW vendor is HP..."
[[ $(dmidecode -s system-manufacturer) =~ HPE ]] && NE_OPTS="--no-collector.hwmon"
cat <<EOF > /etc/default/node_exporter 
NE_OPTS="${NE_OPTS} --collector.textfile.directory=/opt/prometheus/proms"
EOF

echo "Create systemd unit file..."
cat <<'EOF' > /etc/systemd/system/node_exporter.service 
[Unit]
Description=NE Node Exporter
Documentation=https://github.com/prometheus/node_exporter
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=root
Group=root
PIDFile=/var/run/node_exporter.pid
EnvironmentFile=/etc/default/node_exporter
ExecStart=/opt/prometheus/ne_node_exporter/node_exporter $NE_OPTS
ExecStop=/bin/kill -s QUIT $MAINPID
ExecReload=/bin/kill -s HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
