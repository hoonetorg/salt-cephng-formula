# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

{%- for pool, pool_data in ceph.get('clusters').get(ceph.cluster_name).get('pools').items() %}
ceph_pool_create__create_{{pool}}:
  module.run:
    - name: ceph.pool_add
    - pool_name: {{pool}}
    - kwargs: 
        cluster_name: '{{ceph.cluster_name}}'
        pg_num: {{pool_data.pg_num}}
        pgp_num: {{pool_data.pgp_num}}
        {%- if pool_data.get('pool_type') %}
        pool_type: '{{pool_data.pool_type}}'
        {%- endif %}
        {%- if pool_data.get('erasure_code_profile') %}
        erasure_code_profile: '{{pool_data.erasure_code_profile}}'
        {%- endif %}
        {%- if pool_data.get('crush_ruleset') %}
        crush_ruleset: '{{pool_data.crush_ruleset}}'
        {%- endif %}
    - unless: ceph --cluster {{ceph.cluster_name}} osd lspools|grep -w {{pool}}
{%- endfor %}
