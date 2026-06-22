# Git Config Breakdown

## [user]
Your identity embedded into every commit.
```ini
name = rn23thakur
email = rn23thakur@gmail.com
```
Must match your GitHub email for commits to link to your profile.

---

## [init]
```ini
defaultBranch = main
```
New repos start on `main` instead of `master`.

---

## [core]
```ini
editor = nvim
```
Neovim opens for commit messages, rebase todos, etc.

---

## [push]
```ini
autoSetupRemote = true
```
`git push` on a new branch auto-sets the upstream - no more `--set-upstream origin <branch>`.

---

## [credential]
```ini
helper =
helper = !gh auth git-credential
```
- The blank line **clears** any inherited credential helper.
- Delegates auth to the **GitHub CLI** (`gh`) - no password prompts, uses your `gh auth login` session.
- Applied separately for `github.com` and `gist.github.com`.

> **Note:** The path `/home/pookie/.local/bin/gh` is hardcoded. If you reinstall `gh` or change your system username, update this - or simplify to `!gh auth git-credential` if `gh` is in your `$PATH`.

---

## [pull]
```ini
rebase = true
```
`git pull` rebases instead of merging - keeps history linear, no noisy merge commits.

---

## Bitbucket SSH Setup

If you use Bitbucket for work, skip HTTPS and use SSH instead.

**1. Generate an SSH key**
```bash
ssh-keygen -t ed25519 -C "your.work.email@company.com"
```

**2. Add it to the agent**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**3. Add the public key to Bitbucket**
```bash
cat ~/.ssh/id_ed25519.pub
```
Paste the output into **Bitbucket  Account Settings  SSH Keys**.

**4. Always clone via SSH**
```bash
# ? correct
git clone git@bitbucket.org:org/repo.git

# ? avoid - no credential helper configured for Bitbucket
git clone https://bitbucket.org/org/repo.git
```
