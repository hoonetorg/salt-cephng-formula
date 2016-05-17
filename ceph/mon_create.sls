# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "ceph/map.jinja" import ceph with context %}

ceph_mon_create__create:
  module.run:
    - name: ceph.mon_create
    - kwargs:
        clustername: "{{ceph.cluster_name}}"
    - unless: test -f /var/lib/ceph/mon/{{ceph.cluster_name}}-{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done

ceph_mon_create__done:
## ceph.mon_create creates a done file
#  module.wait:
#    - name: file.touch
#    - m_name: /var/lib/ceph/mon/{{ceph.cluster_name}}-{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
#    - watch:
#      - module: ceph_mon_create__create
## ceph_cfg creates done file with wronge user/group (at least until version 0.1.2)
  file.managed:
    - name: /var/lib/ceph/mon/{{ceph.cluster_name}}-{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
    - user: ceph
    - group: ceph
    - onlyif: test -f /var/lib/ceph/mon/{{ceph.cluster_name}}-{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
    - require:
      - module: ceph_mon_create__create

## ceph_cfg does not create init file (at least until version 0.1.2)
ceph_mon_create__init:
  file.managed:
    - name: /var/lib/ceph/mon/{{ceph.cluster_name}}-{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/{{grains['init']}}
    - user: ceph
    - group: ceph
    - onlyif: test -d /var/lib/ceph/mon/{{ceph.cluster_name}}-{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}
    - require:
      - module: ceph_mon_create__create

ceph_mon_create__service:
  service.{{ ceph.monservice.state }}:
    - name: {{ ceph.monservice.name_prefix }}{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}
{% if ceph.monservice.state in [ 'running', 'dead' ] %}
    - enable: {{ ceph.monservice.enable }}
{% endif %}
    - require:
      - module: ceph_mon_create__create
