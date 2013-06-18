{% set jenkins = pillar.get('jenkins', {}) -%}
{% set home = jenkins.get('home', '/usr/local/jenkins') -%}
{% set user = jenkins.get('user', 'jenkins') -%}
{% set group = jenkins.get('group', user) -%}

jenkins_group:
  group.present:
    - name: {{ group }}
    
jenkins_user:
  file.directory:
    - name: {{ home }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 0755
    - require:
      - user: jenkins_user
      - group: jenkins_group
  user.present:
    - name: {{ user }}
    - groups:
      - {{ group }}
    - require:
      - group: jenkins_group

jenkins:
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    {% if grains['os_family'] == 'RedHat' %}
    - baseurl: http://pkg.jenkins-ci.org/redhat
    - gpgkey: http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
    {% elif grains['os_family'] == 'Debian' %}
    - name: deb http://pkg.jenkins-ci.org/debian binary/
    - key_url: http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key
    {% endif %}
  pkg.latest:
    - refresh: True
    - require:
      - pkgrepo: jenkins
  service.running:
    - enable: True
    - watch:
      - pkg: jenkins
