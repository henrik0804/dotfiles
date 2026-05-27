# Ansible Vault secret candidates

This repository was scanned for machine-local credentials, account state, and customer-specific private configuration. Store these as encrypted files under `secrets/` with paths that mirror `$HOME`.

## Vault password

Use a generated random password, not a human memorable password and not a certificate file. Ansible Vault is symmetric password-based; a local key file is just a password file in practice.

This repo now uses `.ansible-vault-password`, generated with:

```bash
openssl rand -base64 32
```

That produces 32 random bytes encoded as a 44-character string. Store that value in 1Password or another password manager, and keep `.ansible-vault-password` uncommitted.

## High priority

The following should be encrypted with Ansible Vault and not committed as plaintext:

| Destination | Vault file | Notes |
| --- | --- | --- |
| `~/.ssh/config` | `secrets/.ssh/config.vault` | Host aliases, usernames, private hostnames. |
| `~/.ssh/id_ed25519` or `~/.ssh/id_rsa` | `secrets/.ssh/id_ed25519.vault` / `secrets/.ssh/id_rsa.vault` | Private SSH keys. Public keys may stay plaintext if desired. |
| `~/.config/rclone/rclone.conf` | `secrets/.config/rclone/rclone.conf.vault` | Usually contains OAuth refresh tokens or storage credentials. |
| `~/.cloudflared/cert.pem` | `secrets/.cloudflared/cert.pem.vault` | Cloudflare tunnel certificate. |
| `~/.cloudflared/*.json` | `secrets/.cloudflared/<tunnel-id>.json.vault` | Cloudflare tunnel credentials. |
| `~/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk/Contents/Resources/config.ovpn` | `secrets/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk/Contents/Resources/config.ovpn.vault` | Sauels VPN profile. |
| `~/.config/opencode/opencode.json` | `secrets/.config/opencode/opencode.json.vault` | Use if it contains provider keys, MCP API keys, OAuth material, or other local-only account config. |
| `~/.config/gh/hosts.yml` | `secrets/.config/gh/hosts.yml.vault` | Only needed if the file contains `oauth_token` or other auth state. Current tracked file has no token. |
| `~/.local/share/atuin/key` / Atuin auth files | matching `secrets/.../*.vault` path | Atuin sync encryption/auth material, if present on a machine. Current tracked Atuin config has no secret. |

## Already cleaned up

`opencode/.config/opencode/opencode.json` contained a Context7 API key in plaintext. The key was removed from the tracked config. Rotate that key because it has already existed in the git worktree/history.

If opencode requires that key inline, create an encrypted full-file overlay:

```bash
ansible-vault encrypt \
  --output 'secrets/.config/opencode/opencode.json.vault' \
  ~/.config/opencode/opencode.json
```

During `./install.sh`, `secrets.sh` decrypts this file to `~/.config/opencode/opencode.json`. If that path is a Stow symlink, the symlink is removed first so decrypted secret material is not written back into the repository.

## Commands to migrate existing local secrets

```bash
mkdir -p \
  secrets/.ssh \
  secrets/.config/rclone \
  secrets/.cloudflared \
  'secrets/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk/Contents/Resources'

ansible-vault encrypt --output secrets/.ssh/config.vault ~/.ssh/config
ansible-vault encrypt --output secrets/.ssh/id_ed25519.vault ~/.ssh/id_ed25519
ansible-vault encrypt --output secrets/.config/rclone/rclone.conf.vault ~/.config/rclone/rclone.conf
ansible-vault encrypt --output secrets/.cloudflared/cert.pem.vault ~/.cloudflared/cert.pem
ansible-vault encrypt --output secrets/.cloudflared/7cad62df-2c79-44bb-b54e-31c590201830.json.vault ~/.cloudflared/7cad62df-2c79-44bb-b54e-31c590201830.json
ansible-vault encrypt \
  --output 'secrets/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk/Contents/Resources/config.ovpn.vault' \
  '$HOME/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk/Contents/Resources/config.ovpn'
```

Only commit the resulting `*.vault` files. Do not commit decrypted output.
