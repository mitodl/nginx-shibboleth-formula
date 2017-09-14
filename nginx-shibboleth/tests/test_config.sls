{% for fname in ['sp-key', 'sp-cert'] %}
test_{{ fname }}_present:
  testinfra.file:
    - name: /etc/shibboleth/{{ fname }}.pem
    - exists: True
    - is_file: True
    - user:
        expected: _shibd
        comparison: eq
    - group:
        expected: _shibd
        comparison: eq
    - mode:
        expected: 420
        comparison: eq
{% endfor %}
