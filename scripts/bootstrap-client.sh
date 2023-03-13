#!/usr/bin/env sh

_install_consul () {
    # Build consul from source
    git clone https://github.com/hashicorp/consul.git
    cd consul

    make dev
    mv ./bin/consul /usr/local/bin/consul
}

_install_nomad () {
    # Copy-pasted straight from HashiCorp documentation
    # https://developer.hashicorp.com/nomad/downloads
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install -y nomad
}

BIND_ADDRESS_TEMPLATE='{{ GetPrivateInterfaces | join "address" " " }}'
consul agent -bind $BIND_ADDRESS_TEMPLATE -client $BIND_ADDRESS_TEMPLATE -bootstrap-expect 1 -config-file /home/cloud-admin/consul-client.json
