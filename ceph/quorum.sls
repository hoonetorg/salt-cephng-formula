# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

ceph_quorum__quorum:
    ceph.quorum:
      - cluster_name: {{ceph.cluster_name}}

