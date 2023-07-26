# Lab 09 - Vault UI and API
In this lab we will pretend that we are end-users and machines. First, we'll show how end-users can access the UI. Then, we'll show how machines can be programmed to access the API. 

> Note: Be sure to stop any previous vaults that were running before you continue with this lab.

## Start Vault
Start the Vault dev server with the following command:

`vault server -dev`

Then, export the Vault address and main Vault token as environment variables. (I suggest doing this in two terminals.)

` export VAULT_ADDR=http://127.0.0.1:8200`

> Note: Do not export the root token ID yet.

Verify that the Vault is running with a `vault status` command. 

## Working with the UI
In the following sections we will perform some work in the web-based user interface (or UI for short). As you progress, think back to the equivalent functions in the CLI. 

### Connect to the UI and sign in
Open a browser and connect to your Vault server:

`http://127.0.0.1:8200`

Now sign in to Vault with the root token displayed when you started the dev server in the CLI.

Once signed in you should see the cubbyhole and secret/ secrets engine for the root account.

### Analyze the system from the CLI
Go to the terminal and run the `vault status` command if you didn't already.

Now, attempt to view the secrets engines that are running:

`vault secrets list` 

This should fail. Permission should be denied. While we have been given access to the UI, we have not gotten access to the CLI yet - the two are separate. 

Export the root token as an environment variable:

` export VAULT_TOKEN=<token_id>`   

The token_id was the one we used in the UI.

Run `vault secrets list` again.

You should see the cubbyhole, identity, secret/ and system secrets engines running. Remember, these always run, but the identity and system secrets engines are not visible in the UI. 

> Note: When running a proper Vault server (using Raft storage or other storage means) there will not be a kv secrets engine by default.

### Enable Username & Password authentication
Now, let's setup userpass authentication in the UI. 

Go to the browser. You will see in the main menu that the root account can use Secrets, Access, Policies, and Tools. 

Click on "Access" now. By default, that places you in the "Auth Methods" section. 

Click "Enable new method +" 

Select "Username & Password" and click Next.

Click "Enable Method". 

That will enable the userpass auth method and place you in a configuration screen where you can modify TTLs, select token type, and more.

*Great work so far! Take a deep breath and continue.*

### Create a new user
Return back to Access > Auth Methods. 

Click on "userpass"

Click on "Create user +"

Select a username (for example, test_user1) and password and click Save.

Now we have a new user to work with.

Before moving to the next step, take a look at the options in the menu. As root, you should see: Secrets, Access, Policies, and Tools. Essentially, root has access to everything.

### Sign in as the new user
Click on the User's drop down menu in the upper right and select "sign out". That will bring you back to the sign in page. 

Change the method to "Username"

Type in the username and the password for your new user and click "Sign In".

That should place you in the Secrets Engines page. Take note of a couple of things:

- **The user account has its own cubbyhole secrets engine.** Remember that this applies to this user account (and token) only.
- **There is no "Policies" option in the main menu.** That is because a standard user is restricted from working with policies by default. More accurately, users in general do not have the permission to work with policies because of the inherent implicit deny in Vault. (The principle of least privilege in action!)

So, you will find that the user is extremely limited in what it can do. There will be "permission denied" errors all over the place. For example, the user will not be able to enable a new secrets engine. However it can use its builtin cubbyhole secrets engine. 

Create a secret in the cubbyhole secrets engine now. Name it "test-secret". You have just created a secret that other user accounts cannot access because each cubbyhole is compartmentalized and secured. 

View the built-in CLI in the web browser. This can be found by clicking the drop down menu with the CLI icon in the upper right of the browser window. (It is to the left of the user icon.) From here you can run commands as you would in the regular terminal, but as the signed in user. 

Press the `?` to see the commands available to the user account.

Try a few commands, for example:

`read cubbyhole/test-secret`

`fullscreen`

`clear`

When done, sign out of the user account using the user icon drop down menu in the upper right. 

### Sign in as the new user account in the CLI
We just did several things in the UI. Let's show some CLI equivalents. (Some of these will be review.)

In the terminal, do the following:

`vault list auth/userpass/users`

That should show the name of the new user account you created. 

Now, in a *new* terminal sign in as that user. 

`vault login -method=userpass username=<username>`

Type in your password and you should be connected as the new user. 

Export the token ID as an environment variable with the `export` command.

Now, attempt to look at the secrets engines available to you:

`vault secrets list`

This will fail with a "permission denied" message, as it should. 

