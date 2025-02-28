# Dotfiles

Configuration files for various Unix programs I use daily. This repo helps synchronize my development environment across different machines.

## What's Included

- `.vimrc` - Vim configuration with my preferred settings
- `.config/helix/config.toml` - Configuration for the Helix editor

## Requirements

- Bash 3.2+
- AWK (for TOML parsing)
- Standard Unix utilities
- Vim, Helix (depending on which configs you use)
- Any Unix-based system (Linux, macOS)

## Deployment

### Quick Setup

Clone the repo and run the deployment script:

```bash
git clone https://your-repo-url/dotfiles.git
cd dotfiles
chmod +x deploy_dotfiles.sh
./deploy_dotfiles.sh manifest_dotfiles.toml
```

### Remote Deployment

To deploy to a remote server:

```bash
# Copy files and deploy
scp -r ./dotfiles user@remote-server:~/
ssh user@remote-server "cd ~/dotfiles && chmod +x deploy_dotfiles.sh && ./deploy_dotfiles.sh manifest_dotfiles.toml"

# Alternatively, clone directly on the server
ssh user@remote-server "git clone https://your-repo-url/dotfiles.git ~/dotfiles && \
  cd ~/dotfiles && chmod +x deploy_dotfiles.sh && ./deploy_dotfiles.sh manifest_dotfiles.toml"
```

### Customization

The `manifest_dotfiles.toml` file specifies which files to deploy and where:

```toml
[".your_dotfile"]
operation = "symlink"
destination = "relative/path/from/home"  # Leave empty for $HOME
```

Create different manifests for different environments (e.g., `manifest_basic.toml` for servers).

### Troubleshooting

If a file already exists at the destination, the script will exit with an error. You'll need to manually remove or rename the existing file before running the script again.
