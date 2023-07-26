# Lab 02 - Vault Development Server

In this lab you will create a Vault dev server, inspect it, and create and view basic secrets within the vault. We will work with key/value pairs and the `vault kv` command.

Be ready use at least two terminals, or employ a terminal multiplexing program such as Tmux, Screen, or Tilix.

---

## Deploy a Vault dev server 
Open a terminal.

Run the following command:

`vault server -dev`

(If it does not work, check and make sure that Vault is installed.)

Examine the results. The vault will be called "secret" by default.

The server should run locally at the following address and port:

http://127.0.0.1:8200

> Note: Be sure not to end the process or close the terminal. The process does not fork, so the terminal (and the process) need to continue running until you are done with the lab.

Also make note of the Unseal Key and the Root Token.

## Export the listener address variable
You may need to export the listener address of the Vault server. 
To do this, open a *new* terminal.

Export the Vault address with the following command:

` export VAULT_ADDR='http://127.0.0.1:8200'`

Each subsequent terminal you want to use will also need this command.

> Note: Enter a <kbd>Space</kbd> before the command so that it is not included in the terminal's history. Get in the habit of doing this whenever entering credentials, IP addresses, and so on. Then type `clear` to clear command history and the contents on the screen. 

## Check the Vault's status
Use the following command to find out the status of the dev Vault:

`vault status`

> Note: If you get an error, verify that the dev server is running, and that you have exported the VAULT_ADDR environment variable as shown previously. 

The results should show that the vault is using the Shamir seal, but it currently unsealed (the default state for a dev vault). You should also see that it is initialized. Note also that the storage type is "inmem" which means in memory. Remember that this is volatile and the vault will cease to exist if you do any one of the following: end the vault dev server process, close the terminal, or reboot the computer.

You can also view the status by viewing JSON information via the API. Example of the initialization status:

`curl http://127.0.0.1:8200/v1/sys/init`

## Create and view a basic secret
Create a secret with the following command:

`vault kv put -mount=secret color-A red=1`

This will create a key pair where the key "red" has a value of 1. Note the response in the terminal as well. Remember that the name of the vault is "secret".

> Note: This uses KV version 2 syntax which makes use of the -mount flag. the older KV version 1 syntax uses a path prefix. For example, the same command in version 1 would be: 
>
> `vault kv put secret/color-A red=1`

Now, view the secret:

`vault kv get -mount=secret color-A`

In the Data section you should see the key and value: red = 1. 

Create a second secret now. For example:

`vault kv put -mount=secret color-B orange=2`

You can also view a list of the secrets stored in the vault:

`vault kv list secret/`

This will show the secrets (displayed as "Keys") but not the internal key/value pairs. 

## Delete and undelete a secret's data
Use the following command to remove the data from a secret:

`vault kv delete -mount=secret color-A`

That should remove the key pair information from the "color1" secret. You can verify this by typing:

`vault kv get -mount=secret color-A`

> Note: This does not remove the secret, it only removes the data within the secret.

To get the key pair information back, use the undelete option:

`vault kv undelete -mount=secret -versions=1 color-A`

> Note: The "destroy" subcommand will permanently remove secret data. 

## Login as root to the UI
Open a browser and connect to the local vault:

`http://127.0.0.1:8200`

Click the "Method" drop down menu. Note that many authentication methods are listed, but only "Token" is being used currently.

Click on the "Token" method.

Enter the token for root.

## Create a new secret in the UI

Create a new secret (color-C) in the KV engine. 

> Note: The steps to do this in the UI are the same as in the CLI, but it's all point and click. 

Be sure to save when done. 

View both secrets in the UI and in the CLI

## Stop the dev server
In the original terminal where the dev vault is running, press <kbd>Ctrl+C</kbd>.

That will stop the server that is listening. The vault will be terminated and flushed from memory. 

Try running `vault status` in another terminal. The connection should be refused.

> Note: While working with key pair data is fine, it is strongly recommended to use files instead. 

## Extra Credit
- Learn more about the `vault kv` command and its subcommands within the Vault help system and at https://developer.hashicorp.com/vault/docs/commands/kv. 
- Run a local server using a configuration file. See opt-03-sealed-vault for step-by-step instructions.

---
## *Excellent! Continue!*
---