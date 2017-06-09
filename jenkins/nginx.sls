{% from "jenkins/map.jinja" import jenkins with context %}

{% if jenkins.symlink_vhost %}

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

extend:
  nginx:
    service:
      - watch:
        - file: /etc/nginx/sites-available/jenkins.conf
      - require:
        - file: /etc/nginx/sites-enabled/jenkins.conf

{% else %}

Add nginx config for jenkins:
  file.managed:
    - template: jinja
    - name: {{ jenkins.nginx_vhost_path }}/jenkins.conf
    - source: salt://jenkins/files/nginx.conf
    - user: {{ jenkins.nginx_user }}
    - group: {{ jenkins.nginx_group }}
    - mode: 440
    - require:
      - pkg: jenkins 

{% endif %}
