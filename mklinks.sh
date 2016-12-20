#!/bin/sh
if [ "$HOME" != "$(pwd)" ]; then
echo Run the script from your home directory.
exit 1
fi
dir=${XDG_CONFIG_HOME:-~/.config}
ln -sf $dir/emacs/elisp '.emacs.d/elisp'
ln -sf $dir/emacs/init.el '.emacs.d/init.el'
ln -sf $dir/bash/'bashrc' '.bashrc'
ln -sf $dir/zsh/'zshenv' '.zshenv'
ln -sf $dir/zsh/'zshrc' '.zshrc'
ln -sf $dir/zsh/'zprofile' '.zprofile'
ln -sf $dir/x11/'Xdefaults' '.Xdefaults'
ln -sf $dir/x11/'xsession' '.xsession'
ln -sf $dir/xmobar/'xmobar' '.xmobarrc'
ln -sf $dir/xmonad/'xmonad.hs' '.xmonad/xmonad.hs'
ln -sf $dir/abcde/'abcde.conf' '.abcde.conf'
ln -sf $dir/tinyfugue/'tfaardwolf' '.tfaardwolf'
ln -sf $dir/tinyfugue/'tfcybersphere' '.tfcybersphere'
ln -sf $dir/tinyfugue/'tfdiscworld' '.tfdiscworld'
ln -sf $dir/tinyfugue/'tfgodwars2' '.tfgodwars2'
ln -sf $dir/tinyfugue/'tfhellmoo' '.tfhellmoo'
ln -sf $dir/tinyfugue/'tflegendsofthejedi' '.tflegendsofthejedi'
ln -sf $dir/tinyfugue/'tfrc' '.tfrc'
ln -sf $dir/tinyfugue/'tfshadowsofisildur' '.tfshadowsofisildur'
ln -sf $dir/beirc/'beirc.lisp' '.beirc.lisp'
ln -sf $dir/mercurial/'hgrc' '.hgrc'
ln -sf $dir/lisp/'init.lisp' '.init.lisp'
ln -sf $dir/sbcl/'sbclrc' '.sbclrc'
ln -sf $dir/clisp/'clisprc' '.clisprc'
ln -sf $dir/cmucl/'cmucl-init' '.cmucl-init'
ln -sf $dir/bash/'bash_logout' '.bash_logout'
ln -sf $dir/git/'gitconfig' '.gitconfig'
ln -sf $dir/mksh/'mkshrc' '.mkshrc'
ln -sf $dir/mksh/'profile' '.profile'
ln -sf $dir/xbindkeys/'xbindkeysrc' '.xbindkeysrc'
ln -sf '/home/athas/.config/tmux/.tmux.conf/tmux.conf' '.tmux.conf'
ln -sf '/home/athas/.config/bash/bash_profile' '.bash_profile'
ln -s '/home/athas/.config/readline/inputrc' '.inputrc'
