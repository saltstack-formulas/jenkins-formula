jenkins
=======

Available states
================

.. contents::
    :local:

``jenkins``
-----------

Install jenkins from the source package repositories and start it up.


``jenkins.nginx``
-----------------

Add a jenkins nginx entry. It depends on the nginx formula being installed and
requires manual inclusion `nginx` and `jenkins` states in your `top.sls` to
function, in this order: `jenkins`, `nginx`, `jenkins.nginx`.


``jenkins.plugins``
-------------------

Install listed jenkins plugins.


``jenkins.jobs``
----------------

Automatically create jenkins jobs and update them when they change. Allows you to specify a list of jobs that already
exist on the server.

Assumes you have some way to copy your config to the server, e.g.

.. code-block:: yaml

    {% for job, path in salt['pillar.get']('jenkins:lookup:jobs:installed', {}).iteritems() %}
    jenkins-host_job_definition_{{ job }}:
      file.managed:
        - name: {{ path }}
        - source: salt://path/to/jenkins/jobs/{{ job }}.xml
        - template: jinja

    {% endfor %}


Pillar customizations:
======================

.. code-block:: yaml

    jenkins:
      lookup:
        # Base
        port: 80
        home: /usr/local/jenkins
        user: jenkins
        group: www-data
        server_name: ci.example.com
        # Nginx
        symlink_vhost: False
        nginx_user: nginx
        nginx_group: nginx
        nginx_vhost_path: /etc/nginx/sites-available
        # Plugins
        plugins:
          installed:
            - git
            - rebuild
        # Jobs
        jobs:
          installed:
            JobName: /var/lib/jenkins/jobDefs/jobFile.xml

