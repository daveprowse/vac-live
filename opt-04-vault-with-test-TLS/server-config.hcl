ui = true
disable_mlock = true

storage "raft" {
  path    = "./data"
  node_id = "node1"
}

listener "tcp" {
  address     = "<hostname>:8200"
  tls_cert_file = "cert.pem"
  tls_key_file = "key.pem"
}

# for the address you could also use:
# address     = "<ip_address>:8200"

api_addr = "http://<ip_address>:8200"
cluster_addr = "https://<ip_address>:8201"