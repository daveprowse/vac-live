# Lab 07 - Vault Leases
In this lab we will setup IAM users in AWS from Vault. Then we will show how to view, renew and revoke the leases associated with those users. 

> Important! Cloud-based providers (such as AWS) charge for their services. The cost of this lab should be low (or nil depending on your location and configuration), but be warned that you may incur cost. 

## Start a Dev Server
Start a dev server, and in another terminal export the vault address and vault root token environment variables.

## View the help file
Run the following commands:

`vault lease -help`

View the subcommand options. Then:

`vault lease lookup -help`

Take a minute to view what the `vault lease lookup` command does and examine the options the primary help information.

## Log into the AWS console and create an access key
Log in to the AWS console with a new, test user. Make sure that the user has zero access keys set up currently. 

> Note: Make sure that you are using a test IAM user to log in with and not your main (or root) account. For more information on how to create a new IAM user, see this link: 

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html  

Make sure that your IAM user has zero access keys. 

Create a new access key 

- Click on your user account menu on the upper-right
- Select "Security Credentials"
- Scroll down and locate "Access keys"
- Click on "Create access key"
- Select "Command Line Interface (CLI)"
- Click the checkbox at the bottom stating that you understand the above recommendations and click Next.
- Enter "vault-access-key" in the description tag value field and click "Create access key".

Leave that screen open while we work on the next step. (Or download the .csv file if you wish.)

## Enable the AWS secrets engine in Vault and configure credentials
- Enable the AWS secrets engine

  `vault secrets enable aws`

  Verify that you get a "Success" message. You can also type `vault secrets list` to verify that the AWS secrets engine is running.

- Configure the AWS credentials

  It's recommended that you use environment variables for this procedure instead of hard coding them into Vault. Copy and paste the keys into the following `export` commands.

  `export AWS_ACCESS_KEY_ID=<aws_access_key>`
  
  `export AWS_SECRET_ACCESS_KEY=<aws_secret_key>`

  > Note: You will need to replace <aws_access_key> and <aws_secret_key> with your key values from the access key you generated at the AWS console.

  > Note: Windows users, use `$env:` to export environment variables.

  Next, use the `vault write` command to enter in your AWS credentials into Vault.

  ```bash
  vault write aws/config/root \
    access_key=$AWS_ACCESS_KEY_ID \
    secret_key=$AWS_SECRET_ACCESS_KEY \
    region=us-east-2
  ```
  
  Take notice of the path that the access key is being written to: aws/config/root. This is the secrets engine path leading to the root authorization. Use it with caution!

  > **Security alert!!** This is only one method of depositing the AWS secret key. You could also use AWS environment credentials or cloud-based variable options. Just don't hard-code them!

  Make sure that this is successful. If not, check and make sure that the AWS secrets engine is running in Vault. 

  If successful, Vault will now internally connect to AWS using the credentials you provided. 

*Take a deep breath! You are doing great!*

## Configure a Vault role
Now we can configure a role that will be stored in Vault. This role will allow IAM users to work with the EC2 platform and create instances on AWS. 

Enter the following in the terminal (Bash or similar):

```bash
vault write aws/roles/my-role \
    credential_type=iam_user \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOF
```

Verify that you get a "Success!" message.

Here, we used the `vault write` command to build a new role in Vault. Take note of the credential type - it is iam_user. Later, we will build actual AWS IAM users that are based on this role. 

> Note: You could use a similar `vault write` command to build assumed_role and federation_token credentials as well. 

## Generate new credentials
Now we'll build IAM users based on the role that we just created. To do this, we use the `vault read` command. 

`vault read aws/creds/my-role`

The response in the CLI should show a new lease ID, access key, and other information for the new IAM user. For example:

```bash
Key                Value
---                -----
lease_id           aws/creds/my-role/n1JDt9KzuY4apiIEk11FahIU
lease_duration     768h
lease_renewable    true
access_key         AKIA33FNGQ2MNZYK7DE3
secret_key         bvHnU/ZMIqWtq3+YXfAowqjkyGlqjjbnKlgONbbB
security_token     <nil>
```

If the command was successful, then you just generated your first dynamic credentials! At this point, the new IAM user should be displayed in the AWS console. Go to your AWS console, then IAM > Users. The new user should be named "vault-token-my-role-...etc..." Click on the IAM user and go to "Security credentials". You should also see the Access key that was created automatically by Vault.

** Run the command two more times so that you end up with three new IAM users. Check it in the AWS console.

## Modify the lease duration
To renew a lease, use the `vault lease renew` command and specif the lease ID. But let's take it further...

Go back to the CLI and view the lease_duration for the last IAM user you created. It should show 768 hours. This is a default number, but it can be modified, either within a policy or by using the `vault lease renew` command. Let's show that command now:

`vault lease renew -increment=3600 <lease_id>`

You need to paste in the entire lease ID and path. So for example, using our previous IAM user that was created: 

`vault lease renew -increment=3600 aws/creds/my-role/n1JDt9KzuY4apiIEk11FahIU`

That will adjust the lease duration from 768 hours to 1 hour (3600 seconds). The results should look similar to the following:

```bash
Key                Value
---                -----
lease_id           aws/creds/my-role/n1JDt9KzuY4apiIEk11FahIU
lease_duration     1h
lease_renewable    true
```

Now try adjusting the lease duration to something beyond the default 768 hour setting:

`vault lease renew -increment=1000h <lease_id>`

This should give a warning stating that the number you chose is beyond the max_ttl. Instead of 1000 hours, the lease is set to 768 hours (minus any time already elapsed from current usage). That is because the global settings in Vault (and the policy) have a cap on the lease duration. 

> Note: Normally, you wouldn't want a lease that lasts longer than 1 month, because clients could simply renew if they needed to. However, in rare cases you might need to modify the global settings to something higher or use a root token to accomplish this. 

## View leases
Let's take a look at the leases that we have created so far.

Start by viewing the lease for the last IAM user we created:

`vault lease lookup aws/creds/my-role/<lease_id>`

You should see the lease issuance, expiration, last renewal, and the current TTL. 

To view a list of leases for AWS, use the following command:

`vault list sys/leases/lookup/aws/creds/my-role`

That should display all three of the lease IDs for your AWS IAM users. 

## Revoke leases
First, we'll revoke a single lease:

`vault lease revoke aws/creds/my-role/<lease_id>`

From the previous list, copy and paste the last lease ID. 

To verify that the IAM user has been removed, do two things:

  1. Run the `vault list` command you ran previously.
  2. Check the AWS console. 

Now, remove all leases that are left with the following command:

`vault lease revoke -prefix aws/`

Check if it was successful with the `vault list` command used previously and in the AWS console. At this point, all IAM users should have been deleted.

> Important! This removes all secrets/credentials from the AWS path. If you had other AWS components, their leases would be removed as well. To specify leases pertaining to the my-role role only, the command should be:
> `vault lease revoke -prefix aws/creds/my-role`

---
## *Well, our lease for this lab is up. Excellent work!*
---

**Extra Credit**

Remove multiple IAM users by revoking the root token.

1. Create three new IAM users with the `vault read` command used previously. Check that they exist in the AWS console.
2. Revoke the main root token.
  `vault token revoke <root_token_id>`
1. Check the AWS console. All IAM users should be deleted.

This happens because all leases created with a token are "owned" by that token. Revoke the token, and all associated leases are revoked as well. 

Be careful with tokens and their associated leases!

---