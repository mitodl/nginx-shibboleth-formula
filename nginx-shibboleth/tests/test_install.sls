{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}

{% for pkg in nginx_shibboleth.pkgs %}
test_{{pkg}}_is_installed:
  testinfra.package:
    - name: {{ pkg }}
    - is_installed: True
{% endfor %}

test_shibd_is_running:
  testinfra.service:
    - name: shibd
    - is_running: True
    - is_enabled: True

test_nginx_is_running:
  testinfra.service:
    - name: nginx
    - is_running: True
    - is_enabled: True
