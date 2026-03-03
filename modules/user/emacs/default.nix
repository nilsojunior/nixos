{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.userSettings.emacs;
in
{
    options = {
        userSettings.emacs.enable = lib.mkEnableOption "Enables Emacs";
    };

    config = lib.mkIf cfg.enable {
        # stylix.targets.emacs.enable = false;
        programs.emacs = {
            enable = true;
            package = pkgs.emacs-pgtk;
            extraPackages =
                epkgs: with epkgs; [
                    evil
                    evil-collection
                    evil-commentary
                    org
                    org-modern
                    general
                    undo-fu
                    undo-fu-session
                    magit
                    vterm
                    envrc
                    evil-mc
                    pdf-tools

                    diredfl
                    xterm-color

                    consult
                    corfu
                    cape

                    # Modes
                    rust-mode
                    nix-mode
                    nix-ts-mode
                    just-mode
                    just-ts-mode
                    lua-mode
                    markdown-mode
                    markdown-ts-mode
                    typst-ts-mode
                    qml-mode
                    (treesit-grammars.with-grammars (
                        grammars: with grammars; [
                            tree-sitter-rust
                            tree-sitter-nix
                            tree-sitter-just
                            tree-sitter-lua
                            tree-sitter-markdown
                            tree-sitter-typst
                        ]
                    ))
                ];
            extraConfig = ''
                    (org-babel-load-file
                        (expand-file-name
                        "config.org"
                        user-emacs-directory))
                '';
        };

        # home.file.".emacs.d/config.org".source = ./config.org;
    };
}
