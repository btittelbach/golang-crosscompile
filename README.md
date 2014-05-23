See http://dave.cheney.net/2012/09/08/an-introduction-to-cross-compilation-with-go

## use with zsh ##

### Installation ###
add the following to your ```~/.zshenv```

1. add go/bin and go-pkgs/bin to your path e.g:. ```path+=(~/go/bin ~/go-pkgs/bin)```
2. optinally add ```export GOPATH=~/go-pkgs```
3. source ```crosscompile.zsh``` e.g.:
```  [[ -e ~/golang-crosscompile/crosscompile.zsh ]] && . ~/golang-crosscompile/crosscompile.zsh ```

### Use ###

once you run i.e. ```go-crosscompile-build linux/386``` a shell function ```go-linux-386``` will become available
which you can use instead of ```go```. The same works for linux/amd64, darwin/386, linux/arm, etc...

you may also ```go-crosscompile-build-all```
