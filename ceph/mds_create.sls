# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

ceph_mds_create__create:
  module.run:
    - name: ceph.mds_create
    - kwargs: 
        cluster_name: "{{ceph.cluster_name}}"
        name: "{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}"
        #is ignored currently - thank god
        port: 1000
        addr: {{ grains['fqdn_ip4'] }}

