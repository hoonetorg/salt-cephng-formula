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

ceph_orchestration__serverpkgs:
  salt.state:
    - tgt: {{node_ids_servers}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.serverpkgs

ceph_orchestration__cephconf:
  salt.state:
    - tgt: {{node_ids_servers}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.cephconf
    - require:
      - salt: ceph_orchestration__serverpkgs

#ceph_orchestration__deploy:
#  salt.state:
##    - tgt: {{admin_node_id}}
#    - expect_minions: True
#    - sls: ceph.deploy
#    - require:
#      - salt: ceph_orchestration__pcs
