pkgs:
with pkgs;
let
    nginxPort = "80";
    nginxConf = pkgs.writeText "nginx.conf" ''
    user nobody nobody;
    daemon off;
    error_log /dev/stdout info;
    pid /dev/null;
    events {}

    http {
        access_log /dev/stdout;
        server {
            listen ${nginxPort};
            index index.html;
            location / {
            root ${nginxWebRoot};
            }
        }
    }'';

    nginxWebRoot = pkgs.writeTextDir "index.html" ''
        <html><body><h1>Hello from NGINX</h1></body></html>
    '';
in
    dockerTools.buildLayeredImage {
    name = "nix-nginx";
    tag = "latest";
    contents = [
        dockerTools.fakeNss
        pkgs.nginx
    ];

    extraCommands = ''
        # nginx still tries to read this directory even if error_log
        # directive is specifying another file :/
        mkdir -p var/log/nginx
        mkdir -p var/cache/nginx
    '';

    config = {
        Cmd = [ "nginx" "-c" nginxConf ];
        ExposedPorts = {
        "${nginxPort}/tcp" = {};
        };
    };
}