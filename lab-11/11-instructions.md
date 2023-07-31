# Lab 11 - Transit Secrets Engine
In this lab we will run a dev Vault server, enable the transit secrets engine and encrypt and decrypt text.

Go ahead and run a Vault dev server now in the same manner you have before.

Run `vault status` and verify that the vault is ready.

## Enable the transit secrets engine
First, let's review what secrets engines are currently running in our dev server:

`vault secrets list`

You should see the default four: cubbyhole, identity, secret, and sys.

Now, let's enable the transit secrets engine:

`vault secrets enable transit`

You should see a success message. Verify that it is running:

`vault secrets list`

## Create an encryption key ring
This will be the encryption key used to create ciphertext for our data. 

`vault write -f transit/keys/emails`

This writes the key ring to the transit/ path. We could use another path, or additional paths if necessary with the `-path=` option.

> Note: `-f` is the `-force` option. This forces operations and will write a key that does not need data and can continue with no KV pairs.

## Write a transit policy and create an associated token
Take a look at the supplied policy named *emails-policy.hcl*. It allows the update capability for encrypting and decrypting data. we will write this policy to Vault and then use it as the basis for a new token that we create later.

Remember that you need to specify the policy name (for Vault) and then the policy filename.

`vault policy write emails-policy emails-policy.hcl`

That should be successful. Check it with the following command:

`vault policy list`

You should see the following policies: default, root, and emails-policy.

Create a new token for use with the policy:

`vault token create -policy=emails-policy`

That should supply you with a new token that uses the *default* and *emails-policy* policies.

Create an environment variable for the token ID:

` export EMAILS_TOKEN="<token_id>"`

Copy and paste the token ID that was listed in the previous command results.

Now we can use that token's EV to do our work.

## Encrypt data
We will encrypt plaintext data using our new token that we created.

```bash
VAULT_TOKEN=$EMAILS_TOKEN vault write transit/encrypt/emails \
plaintext=$(base64 <<< "<fake_email_address>")
```

> Note: Enter in a fake email address such as: info@company.local

The ciphertext should be displayed in the Value column. You just encrypted plaintext so that it can no longer be read (unless you have the decryption key - and we do!)

## Decrypt data
When an app is ready to read or send actual data, it will have to decrypt it. Do so with the following command:

```bash
VAULT_TOKEN=$EMAILS_TOKEN vault write transit/decrypt/emails \
ciphertext="<vault_ciphertext>"
```

> Note: For <vault_ciphertext>, copy and paste the value for the ciphertext that was displayed before. It starts with "vault:V1:"

That should return a plaintext value. It is important to note that at this point the data has been decrypted! However, this is still base64 encoded. Use the `base64` command to decode the plaintext.

`base64 --decode <<< "<plaintext_value>"`

When you do so, base64 should decode that to the original email address you originally encrypted.

> Note: There are other encoding methods available such as hex, base36, and so on. However, base64 is an accepted standard.

> IMPORTANT! Don't confuse encoding with encryption. We use encoding to store information as a certain data type. However, it does not use a key. Anyone with access to the base64 command can decode text. It is not encryption and is not a substitute. Actual encryption methods use a key (which should be kept separate). Take a look at the difference between your base64 encoded plaintext and the actual ciphertext (starting with "vault:v1:")

When it comes to security and encryption, we could go on and on. But that's a good start.

---
## *Excellent work! That was the last lab. Great job!*
---
