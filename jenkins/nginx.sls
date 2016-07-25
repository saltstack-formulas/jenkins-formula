{% from "jenkins/map.jinja" import jenkins with context %}

/etc/nginx/sites-available/jenkins.conf:
  file.managed:
    - template: jinja
    - source: salt://jenkins/files/nginx.conf
    - user: {{ jenkins.nginx_user }}
    - group: {{ jenkins.nginx_group }}
    - mode: 440
    - require:
      - pkg: jenkins

/etc/nginx/sites-enabled/jenkins.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/jenkins.conf
    - user: {{ jenkins.nginx_user }}
    - group: {{ jenkins.nginx_group }}
