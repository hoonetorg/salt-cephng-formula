# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

ceph_mon_create__create:
  module.run:
    - name: ceph.mon_create
    - kwargs:
        clustername: "{{ceph.cluster_name}}"
