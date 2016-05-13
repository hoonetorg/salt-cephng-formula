# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

ceph_keyring__sudo:
  file.managed:
    - name: /etc/sudoers.d/donotrequiretty
    - contents: "Defaults    !requiretty"
    - user: root
    - group: root
    - mode: "0644"
