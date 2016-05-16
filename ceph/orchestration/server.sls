#!jinja|yaml
{% set node_ids_mon = salt['pillar.get']('ceph:server:pcs:node_ids_mon') -%}
{% set node_ids_osd = salt['pillar.get']('ceph:server:pcs:node_ids_osd') -%}
{% set node_ids_mds = salt['pillar.get']('ceph:server:pcs:node_ids_mds') -%}
{% set node_ids_rgw = salt['pillar.get']('ceph:server:pcs:node_ids_rgw') -%}
{% set node_ids_servers = node_ids_mon + node_ids_osd + node_ids_mds + node_ids_rgw -%}
{% set admin_node_id = salt['pillar.get']('ceph:server:pcs:admin_node_id') -%}
# node_ids_mon: {{node_ids_mon|json}}
# node_ids_osd: {{node_ids_osd|json}}
# node_ids_mds: {{node_ids_mds|json}}
# node_ids_rgw: {{node_ids_rgw|json}}
# node_ids_servers: {{node_ids_servers|json}}
# admin_node_id: {{admin_node_id}}

ceph_orchestration__mon:
  salt.state:
    - tgt: {{node_ids_mon}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.mon

ceph_orchestration__quorum:
  salt.state:
    - tgt: {{admin_node_id}}
    - expect_minions: True
    - sls: ceph.quorum
    - require:
      - salt: ceph_orchestration__mon

ceph_orchestration__keyring_auth_add:
  salt.state:
    - tgt: {{admin_node_id}}
    - expect_minions: True
    - sls: ceph.keyring_auth_add
    - require:
      - salt: ceph_orchestration__quorum

ceph_orchestration__osd:
  salt.state:
    - tgt: {{node_ids_osd}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.osd
    - require:
      - salt: ceph_orchestration__keyring_auth_add

ceph_orchestration__pools:
  salt.state:
    - tgt: {{admin_node_id}}
    - expect_minions: True
    - sls: ceph.pool_create
    - require:
      - salt: ceph_orchestration__osd

ceph_orchestration__rgw:
  salt.state:
    - tgt: {{node_ids_rgw}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.rgw_create
    - require:
      - salt: ceph_orchestration__pools

ceph_orchestration__mds:
  salt.state:
    - tgt: {{node_ids_mds}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.mds_create
    - require:
      - salt: ceph_orchestration__pools
