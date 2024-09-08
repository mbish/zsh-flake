{
  pkgs,
  lib,
  inputs,
  vim,
  browser,
  system,
  extraConfig ? "",
  ...
}: let
  mimBin = "${vim}/bin/vim";
  vimBin = "${vim}/bin/vim";
  ripgrepBin = "${pkgs.ripgrep}/bin/rg";
  batBin = "${pkgs.bat}/bin/bat";
  fdBin = "${pkgs.fd}/bin/fd";
  tmuxinatorBin = "${pkgs.tmuxinator}/bin/tmuxinator";
  gitBin = "${pkgs.git}/bin/git";
  nixBin = "${pkgs.nix}/bin/nix";
  grepBin = "${pkgs.coreutils}/bin/grep";
  ezaBin = "${pkgs.eza}/bin/eza";
  direnvBin = "${pkgs.direnv}/bin/direnv";
  chatbladeBin = "${pkgs.chatblade}/bin/chatblade";
  fzfBin = "${pkgs.fzf}/bin/fzf";
  zBin = "${pkgs.z-lua}/bin/z";
  browserBin = browser;
  powerlineConfigBin = "${pkgs.powerline}/bin/powerline-config";
  oh-my-zsh-source = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
  autoSuggestions = pkgs.zsh-autosuggestions;
in
  with lib;
    pkgs.writeTextDir ".zshrc"
    ''
      include () {
          [[ -f "$1" ]] && source "$1"
      }

      export GIT=${gitBin}
      export ZSH="${oh-my-zsh-source}"
      export EDITOR=${vimBin}
      export VISUAL=${mimBin}
      export BROWSER=${browserBin}
      export PATH=$PATH:${pkgs.fzf}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.eza}/bin:${pkgs.z-lua}/bin:${pkgs.atuin}/bin
      export CUR_SHELL=zsh
      export TERM=xterm-256color
      export CDPATH=.:~:~/workspace:~/workspace/personal:~/workspace/duo
      export HISTTIMEFORMAT="%d/%m/%y %T "
      export HISTFILE=$HOME/.zsh_history
      export HISTSIZE=1000000000
      export HISTFILESIZE=1000000000
      export SAVEHIST=10000000
      setopt INC_APPEND_HISTORY
      export POWERLINE_CONFIG_COMMAND=${powerlineConfigBin}
      export FZF_DEFAULT_COMMAND='${ripgrepBin} --files --no-ignore-vcs --hidden -g\!.git'
      export FZF_DEFAULT_OPTS="--bind 'ctrl-l:jump'"
      export GIT_PAGER="${batBin} --paging=always --theme='Monokai Extended'"
      export ZSH_AUTOSUGGEST_USE_ASYNC=1
      export ZSH_AUTOSUGGEST_STRATEGY=(history)
      export _JAVA_AWT_WM_NONREPARENTING=1

      alias mux="${tmuxinatorBin}"
      alias gco='$GIT checkout'
      alias fixup="$GIT commit -C HEAD --amend -a"
      alias dirinit="${nixBin} flake new -t github:nix-community/nix-direnv ."
      alias edit=$EDITOR
      alias vim=$EDITOR
      alias nvim=$EDITOR
      alias zshconfig="$EDITOR ~/.zshrc"
      alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
      alias make_certs="openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt"
      alias ai="${chatbladeBin} -c 4"
      alias killjobs="kill -9 \$(jobs -l | ${grepBin} -oP \"\\d+ (running)\"|cut -f1 -d\" \") 2>/dev/null || echo 'No jobs running'"
      alias cim="$EDITOR \`$GIT diff --name-only\`"
      alias ls='${ezaBin}'

      include ${./theme.zsh-theme}
      include ~/.local.zshrc
      HYPHEN_INSENSITIVE="true"
      DISABLE_UPDATE_PROMPT="true"
      export UPDATE_ZSH_DAYS=1
      DISABLE_UNTRACKED_FILES_DIRTY="true"

      plugins=(
          git
          fzf
          z
      )
      include $ZSH/oh-my-zsh.sh
      include ${autoSuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      updir() {
          cd ../
          zle reset-prompt
      }


      zle -N updir{,}
      bindkey '' updir


      show_dir() {
          echo ""
          ${ezaBin} --color=always
          zle reset-prompt
      }

      zle -N show_dir{,}
      bindkey '' show_dir

      zle -N _expand_alias{,}
      bindkey '' _expand_alias

      export KEYTIMEOUT=1

      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^g' edit-command-line
      autoload -U compinit
      compinit

      eval "$(${direnvBin} hook zsh)"

      chatblade () {
          (
              source ~/.config/chatblade/creds
              ${chatbladeBin} $@
          )
      }

      jmp () {
          cd "$(${zBin}|${grepBin} -o "/.*"|${fzfBin} || pwd)"
      }


      export FZF_CTRL_T_COMMAND="command ${fdBin} -H -L . --min-depth 1 --exclude "/sys" --exclude "/dev" --exclude "/tmp" --exclude "/proc" -c never"

      export VIM_MODE_NO_DEFAULT_BINDINGS=true
      bindkey '' autosuggest-accept
      bindkey '' up-line-or-history
      bindkey '' down-line-or-history

      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

      ${extraConfig}
    ''
