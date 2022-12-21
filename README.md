# crtsh

Crtsh is a tool that finds automatically a lot of subdomains through ssl certificates, using https://crt.sh in an efficient way.

## Install

To install `crtsh` run the following command:

```
git clone https://github.com/nahuelrm/crtsh; cd crtsh; chmod +x install.sh; ./install.sh
```

## Usage

Run this command to check for dependencies:

```
crtsh -d
```

Run this command to find subdomains using https://crt.sh, check for alive hosts, and grep for important ones:

```
crtsh -l -i -a <domain/file>
```

## Options

| Option | Description |
| :--- | :--- |
| `-s <domain>` | small target scan |
| `-b <domain>` | big target scan |
| `-a <domain>` | automatic target scan |
| `-i` | grep important subdomains |
| `-l` | check for alive hosts |
| `-c <domain>` | check a target size |
| `-d` | check for dependencies |
| `-h` | show help panel |

## TO-DO List

- screenshot alive hosts option (using other tool)
- add wordlist support for grepping important domains
- uninstall and update script
