# dotfiles

Bootstrap a fresh macOS install with Homebrew, GNU Stow, Ansible Vault-backed secrets, and a few setup scripts.

## Fresh install

```bash
git clone https://github.com/henrik0804/dotfiles.git
cd dotfiles
./install.sh
```

Sauels-specific setup is opt-in:

```bash
./install.sh --include-sauels
```

Or enable only individual pieces:

```bash
./install.sh --with-sauels-repos
./install.sh --with-vpn
./install.sh --with-legacy-node
```

`install.sh` will:

1. install Homebrew if needed
2. run `brew bundle --file Brewfile`
3. stow dotfile packages into `$HOME`
4. decrypt any Ansible Vault secrets from `secrets/**/*.vault`
5. run macOS defaults and generic repo cloning when present

By default, it skips Sauels repositories, Tunnelblick/VPN setup, and legacy Node 14 setup. Use `./install.sh --help` to see all flags.

## Adding software

Add software to `Brewfile` instead of editing `install.sh`:

```bash
brew bundle add <formula-or-cask>
# or edit Brewfile directly, then run:
brew bundle --file Brewfile
```

For apps from outside Homebrew, prefer creating a small dedicated script and calling it from `install.sh` only if it truly cannot be represented in `Brewfile`.

## Adding dotfiles

Create a top-level directory that mirrors `$HOME`. `stow.sh` automatically stows every top-level package except internal directories such as `.git` and `secrets`.

Example:

```text
mytool/.config/mytool/config.toml
```

Then run:

```bash
./stow.sh
```

No `stow.sh` edit is required for new packages.

## Secrets with Ansible Vault

Secrets live in `secrets/` as encrypted `.vault` files. The path under `secrets/` mirrors the destination path in `$HOME`; the `.vault` suffix is removed when decrypted.

Examples:

```bash
mkdir -p secrets/.ssh secrets/.config/rclone secrets/.cloudflared
ansible-vault encrypt --output secrets/.ssh/config.vault ~/.ssh/config
ansible-vault encrypt --output secrets/.ssh/id_ed25519.vault ~/.ssh/id_ed25519
ansible-vault encrypt --output secrets/.config/rclone/rclone.conf.vault ~/.config/rclone/rclone.conf
```

See `ansible-secret-candidates.md` for the repo scan and suggested secret migrations.

Restore secrets with:

```bash
./secrets.sh
```

This repo uses a generated 32-byte random Ansible Vault password stored locally in `.ansible-vault-password` and ignored by git. That is better than a human password and simpler than certificate/key-file schemes because Ansible Vault encryption is symmetric password-based.

Create or update vault files from the current machine with:

```bash
./vault-migrate.sh
```

Store the contents of `.ansible-vault-password` in 1Password or another password manager. The default 1Password location is:

```text
op://Private/dotfiles-vault/password
```

On a fresh machine, use the 1Password-backed flag:

```bash
./install.sh --vault-password-1p
```

That falls back to the default 1Password ref above. To use a different 1Password field:

```bash
./install.sh --vault-password-1p --vault-1p-ref 'op://Private/some-other-item/password'
```

Other supported options:

```bash
DOTFILES_VAULT_PASSWORD_FILE=/path/to/password ./install.sh
DOTFILES_VAULT_PASSWORD_COMMAND='op read op://Private/dotfiles-vault/password' ./install.sh
```

If `.ansible-vault-password` exists in the repo checkout locally, `secrets.sh` uses it automatically before trying the 1Password flag.

This keeps 1Password optional: it can still bootstrap the vault password, but adding new secrets no longer requires changing the install script.

`.gitignore` ignores decrypted files in `secrets/` and allows only encrypted `*.vault` files to be committed.

If a vault secret overlays a path that was already created by Stow, `secrets.sh` removes the symlink before decrypting so plaintext is not written back into this repository.

## Post-install todo list

- [ ] Install tools through JetBrains Toolbox
- [ ] Import PhpStorm settings from `jetbrains/phpstorm/settings.zip`
- [ ] Set Brave as default browser
- [ ] Grant accessibility permissions to: Aerospace, Borders, Hammerspoon, Raycast
- [ ] Set Caps Lock to Ctrl in macOS keyboard settings
- [ ] Enable Brave sync
- [ ] Install Raycast extensions:
  - [ ] Ploi
  - [ ] Obsidian
  - [ ] Aerospace
  - [ ] 1Password
  - [ ] Spotify
  - [ ] cURL
  - [ ] Laravel Herd
  - [ ] Random Data Generator

## Additional setup

- [ ] Install Node.js 14 via nvm if a legacy project still needs it
- [ ] Install laravel-echo-server if a legacy project still needs it
- [ ] Install Docker CLI / Docker Desktop if not managed by Homebrew
