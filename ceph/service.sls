# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ceph/map.jinja" import ceph with context %}

ceph.target:
  service.running:
    - name: {{ ceph.service.name }}
    - enable: True
