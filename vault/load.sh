#!/usr/bin/env sh
vault kv put secret/tyk url=https://nginx cert=@/certs/combined.pem
