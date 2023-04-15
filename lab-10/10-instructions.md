# Lab 10 - Auditing and Troubleshooting
In this lab we will run a Vault server with disk-based Raft storage. Then we'll setup audit devices so that we can track everything that happens in the Vault server.

## Prep-work
Analyze the supplied config.hcl file. Within that file you will see that we are running a Vault server with storage inside of ./vault/data. TLS is disabled, as is the UI altogether. 

Now create the directory structure we will need:

`mkdir -p vault/data`

Check the Vault configuration file:

`vault operator diagnose -config=config.hcl`

This should result in mostly success messages. If there are any failures, they should be troubleshot before running the server.

Preparations are now complete.

## Run the Vault server
Use the config.hcl file to run a Vault server:

`vault server -config=config.hcl`

Verify that the server is running properly and export the Vault address to another terminal (or two!)

` export VAULT_ADDR=http://127.0.0.1:8200`

Run `vault status` and verify that the vault is not initialized and is currently sealed.

## Initialize the Vault
From a second terminal, run the following command:

`vault operator init`

You are supplied with 5 unseal keys and the initial root token. 

Note the log file from the first terminal. It will record everything that is happening in real time. Try to keep an eye on this as you do your work!

## Unseal the vault
To make things easier, work in a third terminal. Issue the following command:

`vault operator unseal`

Then copy the first unseal key from the 2nd terminal. 

Repeat the process two more times using a different unseal key each time. (Do you remember the security method being implemented here?)

## Login to the Vault
At this point the vault should be unsealed. Now we can login:

`vault login`

Paste in the initial root token when prompted.

Once you have logged in with a root token you should be able to whatever you want with the vault. 

## Examine the vault audit help file
Take a look that the help files for the following:

`vault audit -h`

`vault audit enable -h`

Spend a minute looking at the options for `vault audit`.

## Enable an audit device and view the auditing information
Auditing is disabled by default in a Vault server. You need to enable it. Also, auditing devices can only be enabled by privileged users that have sudo permissions (capabilities) on the path: "sys/audit". We will be using the root account which has access to anything, but in the field you would want to specify a user account with specific capabilities for auditing.

Run the following command to setup a log file that will act as an audit device:

`vault audit enable file file_path=./vault/vault-audit.log`

If successful, you should see that it was created in the main Vault log in your first terminal. 

Now, view the audit device:

`vault audit list -detailed`

Note the path of the audit device created which is simply `file/`

Finally, examine the audit file itself:

`cat ./vault/vault-audit.log`

Not much there for now. But wait! go back to the second terminal and run the following command:

`vault auth enable aws`

You will see that the AWS credential backend is enabled in the real-time log in the first terminal. Now, view that in the audit device log file (from the third terminal):

`cat ./vault/vault-audit.log | jq`

You should see that AWS was enabled just by searching for the "path" sub-block which shows "sys/auth/aws". That's just the tip of the iceberg when it comes to auditing, there is much more!

For now, let's show how to disable the audit device. You do this by the path name:

`vault audit disable file/`

That will disable the audit device, but it does not remove the file associated with the audit device. This way, you could resume auditing at a later time using the same file.

Take a look at the file:

`cat ./vault/vault-audit.log | jq`

You should see that the last logged entry shows a "delete" operation for the path: sys/audit/file. 

Try running another command and checking the log file. It should not be logging anymore.

`vault auth disable aws`

`cat ./vault/vault-audit.log | jq`

---
## *Whoa! Someone needs to audit our lack of break time!*
---
