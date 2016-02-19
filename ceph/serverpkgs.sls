# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ceph/map.jinja" import ceph with context %}

ceph_serverpkgs__pkgs:
  pkg.installed:
    - pkgs: {{ ceph.serverpkgs }}
