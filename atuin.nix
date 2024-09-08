{
  pkgs,
  lib,
  system,
  inputs,
  ...
}: let
  atuinToFcBin = "${inputs.atuinToFc.packages.${system}.default}/bin/atuin-to-fc";
  atuinBin = "${pkgs.atuin}/bin/atuin";
in ''
  atuin-setup() {
      if ! which ${atuinBin} &> /dev/null; then return 1; fi

      export ATUIN_NOBIND="true"
      eval "$(${atuinBin} init "$CUR_SHELL")"
      fzf-atuin-history-widget() {
        local selected num history_list
        setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
        history_list=$(${atuinBin} history list --print0 --cmd-only | ${atuinToFcBin} -r)
        selected=( $(echo "$history_list" | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
          FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} ''${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${"$"}{FZF_CTRL_R_OPTS-} --query=${"$"}{(qqq)LBUFFER} +m" $(__fzfcmd)) )
        cmd=$(echo $selected | cut -f2- -d' ')
        local ret=$?
        LBUFFER="$cmd"
         zle reset-prompt
        return $ret
      }
      zle -N fzf-atuin-history-widget
      bindkey '^R' fzf-atuin-history-widget
  }
  atuin-setup
''
