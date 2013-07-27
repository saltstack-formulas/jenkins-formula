include:
  - nginx

/etc/nginx/sites-available/jenkins.conf:
  file:
    - managed
    - template: jinja
    - source: salt://jenkins/files/nginx.conf
    - user: www-data
    - group: www-data
    - mode: 440
    - require:
      - pkg: jenkins

/etc/nginx/sites-enabled/jenkins.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/jenkins.conf
    - user: www-data
    - group: www-data

extend:    
  nginx:
    service:
      - watch:
        - file: /etc/nginx/sites-available/jenkins.conf
