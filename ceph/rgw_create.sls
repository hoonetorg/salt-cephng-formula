# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

## rgw pools not valid for jewel anymore
#ceph_rgw_create__pools_create:
#  module.run:
#    - name: ceph.rgw_pools_create
#    - kwargs:
#        cluster_name: '{{ceph.cluster_name}}'

ceph_rgw_create__create:
  module.run:
    - name: ceph.rgw_create
    - kwargs:
        cluster_name: "{{ceph.cluster_name}}"
        name: "rgw.{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}"
    #- require:
    #  - module: ceph_rgw_create__pools_create
