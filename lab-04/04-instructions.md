# Lab 04 - Authentication Methods

In this lab we will work with a few different authentication methods in Vault. First, we'll create a new vault. Then we'll initialize and unseal it. After that, we'll enable multiple authentication methods and interact with those methods via the CLI, UI, and API. The main goal is to get you accustomed to working with authentication methods.

This is a longer lab than the previous ones. If you need to take a break or restart/shut down your computer, be sure to save the state of your virtual machine. This way, you can resume your work easily at a later time.

> Note: Again, be prepared to use three different terminals for this lab. 

---

## Start the Server and Unseal the Vault
Make sure your terminal's working directory is lab-04. 

Make a new directory for our data storage:

`mkdir data`

Review the vault-auth-config.hcl file. This is designed to start a basic vault using Raft storage and listen on the localhost IP address. 

- Run the server with the following command:

`vault server --config=vault-auth-config.hcl`

- Then, *in another terminal*, export the VAULT_ADDR environment variable:

` export VAULT_ADDR='http://127.0.0.1:8200'`

- Initialize the vault:

`vault operator init`

This will display 5 unseal codes. It will also display the root token. Copy all of that information to a separate file for re-use later.

- Unseal the vault by pasting in the unseal codes:

`vault operator unseal <unseal_key>`

Repeat this process two more times.

- Verify that the vault is initialized and unsealed:

`vault status`

- Login to the vault as root

`vault login` and paste in the root token. Make sure that you are authenticated to vault.

**Now we can get to the purpose of the lab!**

## Analyze the current vault methods
Use the following command:

`vault auth list`

It should show the that token-based authentication is the only type available. That is the authentication method we used to login as root.

## View the help file
Type `vault auth -h` to view the help file. Take a minute to read through it.

## Enable/disable username/password authentication
In vault, username/password authentication is known as "userpass". 

- Enable userpass:

`vault auth enable userpass`

- Verify that it is running: 
 
`vault auth list`

- Disable userpass:

`vault auth disable userpass`

- Enable userpass with a custom name and description:

`vault auth enable -path=local_logins -description="Local username/password authentication" userpass`

- View the path and description with `vault auth list`

For easier typing, we will disable the current authentication method with the custom path, and enable the more simple "userpass" path.

- Disable the current auth method:

`vault auth disable local_logins`

- Enable the default userpass auth method:

`vault auth enable userpass`

## Create a user in Vault
Create a new user by making use of the `vault write` command.

```bash
vault write auth/userpass/users/test_user \
password=<your-password> \
```

That will create a user named "test_user" with the password you supply. This user will have extremely limited access to the system.

To find out information about the user:

`vault read auth/userpass/users/test_user`

## Login as the new user in the CLI
Go to a *third terminal* and login as the new user:

```bash
vault login -method=userpass \
username=test_user \
password=<your-password>
```

Make note of the token that is granted to the user account, and the duration of that token.

View the token. It is stored in the home directory as:
  .vault-token, 
Compare it with the token that was listed when you logged in. They should be the same.

> Note: This user can now begin creating and viewing secrets the way we did previously.

Try issuing the following command:

`vault auth list`

You will find that the user cannot access this information.

## Log back in as root
Return to the second terminal and connect as root as you did before:

`vault login <root_token>`

> Note: All open terminals reflect the user that is currently logged in.

## Login as the new user from the UI
Open a browser and connect to the local vault:

`http://127.0.0.1:8200`

Click the "Method" drop down menu. Note that many authentication methods are listed, but only "Token" and "Username" are actually being used.

Click on the "Username" method.

Enter the username and password of the user you created previously. That should allow you to access the vault.

At this point the user can work with secrets engines (as long as the user has permissions! more on that later.)

Sign out from the UI

## Accessing information via the API
To see a user's details via the API, type the following:

```bash
curl \
    --request POST \
    --data '{"password": "<your-password>"}' \
    http://127.0.0.1:8200/v1/auth/userpass/login/test_user 
```

That makes a POST request and displays a lot of information.
Note the authentication client token that has been assigned. It should match the token stored in the home directory.

> Note: leave this Vault running so we can demonstrate a couple of things in the following theory segment.

> Note: I set up the *vault-auth* directory for you in case you would like to do additional testing in a separate directory later on.

---
## *Nice work! Continue!*
---
