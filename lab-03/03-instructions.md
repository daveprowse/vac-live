# Lab 03 - Build a Sealed Vault

In this lab you will create a sealed Vault server. This is the typical nature of HashiCorp Vault. Unlike the -dev server, this vault will begin in an uninitialized yet sealed state. 

Be prepared to use three different terminals for this lab. The first will run the server and can be used to review the logs in real time. The second will display the unseal keys and root token. The third will be where we work with the vault.

---

## Create your directories
Open a terminal to the lab-03 directory.

Create the directory path vault/data. For example:

`mkdir -p vault/data`

The "data" directory will house the vault's data! Be sure to point to it in the configuration file.

## Build a Vault configuration file
Copy the configuration from **code.txt** to a new file named **config.hcl**. 

Find the three instances where it says "your_IP_address" and modify it to your system's actual IP address.

> Note: to find this in Linux, type `ip a`. In macOS, `ifconfig`. In Windows `ipconfig` or, in all cases, use whatever GUI-based method you prefer. 

Save the file.

> Note: You could have also used the localhost IP (127.0.0.1) but that would only be accessible from your local machine. This way, you can potentially access the vault from other systems.

## Deploy a Vault sealed server 
Run the following command:

`vault server --config=config.hcl`

This will create a sealed vault using the configuration found in the config.hcl file you modified previously.

> Note: As you work through this lab, periodically scan the log file in the terminal where you created the vault. The more you read the INFO and ERROR statements in the log, the more familiar you will become with Vault.

## Make sure it works! 
First, open a new terminal.

Then, export the VAULT_ADDR environment variable:

` export VAULT_ADDR='http://<your_IP_address>:8200'`

Change "<your_IP_address>" to the actual IP address of your system. 

Run the `vault status` command.

Verify that you can see the vault. It should be uninitialized and sealed. 

## Initialize the Vault
Run the `vault operator init` command.

This may take up to a minute to complete. When it is finished it should display 5 unseal keys and an initial root token. You will use these to unseal and access the vault.

Copy these keys and the root token to a file. 

> Note: In the field you would want to securely store these, and normally, the keys would be distributed among multiple parties.

Run the `vault status` command again. It should show the vault as initialized. 

## Unseal the Vault
Open a third terminal.

Export the VAULT_ADDR environment variable again.

Run the `vault operator unseal` command along with an unseal key. For example:

`vault operator unseal tSQ5ke6Mc0yPTh2Dl1hxYXnbRpMxO8KOHZhwgEq1pt3R`

Do this two more times using a different unseal key each time.
Each time you do it, the "Unseal Progress" shown in the vault status should increment by one.

When you issue the command the third time, it should show Sealed = false. The vault is now unsealed and can be used. 

> Note: This process could have also been accomplished using a web browser.

## Connect as root to the vault
In order to do anything with the vault we need to login. Type the following command:

`vault login`

The system will ask you for the initial root token. Paste it in and you should see a Success message. 

> Note: You could also simply paste the token directly after `vault login`.

Type the `vault secrets list` to see the secrets engines currently running. 

## Enable a secrets engine
Type the following command:

`vault secrets enable kv`

This will enable a new secrets engine called "kv". 

Type `vault secrets list` to see the new engine.

## Create and view a secret
Remember that the name of our new secrets engine is "kv". 

Type the following command:

`vault kv put -mount=kv solar_system planet1=mercury`

That will create a new secret called "solar_system" which contains a key/value pair (planet1=mercury).

View the secrets stored in the kv secrets engine:

`vault kv list kv`

Now, view the individual solar_system secret data:

`vault kv get -mount=kv solar_system`

That should show the "planet1" key and its corresponding value "mercury".

## Seal the vault
Type the following command:

`vault operator seal`

As long as you are connected as root, that should seal the vault and you should see a success message. 

Prove this by running `vault status`. It should show that the vault is sealed (Sealed = true).

Try viewing the secrets in the kv secrets engine:

`vault kv list kv`

This should fail with a Code 503 error. That is because the vault is now sealed!

## Stop the server 
Go to the terminal where you originally ran the Vault server and turn it off by pressing `Ctrl+C` on the keyboard. 

Run `vault status` to verify that the connection is refused. 

---
## *Fantastic. Now you have a properly sealed vault once again! Great work!*
---

**Extra Credit for Homework (not during class)**

Try closing the server <kbd>Ctrl+C</kbd> and then restarting it using the same configuration file. Then, unseal the vault. Check if your secret is still there. It should be! 

*Remember* - Seal the vault when you are finished!

