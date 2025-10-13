#!/usr/bin/env bash
# ============================================================================
# Ubuntu 24.04 – PRO DEV SETUP (AI/SaaS + Next.js + Supabase + Tauri 2 + Flutter)
# Maintainer: Hybirdss  |  Email: oinkm@naver.com
# Safe to run multiple times (idempotent-ish)
# ============================================================================
set -euo pipefail

log() { printf "\n\033[1;36m[SETUP]\033[0m %s\n" "$*"; }

GIT_NAME=${GIT_NAME:-"<Your_Name>"}
GIT_EMAIL=${GIT_EMAIL:-"<Your_Email>"}
INSTALL_FLUTTER=${INSTALL_FLUTTER:-"1"}      # set 0 to skip
CREATE_STARTERS=${CREATE_STARTERS:-"0"}      # set 1 to scaffold example apps

log "System update"
sudo apt update -y && sudo apt upgrade -y

log "Essentials"
sudo apt install -y build-essential curl wget git unzip zip ca-certificates gnupg lsb-release software-properties-common pkg-config libssl-dev openssh-client

log "Quality-of-life CLI tools"
sudo apt install -y ripgrep fzf tmux tree htop jq file gcc g++ make cmake ninja-build
# modern ls/cat (aliases appended later)
sudo apt install -y bat exa || true   # Ubuntu names: batcat/exa (bat provides batcat)

log "Zsh + Oh-My-Zsh + plugins + Starship"
sudo apt install -y zsh fonts-powerline
if [ "$(basename \"$SHELL\")" != "zsh" ]; then chsh -s "$(which zsh)" "$USER" || true; fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
# plugins
mkdir -p ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins
[ -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ] || git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# starship prompt
curl -fsSL https://starship.rs/install.sh | bash -s -- -y

# append zsh config safely
if ! grep -q "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" "$HOME/.zshrc" 2>/dev/null; then
  {
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo 'alias ll="exa -alh --git"'
    echo 'alias cat="batcat"'
    echo 'eval "$(starship init zsh)"'
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'
  } >> "$HOME/.zshrc"
fi

log "asdf (runtime manager)"
if [ ! -d "$HOME/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  {
    echo '. "$HOME/.asdf/asdf.sh"'
    echo '. "$HOME/.asdf/completions/asdf.bash"'
  } >> "$HOME/.zshrc"
fi
. "$HOME/.asdf/asdf.sh"

log "Install runtimes via asdf: Node.js, Python, Rust, Bun (optional)"
# Node.js
asdf plugin list | grep -q nodejs || asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest
# Python (for tooling + runpodctl, etc.)
asdf plugin list | grep -q python || asdf plugin add python https://github.com/danhper/asdf-python.git
asdf install python latest
asdf global python latest
# Rust (Tauri)
asdf plugin list | grep -q rust || asdf plugin add rust https://github.com/asdf-community/asdf-rust.git
asdf install rust stable
asdf global rust stable
# Bun (optional; many tools like biome use it)
asdf plugin list | grep -q bun || asdf plugin add bun https://github.com/cometkim/asdf-bun.git || true
asdf install bun latest || true
asdf global bun latest || true

log "Global Node tooling (pnpm, yarn, turbo, vercel, supabase, eslint_d)"
corepack enable || true
npm i -g pnpm yarn turbo vercel supabase eslint_d typescript ts-node npm-check-updates
pnpm setup || true

log "Git config & SSH"
[ -n "$GIT_NAME" ] && git config --global user.name "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
fi
printf "\n\033[1;33mAdd this SSH public key to GitHub:\033[0m\n"
cat "$HOME/.ssh/id_ed25519.pub" || true

log "GitHub CLI, Git LFS, direnv, zoxide"
sudo apt install -y gh git-lfs direnv
# zoxide modern cd
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- -y
if ! grep -q 'eval "$(zoxide init zsh)"' "$HOME/.zshrc"; then echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"; fi

git lfs install --system || true

log "Docker Engine + compose plugin"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker "$USER" || true

log "Database & tooling: PostgreSQL client, Redis, SQLite"
sudo apt install -y postgresql-client redis-server sqlite3 libsqlite3-dev

log "Supabase CLI (global via npm already installed)"
supabase --version || true

log "Tauri 2 – Linux dependencies"
sudo apt install -y libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev patchelf
# webkit2gtk-4.1 is required on Ubuntu 24.04 for modern Tauri webview
sudo apt install -y libwebkit2gtk-4.1-dev

log "Rust targets for Tauri (x86_64)"
rustup target add x86_64-unknown-linux-gnu || true

log "Flutter SDK (optional)"
if [ "$INSTALL_FLUTTER" = "1" ]; then
  if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> "$HOME/.zshrc"
  fi
  "$HOME/flutter/bin/flutter" doctor || true
fi

log "VSCode + Extensions"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg >/dev/null
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update -y && sudo apt install -y code

# Core extensions
code --install-extension esbenp.prettier-vscode \
  ms-python.python ms-toolsai.jupyter \
  ms-azuretools.vscode-docker \
  ms-vscode.vscode-typescript-next \
  eamodio.gitlens bradlc.vscode-tailwindcss \
  rust-lang.rust-analyzer \
  tauri-apps.tauri-vscode \
  prisma.prisma \
  svelte.svelte-vscode \
  dbaeumer.vscode-eslint \
  github.copilot github.copilot-chat || true

log "Node project QoL: enable corepack pnpm in zshrc if missing"
if ! grep -q 'corepack enable' "$HOME/.zshrc"; then echo 'eval "$(corepack enable)"' >> "$HOME/.zshrc"; fi || true

log "RunPod CLI (optional) – install via pip if you use it"
python -m pip install --upgrade pip || true
# Uncomment if you actively use RunPod CLI
# python -m pip install runpodctl
# echo 'alias runpodctl="python -m runpodctl"' >> "$HOME/.zshrc"

log "Create dev folders"
mkdir -p "$HOME/Dev" "$HOME/Dev/_starters"

if [ "$CREATE_STARTERS" = "1" ]; then
  log "Scaffold: Next.js 15 + pnpm + Tailwind + tRPC (Shifly-style)"
  pushd "$HOME/Dev/_starters" >/dev/null
  # requires Node >= 18; using pnpm
  pnpm dlx create-next-app@latest next15-trpc --ts --eslint --tailwind --app --src-dir --import-alias "@/*" --no-experimental-app-router || true
  pushd next15-trpc >/dev/null
  pnpm i -D @tanstack/react-query @trpc/server @trpc/client @trpc/react-query @trpc/next zod superjson @supabase/supabase-js
  popd >/dev/null

  log "Scaffold: Tauri 2 + Vite + React (Labbit-style)"
  pnpm dlx create-tauri-app@latest tauri2-vite-react --template vite-react-ts || true
  popd >/dev/null
fi

log "Final notes"
echo "- Restart terminal or: source ~/.zshrc"
echo "- Add SSH key above to GitHub: https://github.com/settings/keys"
echo "- Docker group may need a logout/login to take effect"
echo "- Optional CUDA/driver install is intentionally skipped (GPU servers differ)."

echo "✅ DONE. Happy building, ${GIT_NAME}!"
