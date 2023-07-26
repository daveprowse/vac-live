# Lab 05 - Vault Policies

In this lab we will use a dev vault to practice creating a policy and accessing individual capabilities (permissions) within that policy.

> Note: To keep things simple, and speed up the process, we'll use a basic dev vault so that we can bypass the process of initializing and unsealing.

> Note: Close any currently running vaults before performing this lab.

---

## Start the Dev Server
Make sure your terminal's working directory is lab-05. 

- Run the dev server with the following command:

`vault server -dev`

- Then, *in another terminal*, export the VAULT_ADDR and VAULT_TOKEN environment variables:

` export VAULT_ADDR=http://127.0.0.1:8200`

` export VAULT_TOKEN=<root_token>`

Verify that your dev vault is running with `vault status`. 

If it is running, then Phase 1 is complete because we are not connecting to an authentication backend in this lab.

## Review the included policy
Normally. you would author a policy. This would be part of phase two: "Author the policy". However, there is a supplied policy for you in the lab-05 directory called admin-policy.hcl. Review it now. You will see many permissions set within the policy. We will analyze a couple of them later.

## Upload (write) the policy to the vault
One you are sure that your policy is set up properly, it needs to be written (or uploaded) to the vault. Use the following command:

`vault policy write admin admin-policy.hcl`

This is phase 3. If you have supplied your root token, this should be successful. At this point the policy will be created. (Careful, if a policy already existed with this name, it will be updated.) 

## Display the policy
To view all policies on the system:

`vault policy list`

You should see all policies in the Vault including the built-in policies (*default* and *root*) and the new *admin* policy we just created.

To view the new admin policy we created:

`vault policy read admin`

You will see that this simply displays the entire policy that we reviewed previously.

> Note: You could also view the policy by path using the `vault read` command: `vault read sys/policy/admin`

Try viewing this information via the API:

> Note: You will need JSON processor (jq) installed to complete the API call. Linux users can install it with their package manager, for example: `apt install jq`. 

```bash
curl --header "X-Vault-Token: $VAULT_TOKEN" \
      $VAULT_ADDR/v1/sys/policies/acl/admin | jq
```

Within the data > policy sub-block you should see the entire *admin* policy.

> *Optional*: Take a quick focus break! One deep breath, and back to it. You're doing great!

## Create and display tokens
First, we'll create a basic token with the policy attached:

`vault token create -policy=admin`

That creates a token for us that has the admin policy attached. 

Now, create a new token with the *admin* policy attached and defined as an environment variable. 

`ADMIN_TOKEN=$(vault token create -format=json -policy="admin" | jq -r ".auth.client_token")`

This way, you have a token created with a variable that we can reference later (ADMIN_TOKEN). 

> Note: Again, this requires the JSON processor (jq).

Now, display the new ADMIN_TOKEN that we just created:

`echo $ADMIN_TOKEN`

You should see a system token (starts with .hvs) that was created when we issued the previous command. 

> Note: You could have also issued the `vault token lookup $ADMIN_TOKEN` command to view the token and its details.

## View capabilities (permissions) of a token
Now, view the capabilities of the token we created using the environment variable.

First, we'll check something that the token definitely has access to - approle. 

`vault token capabilities $ADMIN_TOKEN sys/auth/approle`

You can see that we have the create, delete, sudo, and update capabilities concerning the approle auth method. 

This information comes directly from Vault, but it originally was defined in the admin-policy.hcl file. Take a look at that policy file now and view line 30. This shows the path "sys/auth/*" which means all authentication types including approle. Then note the capabilities below it. They should be exactly the same as the listed capabilities we just saw in the terminal. 

Now try another path:

`vault token capabilities $ADMIN_TOKEN sys/auth`

This should only show the "read" capability. While the token has full access to the auth method named approle, it can only read the parent directory in that path. This is shown in the policy file in lines 36-39. 

Here's another:

`vault token capabilities $ADMIN_TOKEN auth/`

Essentially, this token can do anything when it comes to the auth path. Note the path and capabilities for that in the policy file, lines 24-27. 

Now, check something else that the token definitely should *not* have access to:

`vault token capabilities $ADMIN_TOKEN identity/`

You should see the "deny" capability displayed. That means that this token has no access to the identity/ path. The "identity" path is not listed in the policy at all. Therefore, Vault performs an implicit deny. 

## Stop the Vault
Press `Ctrl+C` to close the vault.

---
## *Nice work! That completes this lab. Continue!*
---

