{% from "jenkins/map.jinja" import jenkins with context %}

# Install nginx, run nginx only if installation is successful
install_nginx_package:
  pkg.installed:
    - name: nginx

{% if grains['os_family'] == 'RedHat' %}

# This is the main config for nginx which applies to all instances.
# It refers to default.d config.
configure_main_nginx_configs_generally:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://jenkins/files/nginx_centos.conf
    - user: {{ jenkins.nginx_user }}
    - group: {{ jenkins.nginx_group }}
    - require:
      - pkg: install_nginx_package

# Pastes the configuration for nginx about Jenkins. This is the default dir.
configure_nginx_specifically_for_jenkins:
  file.managed:
    - name: /etc/nginx/default.d/jenkins.conf
    - source: salt://jenkins/files/jenkins_centos.conf
    - user: {{ jenkins.nginx_user }}
    - group: {{ jenkins.nginx_group }}
    - require:
      - file: configure_main_nginx_configs_generally

{% else %}

# This section is for any OS family that is not RedHat. This works well on
# Debian distributions but if you discover irregularities for other
# distributions, feel free to submit a Pull Request.
configure_main_nginx_configs_generally:
  file.managed:
    - name: /etc/nginx/sites-available/jenkins.conf
    - template: jinja
    - source: salt://jenkins/files/nginx_debian.conf
    - user: {{ jenkins.nginx_user }}
    - group: {{ jenkins.nginx_group }}
    - mode: 440
    - require:
      - pkg: jenkins

configure_nginx_specifically_for_jenkins:
  file.symlink:
    - name: /etc/nginx/sites-enabled/jenkins.conf
    - target: /etc/nginx/sites-available/jenkins.conf
    - user: {{ jenkins.nginx_user }}
    - group: {{ jenkins.nginx_group }}

{% endif %}

# Restart nginx after successful configuration and installation
start_nginx_when_ready:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - pkg: nginx
    - watch:
      # Watch the dynamically generated ID depending on OS families
      - file: configure_nginx_specifically_for_jenkins
      - file: configure_main_nginx_configs_generally
