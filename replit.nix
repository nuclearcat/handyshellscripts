{ pkgs }: {
    deps = [
        pkgs.haskellPackages.ShellCheck
        pkgs.sudo
        pkgs.bashInteractive
        pkgs.man
    ];
}