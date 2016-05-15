# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

{%- for osd, osd_data in ceph.get('clusters').get(ceph.cluster_name).get('osd').items() %}
{%- if grains['id'].split('.')[0] in [ osd_data.get('osd_node') ] %}

{%- if osd_data.get('osd_uuid') %}
ceph_osd_create__create_{{osd}}:
  cmd.run:
    - unless: ceph --cluster {{ceph.cluster_name}} osd ls|egrep "^{{osd}}$"
    - name: ceph --cluster {{ceph.cluster_name}} osd create {{osd_data.osd_uuid}} {{osd}}
    - kwargs: 
{%- endif %}

ceph_osd_create__prepare_{{osd}}:
  module.run:
    - name: ceph.osd_prepare
    - kwargs: 
        cluster_name: '{{ceph.cluster_name}}'
        osd_num: {{osd}}
        osd_fs_type: '{{osd_data.osd_fs_type|default('xfs')}}'
        osd_dev: '{{osd_data.osd_dev}}'
        {%- if osd_data.get('osd_uuid') %}
        osd_uuid: '{{osd_data.osd_uuid}}'
        {%- endif %}
        journal_dev: '{{osd_data.journal_dev}}'
        {%- if osd_data.get('journal_uuid') %}
        journal_uuid: '{{osd_data.journal_uuid}}'
        {%- endif %}
    #FIXME 
    #- require:
    #  - module: keyring_osd_auth_add

ceph_osd_create__activate_{{osd}}:
  module.run:
    - name: ceph.osd_activate
    - kwargs: 
        osd_dev: '{{osd_data.osd_dev}}'
    - require:
      - module: ceph_osd_create__prepare_{{osd}}
{%- endif %}
{%- endfor %}
