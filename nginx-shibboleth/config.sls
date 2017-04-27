{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}

include:
  - .install
  - .service

nginx-shibboleth-config:
  file.managed:
    - name: {{ nginx_shibboleth.conf_file }}
    - source: salt://nginx-shibboleth/templates/conf.jinja
    - template: jinja
    - watch_in:
      - service: nginx-shibboleth_service_running
    - require:
      - pkg: nginx-shibboleth
