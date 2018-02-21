{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}
{% set pillar_config = salt.pillar.get('nginx-shibboleth:config', {}) %}

include:
  - .install
  - .service

{% if salt.pillar.get('nginx-shibboleth:secrets:key')
      and salt.pillar.get('nginx-shibboleth:secrets:cert') %}
{% for secret in ['key', 'cert'] %}
place_shibboleth_sp_{{ secret }}:
  file.managed:
    - name: /etc/shibboleth/sp-{{ secret }}.pem
    - mode: 0600
    - user: {{ nginx_shibboleth.shibboleth.user }}
    - group: {{ nginx_shibboleth.shibboleth.group }}
    - contents_pillar: nginx-shibboleth:secrets:{{ secret }}
    - onchanges_in:
        - service: nginx_shibboleth_service_running
{% endfor %}
{% else %}
generate_shibboleth_sp_cert_and_key:
  cmd.run:
    - name: shib-keygen
    - creates: /etc/shibboleth/sp-cert.pem
{% endif %}

{% for config_name in pillar_config %}
generate_{{ config_name }}_configuration_file:
  file.managed:
    - name: /etc/shibboleth/{{ config_name }}.xml
    - contents_pillar: nginx-shibboleth:config:{{ config_name }}
    - watch_in:
        - service: nginx_shibboleth_service_running
        - supervisord: ensure_shibauthorizer_fcgi_running
        - supervisord: ensure_shibresponder_fcgi_running
{% endfor %}

place_supervisor_fcgi_configuration:
  file.managed:
    - name: {{ nginx_shibboleth.supervisor.config_dir }}/shibboleth_sp_fcgi.conf
    - source: salt://nginx-shibboleth/templates/shibboleth_sp_fcgi.conf
    - template: jinja
    - context:
        shib_user: {{ nginx_shibboleth.shibboleth.user }}

{% for program in ['shibauthorizer', 'shibresponder'] %}
ensure_{{ program }}_fcgi_running:
  supervisord.running:
    - name: {{ program }}
    - update: True
    - require:
        - file: place_supervisor_fcgi_configuration
{% endfor %}
