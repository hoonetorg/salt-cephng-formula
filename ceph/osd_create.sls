# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

{%- for osd, osd_data in ceph.get('clusters').get(ceph.cluster_name).get('osd').items() %}
{%- if ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') in [ osd_data.get('osd_node') ] %}

{%- if osd_data.get('osd_uuid') %}
ceph_osd_create__create_{{osd}}:
  cmd.run:
    - unless: ceph --cluster {{ceph.cluster_name}} osd ls|egrep "^{{osd}}$"
    - name: ceph --cluster {{ceph.cluster_name}} osd create {{osd_data.osd_uuid}} {{osd}}
{%- endif %}

ceph_osd_create__prepare_{{osd}}:
  module.run:
    - name: ceph.osd_prepare
    - kwargs: 
        cluster_name: '{{ceph.cluster_name}}'
        fs_type: '{{osd_data.fs_type|default('xfs')}}'
        {%- if osd_data.get('dmcrypt') %}
        dmcrypt: '{{osd_data.dmcrypt}}'
        {%- endif %}
        {%- if osd_data.get('dmcrypt_key_dir') %}
        dmcrypt_key_dir: '{{osd_data.dmcrypt_key_dir}}'
        {%- endif %}
        osd_dev: '{{osd_data.osd_dev}}'
        {%- if osd_data.get('osd_uuid') %}
        osd_uuid: '{{osd_data.osd_uuid}}'
        {%- endif %}
        journal_dev: '{{osd_data.journal_dev}}'
        {%- if osd_data.get('journal_uuid') %}
        journal_uuid: '{{osd_data.journal_uuid}}'
        {%- endif %}
{%- if osd_data.get('osd_uuid') %}
    - require:
      - cmd: ceph_osd_create__create_{{osd}}
{%- endif %}
    - unless: "test -d /var/lib/ceph/osd/{{ceph.cluster_name}}-{{osd}} -o -L /var/lib/ceph/osd/{{ceph.cluster_name}}-{{osd}}"

{%- if osd_data.get('dmcrypt') %}
ceph_osd_create__activate_{{osd}}:
  module.wait:
    - name: cmd.run
    - cmd: ceph-disk -v activate --mark-init {{grains['init']}} --dmcrypt {% if osd_data.get('--dmcrypt-key-dir') %}--dmcrypt-key-dir {{osd_data.dmcrypt_key_dir}}{% endif %} `python -c "import os;path=os.path.realpath('{{osd_data.osd_dev}}');print(path)"`1
    - python_shell: True
    - watch:
      - module: ceph_osd_create__prepare_{{osd}}
    - watch_in: 
      - service: ceph_osd_create__servicetarget

ceph_osd_create__lukskeydir_{{osd}}:
  file.directory:
    - name: /etc/ceph/dmcrypt-keys
    - user: ceph
    - group: ceph
    - makedirs: True

ceph_osd_create__getlukskey_{{osd}}:
  module.wait:
    - name: cmd.run
    - cmd: ceph config-key get dm-crypt/osd/{{osd_data.osd_uuid}}/luks > /etc/ceph/dmcrypt-keys/{{osd_data.osd_uuid}}
    - user: ceph
    - group: ceph
    - python_shell: True
    - require: 
      - file: ceph_osd_create__lukskeydir_{{osd}}
    - watch:
      - module: ceph_osd_create__prepare_{{osd}}

ceph_osd_create__lukskey_{{osd}}:
  file.managed:
    - name: /etc/ceph/dmcrypt-keys/{{osd_data.osd_uuid}}
    - user: ceph
    - group: ceph
    - onlyif: test -f /etc/ceph/dmcrypt-keys/{{osd_data.osd_uuid}}
    - require: 
      - module: ceph_osd_create__getlukskey_{{osd}}

{%- else %}
ceph_osd_create__activate_{{osd}}:
  module.wait:
    - name: ceph.osd_activate
    - kwargs: 
        cluster_name: '{{ceph.cluster_name}}'
        {%- if osd_data.get('dmcrypt') %}
        dmcrypt: '{{osd_data.dmcrypt}}'
        {%- endif %}
        {%- if osd_data.get('dmcrypt_key_dir') %}
        dmcrypt_key_dir: '{{osd_data.dmcrypt_key_dir}}'
        {%- endif %}
        osd_dev: '{{osd_data.osd_dev}}'
    - watch:
      - module: ceph_osd_create__prepare_{{osd}}
    - watch_in: 
      - service: ceph_osd_create__servicetarget
{%- endif %}

{%- endif %}
{%- endfor %}

ceph_osd_create__servicetarget:
  service.{{ ceph.osdservicetarget.state }}:
    - name: {{ ceph.osdservicetarget.name}}
{% if ceph.osdservicetarget.state in [ 'running', 'dead' ] %}
    - enable: {{ ceph.osdservicetarget.enable }}
{% endif %}

