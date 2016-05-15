# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}
{%- for keyring, keyring_data in ceph.get('clusters').get(ceph.cluster_name).get('keyrings').items() %}

{%- if keyring_data.get('caps') %}
  {%- if keyring_data.get('filename') %}
ceph_keyring_save__keyring_{{keyring}}:
  module.run:
    - name: cmd.run
    - cmd: "ceph-authtool -n {{keyring_data.name}} --create-keyring {{keyring_data.filename}} --add-key {{keyring_data.key}}{% for cap in keyring_data.caps %} --cap {{ cap }}{%- endfor %}"
    - unless: "test -f {{keyring_data.filename}}"
    - python_shell: True

  {%- endif %}
{%- else %}
ceph_keyring_save__keyring_{{keyring}}:
  module.run:
    - name: ceph.keyring_save
    - kwargs: 
        cluster_name: "{{ceph.cluster_name}}"
        keyring_type: "{{keyring}}"
        secret: "{{keyring_data.key}}"
{%- endif %}
{%- endfor %}
