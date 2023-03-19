# DiepXuan Personal Package

ductn is private package, in ppa DiepXuan Personal Package.

## Installation

#### Use Apt package manager
```bash
sudo add-apt-repository ppa:caothu91/ppa
```

#### Use own custom installer
```bash
curl -s https://diepxuan.github.io/ppa/install.sh | sudo bash
```

#### Manual install
```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF8545DBEDD9351A
sudo curl -SsL -o /etc/apt/sources.list.d/caothu91-ubuntu-ppa-focal.list https://diepxuan.github.io/diepxuanppa/caothu91-ubuntu-ppa-focal.list
sudo apt update
sudo apt install ductn

sudo systemctl daemon-reload
sudo systemctl enable ductnd
sudo systemctl restart ductnd
```

## Usage

```bash
ductn -v
```

## Contributing

    v3.0.5 --- sync Clusters config
    |
    v3.0.4 --- use CSF replace UFW and manual iptables
    |
    v3.0.3 --- use VPN for multi pve server in office
    |
    v3.0.2 --- create ductn-iptables to ALLOW and NAT port to VMs
    |
    v3.0.1 --- create ductnd service, replace to CRON to active functions
  /
v3 --- create package and create DiepXuan ppa repository
 |
v2 --- Create one bash file to do some functions in v1
 |
v1 --- Create bash file to work some private function in multiple servers and vms

## License

[MIT](https://choosealicense.com/licenses/mit/)
