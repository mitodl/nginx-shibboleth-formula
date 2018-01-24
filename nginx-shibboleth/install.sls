{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}

include:
  - nginx.ng
  - .service

{% if salt.grains.get('os_family') == 'RedHat' %}
add_shibboleth_yum_repo:
  pkgrepo.managed:
    - name: security_shibboleth
    - humanname: Shibboleth (CentOS_7)
    - type: rpm-md
    - baseurl: http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/
    - gpgcheck: True
    - gpgkey: http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/repodata/repomd.xml.key
    - enabled: True
    - require_in:
        - pkg: install_service_provider
{% endif %}

install_service_provider:
  pkg.installed:
    - pkgs: {{ nginx_shibboleth.pkgs }}
    - require_in:
        - service: nginx_shibboleth_service_running
        - cmd: nginx_configure

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
