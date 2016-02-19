================
salt-cephng-formula
================

A saltstack formula for CEPH

.. note::

    install and configure CEPH
    Because https://github.com/hoonetorg/salt-ceph-formula needs refactoring, 
    but is used in prod and the new ceph formula is a complete rewrite, this repo exists.
    Name salt-cephng-formula will only be used during development.
    When this new formula is ready to be used on current prod servers 
    the old formula is renamed to https://github.com/hoonetorg/salt-cephlegacy-formula and 
    this repo is renamed to https://github.com/hoonetorg/salt-ceph-formula.

Available states
================

.. contents::
       :local:

``ceph``
------------

Install and configure CEPH server and client services,
configure options, create pools, create auth keys  
(for libvirt, cinder, glance f.e.)
