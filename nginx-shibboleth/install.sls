{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}

include:
  - nginx.ng
  - .service

install_service_provider:
  pkg.installed:
    - pkgs: {{ nginx_shibboleth.pkgs }}
    - require_in:
        - service: nginx_shibboleth_service_running

clone_nginx_shibboleth_plugin:
  git.latest:
    - name: https://github.com/nginx-shib/nginx-http-shibboleth
    - target: /opt/nginx-http-shibboleth

clone_nginx_headers_module:
  git.latest:
    - name: https://github.com/openresty/headers-more-nginx-module
    - target: /opt/headers-more-nginx-module

extend:
  nginx_configure:
    cmd.run:
      - name: >-
          ./configure
          --prefix=/etc/nginx
          --sbin-path=/usr/sbin/nginx
          --conf-path=/etc/nginx/nginx.conf
          --with-pcre
          --with-http_ssl_module
          --with-http_stub_status_module
          --with-http_geoip_module
          --with-http_auth_request_module
          --with-http_gzip_static_module
          --with-http_v2_module
          --with-http_realip_module
          --with-http_sub_module
          --add-module=/opt/headers-more-nginx-module
          --add-module=/opt/nginx-http-shibboleth
      - require:
          - git: clone_nginx_headers_module
          - git: clone_nginx_shibboleth_plugin
      - require_in:
          - file: copy_shibboleth_includes_to_nginx_path

copy_shibboleth_includes_to_nginx_path:
  file.copy:
    - name: /etc/nginx/includes
    - source: /opt/nginx-http-shibboleth/includes
    - require:
        - git: clone_nginx_shibboleth_plugin
