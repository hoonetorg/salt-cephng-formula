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
  module.wait:
    - name: cmd.run
    - cmd: touch /var/lib/ceph/mon/{{ceph.cluster_name}}-{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/done
    - python_shell: True
    - watch:
      - module: ceph_mon_create__create

ceph_mon_create__init:
  file.managed:
    - name: /var/lib/ceph/mon/{{ceph.cluster_name}}-{{ceph.get('clusters').get(ceph.cluster_name).get('cephhostname')}}/{{grains['init']}}
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
