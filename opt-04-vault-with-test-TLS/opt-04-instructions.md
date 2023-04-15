# Opt 04 - Vault with UI, RAFT and Configs
In this lab we will work with the UI but utilizing a proper server setup with a configuration file and Raft storage. 

> Note: This lab takes things to the next level. As of the writing of this lab, there was is issue with Vault 1.13 where modifications in the UI can only be done if TLS is running. So, we will incorporate a hostname and a basic TLS certificate.  That requires some networking changes. Be ready! 

> Note: As usual, I recommend a Linux virtual machine for this lab. More so for this lab because of the extra configurations we will have to make to the system.

## Configure the local system
To use TLS and domain names properly you might need to rename your system and modify the hosts file. An easy way to do this is to add a local domain suffix to your hostname. For example, you could change computer1 to computer1.local. Of course, other domain suffixes can be used as well. In the field, you would use a real domain, but for educational purposes, .local (or a similar local testing domain suffix) should be fine.

- Modify the hostname, In Linux do:

  `hostnamectl set-hostname <new_hostname>`

  For example: `hostnamectl set-hostname pt1.local`

- Use the `ip a` command to find out your system's IP address.

- Modify the hosts fle. (You will need administrative/sudo rights to do so.) In Linux, open the hosts file:

  `sudo vim /etc/hosts`

  Add a line that will allow for name resolution. The syntax convention for this is:

  `<ip_address>    <FQDN>    <hostname>`

  Use your system's actual IP address. So, for example:

  `10.0.2.52    pt1.local    pt1`

  Save the file and close out.

Now we will be able to access our Vault server from IP address as well as from hostname (or FQDN). In addition, we can build a TLS certificate for use with the Vault server.

## Configure TLS
Here we will build a TLS certificate to be referenced from our Vault server configuration file. This requires that you have OpenSSL installed on your system. (As always, using a Linux virtual machine is the best way to test this kind of thing.)

> Note: You will need OpenSSL. It is installed on most Linux systems by default. To find out the version, type `openssl version` or `ssh -V`. If it is not installed, you can install OpenSSL on Linux using your package manager. For example: `sudo apt install openssl`. 

- Modify the OpenSSL certificate configuration file. This is called "myopenssl.cnf". You will need to modify the last three lines of the file. For example:
  - IP.2 = 10.0.2.52
  - DNS.1 = ip-10-0-2-52
  - DNS.2 = pt1.local
  > Note: Your configuration will vary. See the solution directory for the full example.
- Pass the configuration to OpenSSL. Modify the TTL (days) and RSA strength as needed. 
  
  `openssl req -x509 -nodes -days 3 -newkey rsa:3072 -keyout key.pem -out cert.pem -config myopenssl.cnf`

- Check the certificate
  
  `openssl x509 -in cert.pem -text -noout` 


## Build a Vault server from config file  
Examine the supplied configuration file named server-config.hcl. You will note a couple of things:

- "ui" is set to true. That means that we are enabling the web-based user interface for users. If we didn't want that (and quite often we don't) we would set that to "false". 
- The storage block calls for a path of ./data. We will have to create that directory.
- The listener address says <ip_address>. For this lab, enter your system's IP address instead of using 127.0.0.1 or 0.0.0.0.  For example: 
  - address = "10.0.2.52:8200"
  > Note: Your IP address will vary!
- For now, we'll leave the API and cluster address as the localhost. 
- You will also see that instead of setting TLS to disabled, we are specifying a certificate file and key file. That has already been taken care of for you. 
- Save the file

Create the data directory

- Make sure that you are working in the lab-09 directory. 
- Create a new directory called "data": `mkdir data`

Build the Vault dev server with the following command:

`vault server -config=server-config.hcl`

That should create a sealed and *un*initialized vault.

In another terminal, export the Vault address:

` export VAULT_ADDR=http://<ip_address>:8200`

  > Note: replace <ip_address> with your actual IP address.
  > Note: Consider executing that last command in two separate terminals so you have multiple places to work.

Run `vault status`. You should see a working vault. However, it is sealed and it is not initialized. We will take of that from the UI.

## Connect to the UI, unseal Vault, and sign in
Open a browser and connect to your Vault server:

`https://<hostname>:8200`

Bypass the security message and continue to the server.

> Note: This connection will be seen as insecure. That is because we are using a self-signed certificate. For educational purposes, this is easier than obtaining a proper TLS certificate from a third party. To take this lab to the next level, consider using Let's Encrypt or a similar service.

When you connect you should be automatically forwarded to the Raft Storage page. That is because the Vault is sealed.

Select "Create a new Raft cluster" and click Next.

Now we need to set up the root keys that can be used to seal/unseal the vault. 

- For Key shares, enter 5
- For Key threshold, enter 3.
- Click Initialize

That will create the initial root token, and 5 keys based on that root token. 

Download the keys. They will be downloaded as a JSON file.

Click "Continue to Unseal"

Use three keys from the downloaded JSON file to unseal the vault.

Now sign in to Vault with the Token method. Use the root token that was created during the initialization process. (It is also in the JSON file.)

Once complete, you should be signed in and should see the cubbyhole secrets engine for the root account.

*Great work so far! Take a deep breath and continue.*

## Analyze the system from the CLI
Go to the terminal and run the `vault status` command.

You should note a couple of things:

- The vault is now initialized and unsealed. (You can also see this in the Vault log.)
- Vault is using raft storage.
- High availability (HA) has been enabled. (That's because we created a raft cluster in the UI!)

> Note: If the rest of this section fails for you, skip it and continue to the next section.

Now, attempt to view the secrets engines that are running:

`vault secrets list` 

This should fail. Permission should be denied. While we have been given access to the UI, we have not gotten access to the CLI yet - the two are separate. 

Export the root token as an environment variable:

` export VAULT_TOKEN=<token_id>`

The token_id was the one we used in the UI.

Run `vault secrets list` again.

You should see the cubbyhole, identity, and system secrets engines running. Remember, these always run, but the identity and system secrets engines are not visible in the UI. 

## Create a new user and attempt to connect from another system
Now, let's setup userpass authentication in the UI. Then, we'll create a new user and attempt to connect from a remote system as that new user account. 

> Note: If you don't have another system to connect with, simply use another tab in the browser.

Go to the browser. You will see in the top menu that the root account can use Secrets, Access, Policies, and Tools. 

Click on "Access" now. By default, that places you in the "Auth Methods" section. 

Click "Enable new method +" 

Select "Username & Password" and click Next.

Click "Enable Method". 

That will enable the userpass auth method and place you in a configuration screen where you can modify TTLs, select token type, and more.

## Create a new user
Return back to Access > Auth Methods. 

Click on "userpass"

Click on "Create user +"

Select a username (for example, test_user1) and password and click Save.

Now we have a new user to work with.

## Keep going!
What you have running is very similar to a real production Vault server. Work with this server as if it is an actual Vault server. Continue with any configurations you want to accomplish. 

**More!** The only things that you would need to make this a fully-fledged working Vault server is to setup DNS and use a real certificate. Consider the following:

- Get a real domain that you can utilize with Vault and enable it properly with your domain registrar or with Cloudflare.
- Utilize Let's Encrypt (certbot) to build a proper TLS certificate for the domain. 
- (Optionally) run the BIND DNS server which forwards out to a real DNS server.
- You might also choose to run this on the cloud (AWS, or other) so that you can implement DNS and other networking functionality more easily. 

Good luck!

