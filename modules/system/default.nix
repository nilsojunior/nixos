{
    config,
    pkgs,
    lib,
    ...
}:

{
    imports = [
        ./hyprland
        ./nvidia
        ./sshd
        ./gpg
        ./stylix
        ./pipewire
        ./userinfo
        ./kanata
    ];

    home-manager.users.${config.systemSettings.user}.imports = [
        ../../hosts/${config.networking.hostName}/home.nix
    ];

    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    programs.direnv.enable = true;

    time.timeZone = "Brazil/East";

    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
            timeout = 0; # Acess by pressing space
        };
        kernelParams = [ "quiet" ];
    };

    services = {
        # Journal (logs)
        # Limit size and things to optimize boot speed
        journald = {
            extraConfig = "SystemMaxUse=50M\nSystemMaxFiles=5";
            rateLimitBurst = 500;
            rateLimitInterval = "30s";
        };

        getty.autologinUser = config.systemSettings.user;

        tailscale.enable = true;
    };

    security.rtkit.enable = true;

    networking.networkmanager.enable = true;
    # Don't wait for internet connection to start
    systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];

    nix.settings.experimental-features = [
        "nix-command"
        "flakes"
    ];

    environment.systemPackages = with pkgs; [
        wget
        just
        sshfs
        man-pages
    ];

    # https://github.com/thiagokokada/nix-configs/blob/a00e8aa50e6e5786e1d533389c100aca41800417/modules/nixos/desktop/locale.nix#L12-L14
    i18n = {
        defaultLocale = "en_IE.UTF-8";
        extraLocaleSettings = {
            LC_CTYPE = "pt_BR.UTF-8"; # Fix ç in us-intl.
        };
    };
}
