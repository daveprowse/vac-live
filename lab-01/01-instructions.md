# Lab 01 - Install Vault
Welcome to the first lab! 
In this lab you will install the HashiCorp Vault program to your system. 
Remember, in this course, I am demonstrating on a Debian Linux virtual machine. Let's go!

## Update your system. (Optional due to time constraints)
If you do not have automatic updates running, then update your operating system before continuing with the installation.  

Restart the system when complete.

## Install Vault from the HashiCorp installation web page:
There are two options. Using a package manager for your operating system or installing by downloading a binary. If you are new to installing programs of this nature, I recommend Option #1.

**Option #1** - Install using your package manager.

https://developer.hashicorp.com/vault/docs/install

Locate your operating system and install Vault following the directions.

> Note: Windows users should run PowerShell as an Administrator. Also, consider using Windows Terminal multiplexed to display three different PowerShell terminals.

**Option #2** - Install the binary.

https://releases.hashicorp.com/vault 

Locate the latest version for your platform, download it, verify the checksum, unzip it, and copy it to the proper binaries directory (such as: /usr/local/bin). More instructions are available at the link in Option #1. 

If you have any issues, ASK QUESTIONS! 

> Note: As you progress, Option #2 will be the preferred method of the two. Furthermore, for custom installations, you might need to install from source. Get the source files here: https://github.com/hashicorp/vault. 

## Verify that Vault is installed and view the version.
`vault -v` 

## Install Vault autocomplete (Linux and macOS users)
First, make sure that you have an existing .bashrc or .zshrc file. 
  
If not, create one, for example:
    
`touch ~/.bashrc`

Install autocomplete: 

`vault -autocomplete-install`
  
Restart the shell.

Verify that autocomplete works by typing the first three letters of a subcommand. For example, `vault sta`, then press <kbd>Tab</kbd> which should complete the subcommand and show `vault status`.

> Note, you cannot install this to Windows, but the Windows Terminal program will recognize vault subcommands and you can press the right arrow key for auto-completion. 

*Use auto-complete as much as possible to reduce the amount of characters your fingers have to type!*

## Examine the help system
First, analyze the main help command:

`vault -h`

You could also type the following options: 

`vault -help`, `vault --help`, or `vault --h`

Take note of the main commands including: read, write, delete, list, login, agent, server, status, and unwrap.

Now, learn more about a subcommand. 

  For example: 
  
  `vault -h read`

  You could also type: `vault read -h` if you wish.

  Understand where to place options and arguments.

---
## *Congratulations! You just finished your first lab!*
---

## (Optional) VSCode HashiCorp HCL extension
If you use Visual Studio Code, consider installing the official HashiCorp HCL extension.
This extension adds syntax highlighting for HashiCorp Configuration Language (HCL) files. 

Install from Quick Open (Ctrl+P):
`ext install HashiCorp.HCL`

Link: https://marketplace.visualstudio.com/items?itemName=hashicorp.hcl

> Note: If you plan to read these markdown files in preview mode, consider the Markdown Preview Github Styling extension:
>
>Install (Press `Ctrl+P`, then:) 
>`ext install bierner.markdown-preview-github-styles`
>
>Link: https://marketplace.visualstudio.com/items?itemName=bierner.markdown-preview-github-styles

## (Optional) Install a Vim Module
If you use Vim, you might want to consider a syntax highlighting module (such as Polyglot) or the HashiVim module. 

See the opt-01 directory for more information.