An important concept here is that everytime you sign in (whether from the CLI or the UI), the cubbyhole is renewed. Anything that was there will be removed when you sign out and the token is revoked. 

For example, try the following command:

`vault kv get -mount=cubbyhole <secret_name>`

This should result in a message saying that no value was found. Remember, every sign in uses a new cubbyhole. the cubbyhole is meant for tokens to store temporary information about themselves. For proper storage of secrets, a user would need access to a KV secrets engine (or other secrets engine).

> Question: Why use the CLI if you can just use the UI? 
> Answer: The CLI has 100% functionality, whereas the UI, while easier to use, is quite often limited. Remember!

## Working with the API
Here we'll show some API functionality. Remember to use the `curl` command in Bash to consume the API. 

First, export the root token so that we can work as root and have full access to the API:

`export VAULT_TOKEN=<token_id>`

### Basic API usage

Return back to a terminal that has a root connection. 

- Curl the main URL:

`curl http://127.0.0.1:8200`

This should result in a "Temporary Redirect" message. That's because the Vault webserver redirects to the ui directory. Instead of showing HTML information, it it programmed to give that basic message. 

Now, let's get some real information from the URL. 

- Let's show the vault status:

`curl http://127.0.0.1:8200/v1/sys/init`

This should show the following:

`{"initialized":true}`

That means that the Vault has been initialized, and that a root key has been created. We know this because the dev server initialized it for us automatically.

### Creating and reading secrets with the API

Now, let's create a secret. To do so, we use the "POST" or "PUT" verbs. Also, you will note that we use the X-Vault-Token header and <token_id>. That is the standard way to call up information by way of token in Vault. You will need to enter your root token ID. Because we exported the token ID as an environment variable, you can simply replace <token_id> with $VAULT_TOKEN. 

```bash
curl \
    -H "X-Vault-Token: <token_id>" \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"data":{"passwd":"S33CReT!"}}' \
    http://127.0.0.1:8200/v1/secret/data/secret1
```

If you get a "permission denied" error, make sure you are:

1. Connected to a terminal as root
2. Are using the correct token_id for root. If you like, you can use the environment variable: $VAULT_TOKEN.

> Note: "data" is not necessary in paths that use KV version 1. But get in the habit of using it, because KV version 2 is the default. 

If you didn't like the format of the results, remember, the API (and curl) is meant for machines, not humans. These commands will be used programmatically. However, for easier to read results during this lab, use jq. Simply add ` | jq` on to the end of your command. If you don't have it, install it with your package manager. (Example `sudo apt install jq`).

Let's read the secret we just created. we'll use jq going forward. This time, we use the "GET" verb.

```bash
curl \
    -H "X-Vault-Token: <token_id>" \
    -X GET \
    http://127.0.0.1:8200/v1/secret/data/secret1 | jq
```

That should show the actual secret under the "data" sub-block.

### Create a user and login as that new user
Create a payload file for the new user:

`vim payload.json`

Add the following to the file:

```bash
{
  "password": "bad-password"  
}
```

Save the file and exit.

Then, create the user in Bash with curl while calling on the payload file. (Remember to replace <token_id> with the correct ID or variable.)

```bash
curl \
    --header "X-Vault-Token: <token_id>" \
    --request POST \
    --data @payload.json \
    http://127.0.0.1:8200/v1/auth/userpass/users/test_user2 | jq
```

That should create a new user named "test_user2".

Display the details of that user:

```bash
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    http://127.0.0.1:8200/v1/auth/userpass/users/test_user2 | jq
```
Now, login as the user!

```bash
curl \
    --request POST \
    --data @payload.json \
    http://127.0.0.1:8200/v1/auth/userpass/login/test_user2 | jq
```
The results should show that test_user is logged in and has a lease that is renewable.

Export the token for the user as USER_TOKEN:

`export USER_TOKEN=<token_id>`

Try viewing the secrets engines in Vault. It should result in a permission denied error:

`VAULT_TOKEN=$USER_TOKEN vault secrets list`

Now, try simply viewing the status of the Vault. This should work:

`VAULT_TOKEN=$USER_TOKEN vault status`

Try creating a secret (in the cubbyhole because we don't have access to anything else yet) and view the secret.

`VAULT_TOKEN=$USER_TOKEN vault kv put -mount=cubbyhole secret1 this=that`

`VAULT_TOKEN=$USER_TOKEN vault kv get -mount=cubbyhole secret1`

---
## *That was a lot! But you made it! Great job.*
---
