# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  - ceph.ceph_cfg_sudo
  - ceph.serverpkgs
  - ceph.serverservice
  - ceph.cephconf
  - ceph.keyring_save
  - ceph.keyring_auth_add
  - ceph.mon_create
