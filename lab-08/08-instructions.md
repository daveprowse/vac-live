# Lab 08 - Secrets Engines
In this lab we will work with the default secrets engines in Vault including cubbyhole, identity, kv, and system. 

> Note: To save time, use the vault from the previous lab. If you do, skip the first step. But remember that the vault will have the AWS secrets engine enabled.

## Start Vault
Start a dev Vault. 

If you wish, you can use the "root" Vault token for simplicity. To do so, follow the instructions below:

> REMEMBER! Do not do this in production. This is for Vault -dev servers only.

Start the Vault dev server with the following command:

`vault server -dev -dev-root-token-id=root`

Then, export the Vault address and main Vault token as environment variables. (I suggest doing this in two terminals.)

` export VAULT_ADDR=http://127.0.0.1:8200`

` export VAULT_TOKEN=root`

Verify that the Vault is running with a `vault status` command. 

> Note: You can use this method for most of the testing that you perform in the future.

## Analyze the vault secrets command
Learn more about the ` vault secrets` command:

`vault secrets -h`

Take a minute to read up on one of the options:

`vault secrets enable -h`

## Display the built-in secrets engines
To see the currently running secrets engines, use the following command:

`vault secrets list`

This should display the cubbyhole, identity, kv, and system secret engine types. Note that the path for these can vary. 

## Learn more about the built-in secrets engines
Type the following command syntax to learn more about a particular type of secrets engine:

`vault path-help <path>`

This is path-based. So, for example, if you wanted to learn more about the cubbyhole secrets engine, type:

`vault path-help cubbyhole`

To learn more about the kv secrets engine that uses the "secret" path, use:

`vault path-help secret`

Spend some time learning more about each of the default secrets engines. 

## Work with the KV secrets engine
In this section we will enable a new KV secrets engine, create a secret, and view it with another token in the UI.

### Enable a new KV secrets engine and create a secret
We already have the built in KV engine known as "secret". Let's make another one now:

`vault secrets enable -path=test_path1 kv`

Now, run the `vault secrets list` command again. This should show the new kv engine. Make note of the different accessor value for each kv engine you create. 

Next, we'll create a secret in our new kv engine.

`vault kv put -mount=test_path1 abc-co-password passwd=T3sT*9`

This creates a new secret (named abc-co-password) and sets the key value as passwd=T3sT*9. 

Check it:

`vault kv get -mount=test_path1 abc-co-password`

Make sure the key/value pair is listed properly.

### Create a new root token and view the secret from the UI
In a new terminal, run the following command:

`vault token create`

This will create a new root token. 

Now, open a browser to http://127.0.0.1:8200. 

Login with the new token ID that was just created.

Access the secrets engine named test_path1. Then click on the secret that we just made. As you can see, the new root token can access (and modify) any secrets that were created by the original root token. 

## Work with the cubbyhole secrets engine
In this section we will create secrets in the cubbyhole secrets engine and view them from the UI.

In the terminal, create a new secret in the cubbyhole:

`vault kv put -mount=cubbyhole secret1 test=this-is-not-a-secret`

That should create the new secret named "secret1" in the cubbyhole secrets engine.

Attempt to view the secret in the UI. Go back to the browser. You should still be logged in with the root token that we created previously. 

If you access the cubbyhole secrets engine, there should not be any secrets listed. 

Sign out of the UI.

Sign back in using the original root token named "root".

Access the cubbyhole secrets engine. You should be able to see the secret named "secret1". This proves that there is a separate, private cubbyhole for each token (or user).

## Explorer the identity secrets engine
Type the following command to learn more about the identity secrets engine:

`vault path-help identity`

From here you can see that you can create entities, aliases, and entity-aliases (among other things). These can be useful if you have individual users in Vault that need to access accounts from multiple authentication methods with different usernames. 

As a very basic example, create a new entity within the identity secrets engine:

`vault write identity/entity name=bob`

That will create a new entity (not a user) named bob. We could then set an alias for that entity. 

> Note: The identity secrets engine is not available in the UI. 

> More information: This is just the tip of the iceberg when it comes to entities and aliases (and the identity secrets engine in general.) For an in-depth lab on the subject, see the following Hashicorp tutorial: https://developer.hashicorp.com/vault/tutorials/auth-methods/identity

## Explore the system secrets engine
Type the following command. Remember that to get help, you have to type the *path* of the secrets engine, not the type. 

`vault path-help sys`

This secrets engine is used for configuration and analysis of Vault including leases, audits, mounts, debugging, and much more. 

For example, we have used the sys/ path to view leases for AWS connections in a previous lab. This time, let's view the keys associated with the root tokens we have so far.

`vault list sys/leases/lookup/auth/token/create`

This should show two keys, one for the main root token created when we started the vault, and the other from when we created a second root token. 

The sys/ path contains all of the configuration data that you might need to access. That is why this secrets engine cannot be moved or disabled (dismounted). It also cannot be accessed from the UI.

## Disable the kv secrets engine  
Finally, let's clean up. Disable the secrets engine we created.

`vault secrets disable test_path1`

Verify that it is disabled by running the `vault secrets list` command. 

---
## *It's no secret. Vault is deep. Keep going!*
---