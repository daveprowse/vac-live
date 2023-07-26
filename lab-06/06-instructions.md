# Lab 06 - Vault Tokens
In this lab we will create and revoke service tokens. We'll also configure and test use-limits and TTLs.

## Start a Dev Server
Start a dev server, and in another terminal export the vault address and vault root token environment variables.

## View the help file
Run the following commands:

`vault token -help`

View the sub-command options. Then:

`vault token create -help`

Take a minute to view what the `vault token create` command does and examine the options. There are many. Focus your efforts on the `-ttl` and `use-limit` options for now.

## Create a token
As you recall, we created a token in a previous lab with a policy attached. This time we will create a token without specifying a policy.

`vault token create`

When you run this command, it builds a new root token. Examine the results. 

This is a child token of the current token we are using. It created a root token because we are connected as root. Note that there is no time-to-live (TTL) and the token duration is infinite (as shown by the ∞ symbol). 

> Important!!! Be very careful with root tokens. Revoke them as soon as you are done with them!

## Revoke a token
Now let's practice some good security and revoke the child root token that we just created.

First, copy the token id. It should have been displayed when you created the token previously. (It starts with "hvs.")

Next, issue the following command:

`vault token revoke <token_ID>`

That should successfully revoke the child root token.

> Note: This does not remove the main root token that you authenticated with, only the child root token that we created.

## Create another token based on the default policy
We are root, so we can create as many tokens as we wish. Let's use that power.

This time, we'll create a token that has the *default* policy attached. We'll also set a TTL and a use-limit.

`vault token create -ttl=1h -use-limit=3 -policy=default`

Examine the results. You should see that the policy is *default*. Also, you will see that the token duration is 1 hour and that it is renewable. In addition, it has a use-limit of 3, which means we can do three things with this token before it is revoked.

## Use up our new token
First, let's set up an environment variable to reference the token ID. 

Copy the token ID (starting with hvs.) and paste it into the following command:

` export LIMITED_TOKEN="<token_id>"`

View the token data:

`vault token lookup $LIMITED_TOKEN`

That is not considered to be a use of the token. Look at the num_uses Key, it should show 3 in the Value column. 

Now, set the VAULT_TOKEN value to our new environment variable, and run a command to lookup that token: 

`VAULT_TOKEN=$LIMITED_TOKEN vault token lookup`

That was considered a "use" of the token. So now, in the results you should see it says: num_uses = 2. We only have two uses left. 

Run the same command three more times. It should work for the first two (with the num_uses value decrementing by 1 each time). But the third time should fail and show a permission denied error. That is because we hit our use limit and the token has been revoked.

You can prove this by typing the following command:

`vault token lookup <token_id>`

using the same token ID we just used previously (it should still be in your clipboard, and you can paste it in.)

The result should display the "* bad token" message. Even if you try to renew the token, you will find that the *token not found* message is displayed. That's because it is gone.

## Create and renew another token within the TTL
Create a new token with the following command:

`vault token create -ttl=1h -policy=default`

Note that we are not specifying a use-limit this time. That means that we can use the token as much as we want.

Wait 15 seconds and then lookup the token's details (pasting in the token ID):

`vault token lookup <token_id>`

Examine the "ttl" value toward the bottom of the key column. This should show less than 59 minutes and 45 seconds. 

Now, renew the token:

`vault token renew <token_id>`

Quickly, press the up arrow to run the previous `vault token lookup` command. 

You should see that the TTL has reset and has begun counting down again. 

## View the accessor value and revoke the token
Run a `vault token lookup <token_id>` command and examine the accessor key value. The accessor value is a reference value assigned to the token.

Now, display all accessor key values:

`vault list auth/token/accessors`

This should display the accessor value for the token you created as well as the root token accessor value.

Revoke the token:

`vault token revoke <token_id>`

If that is successful, run the following command again:

`vault list auth/token/accessors`

The token you had created should not be listed anymore. 

## Revoke the root token and check access
Let's remove the token and show how it no longer has access to the vault.

`vault token revoke <root_token_id>`

Now, try to create a new token. It should fail with a *permission denied* error. 

Try listing the accessors as we did before.

`vault list auth/token/accessors`

This should fail as well. We are no longer root! Careful with this though. You now lose access to the vault!

---
## *As a token of my appreciation, I present to you a gift......  More labs! Continue! :)*
---
