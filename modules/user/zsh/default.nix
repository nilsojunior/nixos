{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.userSettings.zsh;
in
{
    options = {
        userSettings.zsh.enable = lib.mkEnableOption "Enables Zsh";
    };

    config = lib.mkIf cfg.enable {
        programs.zsh = {
            enable = true;
            profileExtra = /* bash */ ''
                if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
                    exec start-hyprland
                fi
            '';

            initContent = /* bash */ ''
                # Vterm
                vterm_printf() {
                    if [ -n "$TMUX" ] \
                        && { [ "$${TERM%%-*}" = "tmux" ] \
                            || [ "$${TERM%%-*}" = "screen" ]; }; then
                        # Tell tmux to pass the escape sequences through
                        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
                    elif [ "$${TERM%%-*}" = "screen" ]; then
                        # GNU screen (screen, screen-256color, screen-256color-bce)
                        printf "\eP\e]%s\007\e\\" "$1"
                    else
                        printf "\e]%s\e\\" "$1"
                    fi
                }

                vterm_prompt_end() {
                    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
                }
                setopt PROMPT_SUBST
                PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

                # NOTE: Vim mode
                bindkey -v
                KEYTIMEOUT=1
            '';

            # NOTE: Using this instead of .zshrc so emacs can see the aliases
            envExtra = ''
                alias launch="hyprctl dispatch exec"
                alias grep="grep --color=always"
                alias cp="cp --interactive"
                alias mv="mv --interactive"
                alias mkdir="mkdir --parents"
                alias v="nvim"
                alias cat="bat"
                alias ..="cd .."
            '';
        };
    };
}
