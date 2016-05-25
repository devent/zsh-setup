#!/bin/bash
cat <<EOT
# Path to your oh-my-zsh installation.
export ZSH=$OHMYZSH
ZSH_THEME="$THEME"
plugins=($PLUGINS)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
source \$ZSH/oh-my-zsh.sh

# You may need to manually set your language environment

# Preferred editor for local and remote sessions
if [[ -n \$SSH_CONNECTION ]]; then
    # remote
    export EDITOR="$REMOTE_EDITOR"
else
    export EDITOR="$LOCAL_EDITOR"
fi

if [ -f "$AUTOJUMP" ]; then
    . $AUTOJUMP
fi

if [ -f "$PROXY" ]; then
    . $PROXY
fi

if [ -f "$USER_RC" ]; then
    . $USER_RC
fi

if [ -f "$USER_ZSHRC" ]; then
    . $USER_ZSHRC
fi
EOT
