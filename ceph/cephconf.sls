# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ceph/map.jinja" import ceph with context %}

ceph_cephconf__conf:
  file.managed:
    - name: /etc/ceph/{{ceph.cluster_name}}.conf
    - source: salt://ceph/files/configtempl.jinja
    - template: jinja
    - context:
      confdict: {{ceph['clusters'][ceph.cluster_name]|json}}
    - mode: 644
    - user: root
    - group: root
