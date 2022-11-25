{% from "jenkins/map.jinja" import jenkins with context %}

{% set extra_groups = jenkins.extra_groups -%}

jenkins_group:
  group.present:
    - name: {{ jenkins.group }}
    - system: True

jenkins_user:
  user.present:
    - name: {{ jenkins.user }}
    - groups:
      - {{ jenkins.group }}
      {% for group in extra_groups -%}
      - {{ group }}
      {% endfor %}
    - system: True
    - home: {{ jenkins.home }}
    - shell: {{ jenkins.shell }}
    - require:
      - group: jenkins_group

{% for dir in ['/var/log/jenkins','/var/cache/jenkins',jenkins.home] %}
{{ dir }}:
  file.directory:
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 0755
    - makedirs: True
    - require:
      - user: jenkins_user
      - group: jenkins_group
{% endfor %}

jenkins:
  {% if grains['os_family'] in ['RedHat', 'Debian'] %}
    {% set repo_suffix = '' %}
    {% if jenkins.stable %}
      {% set repo_suffix = '-stable' %}
    {% endif %}
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    {% if grains['os_family'] == 'RedHat' %}
    - baseurl: https://pkg.jenkins.io/redhat{{ repo_suffix }}
    - gpgkey: https://pkg.jenkins.io/redhat{{ repo_suffix }}/jenkins.io.key
    {% elif grains['os_family'] == 'Debian' %}
    - file: {{jenkins.deb_apt_source}}
    - name: deb https://pkg.jenkins.io/debian{{ repo_suffix }} binary/
    - key_url: https://pkg.jenkins.io/debian{{ repo_suffix }}/jenkins.io.key
    {% endif %}
    - require_in:
      - pkg: jenkins
  {% endif %}
  pkg.installed:
    - pkgs: {{ jenkins.pkgs|json }}
  service.running:
    - enable: True
    - watch:
      - pkg: jenkins
      {% if grains['os_family'] in ['RedHat', 'Debian'] %}
      - file: jenkins config
      {% endif %}

{% if grains['os_family'] in ['RedHat', 'Debian'] %}
jenkins config:
  file.managed:
    {% if grains['os_family'] == 'RedHat' %}
    - name: /etc/sysconfig/jenkins
    - source: salt://jenkins/files/RedHat/jenkins.conf
    {% elif grains['os_family'] == 'Debian' %}
    - name: /etc/default/jenkins
    - source: salt://jenkins/files/Debian/jenkins.conf
    {% endif %}
    - template: jinja
    - user: root
    - group: root
    - mode: 400
    - require:
      - pkg: jenkins
{% endif %}
