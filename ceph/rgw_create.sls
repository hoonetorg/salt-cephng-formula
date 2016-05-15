# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

#ceph_rgw_create__pools_create:
#  module.run:
#    - name: ceph.rgw_pools_create
#     #FIXME 
#    #- require:
#    #  - module: keyring_rgw_auth_add

ceph_rgw_create__create:
  module.run:
    - name: ceph.rgw_create
    - kwargs: 
        name: '{{grains['id'].split('.')[0]}}'
    #- require:
    #  - module: ceph_rgw_create__pools_create
