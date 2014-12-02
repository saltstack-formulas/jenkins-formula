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
  pkg.latest:
    - refresh: True
  service.running:
    - enable: True
    - watch:
      - pkg: jenkins
