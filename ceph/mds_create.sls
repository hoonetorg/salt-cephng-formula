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
## ceph.mds_create creates no done file (at least until version 0.1.2)
  module.wait:
    - name: file.touch
    - m_name: /var/lib/ceph/mds/{{ceph.cluster_name}}-{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}/done
    - watch:
      - module: ceph_mds_create__create
  file.managed:
    - name: /var/lib/ceph/mds/{{ceph.cluster_name}}-{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}/done
    - user: ceph
    - group: ceph
    - onlyif: test -f /var/lib/ceph/mds/{{ceph.cluster_name}}-{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}/done
    - require:
      - module: ceph_mds_create__create

## ceph_cfg does not create init file (at least until version 0.1.2)
ceph_mds_create__init:
  file.managed:
    - name: /var/lib/ceph/mds/{{ceph.cluster_name}}-{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}/{{grains['init']}}
    - user: ceph
    - group: ceph
    - onlyif: test -d /var/lib/ceph/mds/{{ceph.cluster_name}}-{{ ceph.get('clusters').get(ceph.cluster_name).get('cephhostname') }}
    - require:
      - module: ceph_mds_create__create

ceph_mds_create__service:
  service.{{ ceph.mdsservice.state }}:
    - name: {{ ceph.mdsservice.name_prefix }}{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}
{% if ceph.mdsservice.state in [ 'running', 'dead' ] %}
    - enable: {{ ceph.mdsservice.enable }}
{% endif %}
    - require:
      - module: ceph_mds_create__create
      - file: ceph_mds_create__init

ceph_mds_create__servicetarget:
  service.{{ ceph.mdsservicetarget.state }}:
    - name: {{ ceph.mdsservicetarget.name}}
{% if ceph.mdsservicetarget.state in [ 'running', 'dead' ] %}
    - enable: {{ ceph.mdsservicetarget.enable }}
{% endif %}
    - require:
      - module: ceph_mds_create__create
      - file: ceph_mds_create__init
