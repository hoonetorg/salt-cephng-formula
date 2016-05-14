# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}
{%- for keyring, keyring_data in ceph.get('clusters').get(ceph.cluster_name).get('keyrings').items() %}
{%- if keyring not in [ 'admin', 'mon' ] %}
{%- if keyring_data.get('caps') %}
ceph_keyring_auth_add__keyring_{{keyring}}:
  {%- if keyring_data.get('filename') %}
  module.run:
    - name: cmd.run
    - cmd: "ceph auth import -i {{keyring_data.filename}}"
    - unless: "ceph auth get {{keyring_data.name}}"
    - python_shell: True
  {%- else %}
  #FIXME: do not use, does not set the key
  module.run:
    - name: cmd.run
    - cmd: "/usr/bin/ceph --connect-timeout 5 --cluster {{ceph.cluster_name}} auth get-or-create {{keyring_data.name}}{% for cap in keyring_data.caps %} {{ cap }}{%- endfor %}"
    - unless: "ceph auth get {{keyring_data.name}}"
    - python_shell: True
  {%- endif %}
{%- else %}
ceph_keyring_auth_add__keyring_{{keyring}}:
  module.run:
    - name: ceph.keyring_auth_add
    - kwargs: {
        'keyring_type' : '{{keyring}}',
        }
{%- endif %}
{%- endif %}
{%- endfor %}
