{
  lib,
  system,
  inputs,
  ...
}: let
  stBin = "${inputs.st.packages.${system}.default}/bin/st";
in ''
  export TERM_PROGRAM="${stBin}"
  alias bigterm="$TERM_PROGRAM -f \"xos4 Terminus:style=Regular:size=18\""
  alias term="$TERM_PROGRAM"
  alias smallterm="$TERM_PROGRAM -f \"xos4 Terminus:style=Regular:size=12\""
''
