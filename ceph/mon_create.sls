# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

ceph_keyring__mon_create:
  module.run:
    - name: ceph.mon_create
#    - require:
#      - module: keyring_admin_save
#      - module: keyring_mon_save

# Check system is quorum

cluster_status:
    ceph.quorum:
    - require:
      - module: ceph_keyring__mon_create

