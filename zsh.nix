{
  pkgs,
  lib,
  inputs,
  system,
  extraConfig ? "",
  zsh-notify,
  zcomet,
  ...
}:
let
  tmuxinatorBin = "${pkgs.tmuxinator}/bin/tmuxinator";
  chatbladeBin = "${pkgs.chatblade}/bin/chatblade";
  powerlineConfigBin = "${pkgs.powerline}/bin/powerline-config";
  autoSuggestions = pkgs.zsh-autosuggestions;
  bins = lib.strings.makeBinPath [
    pkgs.fzf
    pkgs.git
    pkgs.ripgrep
    pkgs.eza
    pkgs.z-lua
    pkgs.atuin
    pkgs.direnv
    pkgs.fd
    pkgs.bat
    pkgs.ranger
    pkgs.wmctrl
    pkgs.xdotool
    pkgs.buku
    pkgs.sox
  ];
in
pkgs.writeTextDir ".zshrc" ''
  include () {
      [[ -f "$1" ]] && source "$1"
  }
  export DISABLE_AUTO_UPDATE="true"
  export DISABLE_MAGIC_FUNCTIONS="true"
  export DISABLE_COMPFIX="true"
  export PATH=$PATH:${bins}
  export VISUAL=$EDITOR
  export CUR_SHELL=zsh
  export TERM=xterm-256color
  export KEYTIMEOUT=1
  export CDPATH=.:~:~/workspace:~/workspace/personal
  export CUR_SHELL=zsh
  export DISABLE_AUTO_UPDATE="true"
  export DISABLE_COMPFIX="true"
  export DISABLE_MAGIC_FUNCTIONS="true"
  export DISABLE_UNTRACKED_FILES_DIRTY="true"
  export DISABLE_UPDATE_PROMPT="true"
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden -g\!.git'
  export FZF_DEFAULT_OPTS="--bind 'ctrl-l:jump'"
  export GIT_PAGER="bat --paging=always --theme='Monokai Extended'"
  export HISTFILE=$HOME/.zsh_history
  export HISTFILESIZE=1000000000
  export HISTSIZE=1000000000
  export HISTTIMEFORMAT="%d/%m/%y %T "
  export HYPHEN_INSENSITIVE="true"
  export PATH=$PATH:${bins}
  export POWERLINE_CONFIG_COMMAND=${powerlineConfigBin}
  export SAVEHIST=10000000
  export TERM=xterm-256color
  export UPDATE_ZSH_DAYS=1
  export VISUAL=$EDITOR
  export ZDOTDIR=$HOME
  export ZSH_AUTOSUGGEST_STRATEGY=(history)
  export ZSH_AUTOSUGGEST_USE_ASYNC=1
  export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"
  export _JAVA_AWT_WM_NONREPARENTING=1
  export FZF_CTRL_T_COMMAND="command fd -H -L . --min-depth 1 --exclude "/sys" --exclude "/dev" --exclude "/tmp" --exclude "/proc" -c never"
  export VIM_MODE_NO_DEFAULT_BINDINGS=true

  setopt INC_APPEND_HISTORY
  setopt autocd
  setopt PROMPT_SUBST


  alias mux="${tmuxinatorBin}"
  alias gco='git checkout'
  alias fixup="git commit -C HEAD --amend -a"
  alias dirinit="nix flake new -t github:nix-community/nix-direnv ."
  alias edit=$EDITOR
  alias nvim=$EDITOR
  alias vim=$EDITOR
  alias zshconfig="$EDITOR ~/.zshrc"
  alias make_certs="openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt"
  alias ai="chatblade -c 4"
  alias killjobs="kill -9 \$(jobs -l | rg} -oP \"\\d+ (running)\"|cut -f1 -d\" \") 2>/dev/null || echo 'No jobs running'"
  alias cim="$EDITOR \`git diff --name-only\`"
  alias CAPS="xdotool key Caps_Lock"
  alias work="task project:work"
  alias noise="play -n synth brownnoise gain -25"
  alias nixsudo="sudo env \"PATH=$PATH\""
  alias ls="eza"

  autoload -Uz vcs_info
  precmd() { vcs_info }
  zstyle ':vcs_info:git:*' formats '%b' # To display the branch name

  include ${./theme.zsh-theme}
  include ~/.local.zshrc
  include ${autoSuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  include ${zcomet}/zcomet.zsh

  zcomet load ohmyzsh plugins/fzf
  zcomet load ohmyzsh plugins/z
  zcomet load ohmyzsh plugins/gitfast
  zcomet load marzocchi/zsh-notify notify.plugin.zsh

  bindkey -e

  updir() {
      cd ../
      zle reset-prompt
  }


  zle -N updir{,}
  bindkey '' updir


  show_dir() {
      echo ""
      eza --color=always
      zle reset-prompt
  }

  zle -N show_dir{,}
  bindkey '' show_dir

  zle -N _expand_alias{,}
  bindkey '' _expand_alias

  jmp () {
      cd "$(zshz|rg -o "/.*"|fzf || pwd)"
  }

  jump_dir() {
      jmp
      zle reset-prompt
  }

  zle -N jump_dir{,}
  bindkey '' jump_dir

  autoload -U edit-command-line
  zle -N edit-command-line
  bindkey '^g' edit-command-line

  autoload -Uz compinit
  for dump in ~/.zcompdump(N.mh+24); do
      compinit
  done
  compinit -C

  eval "$(direnv hook zsh)"

  chatblade () {
      (
          source ~/.config/chatblade/creds
          ${chatbladeBin} $@
      )
  }

  bindkey '' autosuggest-accept
  bindkey '' up-line-or-history
  bindkey '' down-line-or-history

  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  ${extraConfig}
''
