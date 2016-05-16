# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

ceph_mds_create__create:
  module.run:
    - name: ceph.mds_create
    - kwargs: 
        cluster_name: "{{ceph.cluster_name}}"
        name: "{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}"
        #is ignored currently - thank god
        port: 1000
        addr: {{ grains['fqdn_ip4'] }}
    - unless: test -f /var/lib/ceph/mds/{{ceph.cluster_name}}-{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}/done

ceph_mds_create__done:
  module.wait:
    - name: cmd.run
    - cmd: touch /var/lib/ceph/mds/{{ceph.cluster_name}}-{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}/done
    - python_shell: True
    - watch:
      - module: ceph_mds_create__create

ceph_mds_create__init:
  file.managed:
    - name: /var/lib/ceph/mds/{{ceph.cluster_name}}-{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}/{{grains['init']}}
    - require:
      - module: ceph_mds_create__create
