{% from "nginx-shibboleth/map.jinja" import nginx_shibboleth with context %}
{% set pillar_config = salt.pillar.get('nginx-shibboleth:config', {}) %}

include:
  - .install
  - .service

{% if nginx_shibboleth.generate_sp_cert %}
generate_shibboleth_sp_cert_and_key:
  cmd.run:
    - name: shib-keygen
    - creates: /etc/shibboleth/sp-cert.pem
{% else %}
{% for secret in ['key', 'cert'] %}
place_shibboleth_sp_{{ secret }}:
  file.managed:
    - name: /etc/shibboleth/sp-{{ secret }}.pem
    - mode: 0644
    - user: _shibd
    - group: _shibd
    - contents_pillar: nginx-shibboleth:secrets:{{ secret }}
    - onchanges_in:
        - service: nginx_shibboleth_service_running
{% endfor %}
{% endif %}

{% for config_name, config_data in pillar_config.items() %}
generate_{{ config_name }}_configuration_file:
  file.managed:
    - name: /etc/shibboleth/{{ config_name }}.xml
    - contents: |
        {{ config_data|xml()|indent(8) }}
    - onchanges_in:
        - service: nginx_shibboleth_service_running
{% endfor %}

place_supervisor_fcgi_configuration:
  file.managed:
    - name: /etc/supervisor/conf.d/shibboleth_sp_fcgi.conf
    - source: salt://nginx-shibboleth/files/shibboleth_sp_fcgi.conf

ensure_shibauthorizer_fcgi_running:
  supervisord.running:
    - name: 'fcgi-program:shibauthorizer'
    - update: True
