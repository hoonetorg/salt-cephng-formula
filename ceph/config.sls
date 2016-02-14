# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ceph/map.jinja" import ceph with context %}

ceph-config:
  file.managed:
    - name: {{ ceph.config }}
    - source: salt://ceph/files/etc/ceph.conf.jinja
    - mode: 644
    - user: root
    - group: root
