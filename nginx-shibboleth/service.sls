{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}

nginx_shibboleth_service_running:
  service.running:
    - name: {{ nginx_shibboleth.service }}
    - enable: True
    - restart: True

supervisor_service_running:
  service.running:
    - name: {{ nginx_shibboleth.supervisor.service }}
    - enable: True
