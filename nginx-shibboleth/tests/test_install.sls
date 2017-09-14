{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}

{% for pkg in nginx_shibboleth.pkgs %}
test_{{pkg}}_is_installed:
  testinfra.package:
    - name: {{ pkg }}
    - is_installed: True
{% endfor %}

{% for service in ['shibd', 'nginx', 'supervisor'] %}
test_{{ service }}_is_running:
  testinfra.service:
    - name: {{ service }}
    - is_running: True
    - is_enabled: True
{% endfor %}
