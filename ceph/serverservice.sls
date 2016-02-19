# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ceph/map.jinja" import ceph with context %}

ceph_serverservice__service:
  service.{{ ceph.serverservice.state }}:
    - name: {{ ceph.serverservice.name }}
{% if ceph.serverservice.state in [ 'running', 'dead' ] %}
    - enable: {{ ceph.serverservice.enable }}
{% endif %}
