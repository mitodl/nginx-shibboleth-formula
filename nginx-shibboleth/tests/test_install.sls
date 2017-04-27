{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}

{% for pkg in nginx_shibboleth.pkgs %}
test_{{pkg}}_is_installed:
  testinfra.package:
    - name: {{ pkg }}
    - is_installed: True
{% endfor %}
