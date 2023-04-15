# Opt 03 - Sealed Vault with Configuration File
In this optional lab you create a sealed vault on your local computer using a basic configuration file.

## Analyze the config.hcl file
This file contains the configuration required to run Vault a specific way. Vault data will be stored in the ./vault/data path and will use the Raft storage system. 

> Note: The storage path is ./vault/data. Those directories have been created for you already. If you want the vault data to be stored somewhere else, be sure to modify the path in the config.hcl file. 

## Run the server
To create the vault, type the following in the opt-03 directory:

`vault server --config=config.hcl`

That should run the server on your local system using the IP address you provided in config.hcl. 

## Connect to the Vault and check its status
- Export the Vault address:

  ` export VAULT_ADDR='http://127.0.0.1:8200'`

- View the status of the vault
  
  `vault status`

  You should see the vault is not initialized, but it is sealed. 
  Play around with it to see how it works.

You can use this basic vault as a testing ground for future configurations. Great work!
