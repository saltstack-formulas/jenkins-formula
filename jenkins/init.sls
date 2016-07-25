{% from "jenkins/map.jinja" import jenkins with context %}

# Always create the group first before creating the user within that group.
create_jenkins_group:
  group.present:
    - name: {{ jenkins.group }}
    - system: True

create_jenkins_user:
  user.present:
    - name: {{ jenkins.user }}
    - groups:
      - {{ jenkins.group }}
    - system: True
    - home: {{ jenkins.home }}
    - shell: /bin/bash
    - require:
      - group: create_jenkins_group
  file.directory:
    - name: {{ jenkins.home }}
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 755
    - require:
      - user: create_jenkins_user

jenkins:
  {% if grains['os_family'] in ['RedHat', 'Debian'] %}
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    {% if grains['os_family'] == 'RedHat' %}
    - baseurl: http://pkg.jenkins-ci.org/redhat{{ jenkins.repo_version }}
    - gpgkey: http://pkg.jenkins-ci.org/redhat{{ jenkins.repo_version }}/jenkins-ci.org.key
    {% elif grains['os_family'] == 'Debian' %}
    - file: {{jenkins.deb_apt_source}}
    - name: deb http://pkg.jenkins-ci.org/debian binary/
    - key_url: http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key
    {% endif %}
    - require:
      - file: create_jenkins_user
  {% endif %}
  pkg.installed:
    - pkgs: {{ jenkins.pkgs|json }}
    - require:
      - pkgrepo: jenkins
  service.running:
    - enable: True
    - watch:
      - pkg: jenkins
