nginx-shibboleth_service_running:
  service:
    - running
    - name: {{ nginx_shibboleth.service }}
    - enable: True
