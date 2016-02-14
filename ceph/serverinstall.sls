# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ceph/map.jinja" import template with context %}

ceph-pkg:
  pkg.installed:
    - name: {{ ceph.pkg }}
