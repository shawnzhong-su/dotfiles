# 💻 macOS Dotfiles

> A personalized, robust, and aesthetically pleasing macOS configuration managed by **GNU Stow**.

Welcome to my personal macOS dotfiles repository! This project centralizes all my essential configurations, terminal setups, developer tools, and editor profiles, making it easy to replicate a productive and elegant environment across different macOS machines.

---

## 🚀 Core Components

This repository is modularly organized. Below are the core components tailored for performance and usability:

### 📟 Terminal & Shell

- **[Kitty](kitty/)**: A fast, feature-rich, GPU-based terminal emulator configured with a sleek dark theme.
- **[Zsh](zsh/)**: The default shell, supercharged by `p10k` (Powerlevel10k) for a blazing-fast and informative prompt.
- **[Fish](fish/)**: An alternative modern shell, pre-configured with `uv` environment variable integrations for Python development.

### 📝 Editor

- **[Neovim](nvim/)**: A deeply customized, minimalist monochrome (black & white) Neovim configuration built for high performance and optimized for Python and Lua development. _(See the [detailed Neovim README](nvim/.config/nvim/README.md) for more info)._

### 🛠️ Development Tools

- **[Git & LazyGit](git/) / [lazygit](lazygit/)**: Comprehensive Git configurations and seamless integration with `lazygit` for intuitive and visual version control from the terminal.

### 📦 Package & Environment Management

- **Homebrew**: All macOS packages, casks, and Mac App Store apps are tracked cleanly using a `Brewfile`.
  - **`brew-sync.sh`**: A custom automation script that synchronizes package lists and injects descriptions and notes from `Brewfile.notes` directly into the `Brewfile`.
- **[uv](uv/)**: An ultra-fast Python package and project manager written in Rust.

### ⚙️ System Utilities

- **[Hammerspoon](hammerspoon/)**: Powerful macOS automation scripts (window management, shortcuts, etc.) written in Lua.
- **[Clash](clash/)**: Network proxy configurations.

---

## 🛠️ Installation & Deployment

I use **[GNU Stow](https://www.gnu.org/software/stow/)** to manage dotfiles. Stow elegantly creates symlinks from the `dotfiles` directory to your home directory, keeping the configuration tracked in Git while cleanly deployed in the system.

### 1. Prerequisites

Ensure you have the following installed on a fresh macOS system:

- **[Homebrew](https://brew.sh/)**
- **Git**
- **GNU Stow** (`brew install stow`)

### 2. Clone the Repository

Clone this repository to the root of your home directory:

```bash
git clone https://github.com/shawnzhong-su/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Deploy Configurations with Stow

Stow automatically handles symlinking based on the folder structure. To install a specific configuration (e.g., Neovim and Zsh), run:

```bash
# Example: Deploy Neovim and Zsh configs
stow nvim
stow zsh

# Or loop through multiple directories:
for app in kitty nvim zsh git lazygit; do
    stow $app
done
```

> **Note**: The `.stow-local-ignore` file ensures that files like `.git`, `README.md`, and backups (`*.bak`) are ignored during the symlinking process.

### 4. Restore Packages & Apps

To restore all tools, applications, and casks via Homebrew:

```bash
brew bundle --file=~/dotfiles/Brewfile
```

---

## 🔄 Package Management (`brew-sync.sh`)

Maintaining a clean `Brewfile` can be difficult when installing things ad-hoc. I've built a custom workflow to manage this:

1. **`Brewfile.notes`**: Acts as a detailed registry mapping installed packages to my personal notes and the official descriptions.
2. **`brew-sync.sh`**: Running this script will:
   - Dump the current system state (`brew bundle dump`, outputting to `Brewfile`).
   - Automatically migrate any old-format notes.
   - Inject the localized notes and descriptions from `Brewfile.notes` into the generated `Brewfile` as clean comments.

Run this periodically to keep the repository's `Brewfile` updated with your live system state:

```bash
cd ~/dotfiles
./brew-sync.sh
```

---

## 📂 Directory Structure

Here is a quick overview of how the repository is structured:

```text
~/dotfiles
├── brew-sync.sh       # Script to synchronize Brewfile with notes
├── Brewfile           # Generated list of Homebrew packages
├── Brewfile.notes     # Custom descriptions and notes for Brew packages
├── clash/             # Proxy configuration (.config/clash)
├── fish/              # Fish shell config and scripts (.config/fish)
├── git/               # Git configuration (.gitconfig)
├── hammerspoon/       # macOS automation scripts (.hammerspoon)
├── kitty/             # Terminal emulator configuration (.config/kitty)
├── lazygit/           # Git UI tool configuration (.config/lazygit)
├── nvim/              # Neovim configuration (.config/nvim)
├── uv/                # Python package manager config (.config/uv)
└── zsh/               # Zsh & p10k configuration (.zshrc, .p10k.zsh)
```

---

## 📜 License

MIT
