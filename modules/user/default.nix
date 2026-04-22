{ pkgs, lib, config, ... }:

{
    imports = [
        ./zsh
        ./hyprland
        ./browser
        ./editor
        ./terminal
        ./keepass
        ./git
        ./emacs
        ./stylix
        ./spotify
        ./ssh
        ./vicinae
        ./laptop
    ];

    home.file.".config/nvim".source = ./nvim;

    home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
    };

    home.packages = with pkgs; [
        # Applications
        neovim
        pavucontrol

        # Tools
        unzip
        ffmpeg
        dysk
        ripgrep
        eza
        fd
        bat
        fzf
        tealdeer
        imagemagick
        pandoc
    ];
}
