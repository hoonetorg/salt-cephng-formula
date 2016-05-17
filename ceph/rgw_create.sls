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
## ceph.rgw_create creates no done file (at least until version 0.1.2)
  module.wait:
    - name: file.touch
    - m_name: /var/lib/ceph/radosgw/{{ceph.cluster_name}}-rgw.{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
    - watch:
      - module: ceph_rgw_create__create
  file.managed:
    - name: /var/lib/ceph/radosgw/{{ceph.cluster_name}}-rgw.{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
    - user: ceph
    - group: ceph
    - onlyif: test -f /var/lib/ceph/radosgw/{{ceph.cluster_name}}-rgw.{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
    - require:
      - module: ceph_rgw_create__create

## ceph_cfg does not create init file (at least until version 0.1.2)
ceph_rgw_create__init:
  file.managed:
    - name: /var/lib/ceph/radosgw/{{ceph.cluster_name}}-rgw.{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/{{grains['init']}}
    - user: ceph
    - group: ceph
    - onlyif: test -d /var/lib/ceph/radosgw/{{ceph.cluster_name}}-rgw.{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}
    - require:
      - module: ceph_rgw_create__create

ceph_rgw_create__service:
  service.{{ ceph.rgwservice.state }}:
    - name: {{ ceph.rgwservice.name_prefix }}{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}
{% if ceph.rgwservice.state in [ 'running', 'dead' ] %}
    - enable: {{ ceph.rgwservice.enable }}
{% endif %}
    - require:
      - module: ceph_rgw_create__create
      - file: ceph_rgw_create__init

ceph_rgw_create__servicetarget:
  service.{{ ceph.rgwservicetarget.state }}:
    - name: {{ ceph.rgwservicetarget.name}}
{% if ceph.rgwservicetarget.state in [ 'running', 'dead' ] %}
    - enable: {{ ceph.rgwservicetarget.enable }}
{% endif %}
    - require:
      - module: ceph_rgw_create__create
      - file: ceph_rgw_create__init
