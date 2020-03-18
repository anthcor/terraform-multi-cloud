#!/usr/bin/env bash
set -e

function ssh-apt {
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq \
    --force-yes \
    -o Dpkg::Use-Pty=0 \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    "$@"
}

echo "--> Installing common dependencies"
ssh-apt update
ssh-apt upgrade
ssh-apt install \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  git \
  jq \
  software-properties-common \
  unzip \
  vim
ssh-apt clean
ssh-apt autoclean
ssh-apt autoremove

echo "--> Setting hostname"
echo "127.0.0.1  ${hostname}" | sudo tee -a /etc/hosts
echo "${hostname}" | sudo tee /etc/hostname
sudo hostname -F /etc/hostname

echo "--> Fetching Consul"
pushd /tmp
curl \
  --silent \
  --location \
  --output consul.zip \
  https://releases.hashicorp.com/consul/0.8.4/consul_0.8.4_linux_amd64.zip
unzip -qq consul.zip
sudo mv consul /usr/local/bin/consul
sudo chmod +x /usr/local/bin/consul
rm -rf consul.zip
popd

echo "--> Writing configuration"
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/config-default.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "bind_addr": "$PRIVATE_IP",
  "data_dir": "/mnt/consul",
  "leave_on_terminate": true,
  "node_name": "${hostname}"
}
EOF

echo "--> Writing systemd configuration"
sudo tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
Environment=GOMAXPROCS=8
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable consul

echo "--> Installing Nginx"
ssh-apt install nginx
sudo rm -f /var/www/html/index.nginx-debian.html

echo "--> Fetching Consul Template"
pushd /tmp
curl \
  --silent \
  --location \
  --output consul-template.zip \
  https://releases.hashicorp.com/consul-template/0.18.5/consul-template_0.18.5_linux_amd64.zip
unzip -qq consul-template.zip
sudo mv consul-template /usr/local/bin/consul-template
sudo chmod +x /usr/local/bin/consul-template
rm -rf consul-template.zip
popd

echo "--> Creating template file"
sudo mkdir -p /etc/consul-template.d
sudo tee /etc/consul-template.d/config.hcl > /dev/null <<"EOF"
log_level = "debug"

template {
  destination = "/var/www/html/index.html"
  command     = "sudo systemctl reload nginx"

  contents = <<EOH
<h1>Terraform Demo!</h1>
<p>I am <strong>{{ with node }}{{ .Node.Node }} - {{ .Node.Address }}{{ end }}</strong></p>

{{ range $dc := datacenters }}<h2>{{ $dc }}</h2>
<ul>{{ range nodes ( printf "@%s" $dc ) }}
  <li>{{ .Node }} - {{ .Address }}</li>{{ end }}
</ul>
{{ end }}
EOH
}
EOF

echo "--> Writing systemd configuration"
sudo tee /etc/systemd/system/consul-template.service > /dev/null <<"EOF"
[Unit]
Description=consul template
Requires=consul.service
After=consul.service

[Service]
Environment=GOMAXPROCS=8
Restart=on-failure
ExecStart=/usr/local/bin/consul-template -config=/etc/consul-template.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable consul-template
