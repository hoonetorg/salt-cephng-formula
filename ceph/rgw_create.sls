# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

## rgw pools not valid for jewel anymore
#ceph_rgw_create__pools_create:
#  module.run:
#    - name: ceph.rgw_pools_create
#    - kwargs:
#        cluster_name: '{{ceph.cluster_name}}'

ceph_rgw_create__create:
  module.run:
    - name: ceph.rgw_create
    - kwargs:
        cluster_name: "{{ceph.cluster_name}}"
        name: "rgw.{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}"
    - unless: test -f /var/lib/ceph/radosgw/{{ceph.cluster_name}}-rgw.{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
    #- require:
    #  - module: ceph_rgw_create__pools_create

ceph_rgw_create__done:
  module.wait:
    - name: cmd.run
    - cmd: touch /var/lib/ceph/radosgw/{{ceph.cluster_name}}-rgw.{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
    - python_shell: True
    - watch:
      - module: ceph_rgw_create__create

ceph_rgw_create__init:
  file.managed:
    - name: /var/lib/ceph/radosgw/{{ceph.cluster_name}}-rgw.{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/{{grains['init']}}
    - require:
      - module: ceph_rgw_create__create

