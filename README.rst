================
nginx-shibboleth
================

Formula to install and configure the Shibboleth Service Provider with Nginx integration

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.


Available states
================

.. contents::
    :local:

``nginx-shibboleth.install``
--------------------

Installs the Shibboleth Service Provider, as well as compiling Nginx with support for interfacing with the service
provider via the FastCGI protocol.

``nginx-shibboleth.config``
-------------------------

This state will place the contents of the shibboleth key and certificate from
pillar data. It will also render the shibboleth service provider configuration
from a pillar dictionary. The contents of the configuration requires a `RequestMapper_`
block with a Host:name attribute that matches the server_name configured in Nginx.


Template
========

This formula was created from a cookiecutter template.

See https://github.com/mitodl/saltstack-formula-cookiecutter.

.. _RequestMapper: https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapper
