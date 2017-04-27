{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}

include:
  - .service

nginx-shibboleth:
  pkg.installed:
    - pkgs: {{ nginx_shibboleth.pkgs }}
    - require_in:
        - service: nginx-shibboleth_service_running
