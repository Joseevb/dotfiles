
# fnm
set FNM_PATH "/home/jose/.local/share/fnm"
if [ -d "$FNM_PATH" ]
  set PATH "$FNM_PATH" $PATH
  fnm env --shell fish | source
end

fnm env --use-on-cd --shell fish | source
