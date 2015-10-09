include:
  - jenkins

{% from "jenkins/map.jinja" import jenkins with context %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd, strargs) -%}
{{ ' '.join([jenkins.cli, fmtarg('-s', jenkins.get('master_url')), fmtarg('-i', jenkins.get('privkey')), cmd, strargs]) }}
{%- endmacro -%}

{% set plugin_cache = "{0}/updates/default.json".format(jenkins.home) %}

jenkins_updates_file:
  pkg.installed:
    - name: curl

  cmd.run:
    - unless: test -f {{ plugin_cache }}
    - name: "curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' > {{ plugin_cache }}"
    - require:
      - pkg: jenkins
      - pkg: jenkins_updates_file

restart_jenkins:
  cmd.wait:
    - name: {{ jenkins_cli('safe-restart', '') }}

reload_jenkins_config:
  cmd.wait:
    - name: {{ jenkins_cli('reload-configuration', '') }}

{% for plugin in jenkins.plugins.installed %}
jenkins_install_plugin_{{ plugin }}:
  cmd.run:
    - unless: {{ jenkins_cli('list-plugins', '') }} | grep {{ plugin }}
    - name: {{ jenkins_cli('install-plugin', plugin) }}
    - timeout: 360
    - require:
      - service: jenkins
      - cmd: jenkins_updates_file
    - watch_in:
      - cmd: restart_jenkins
{% endfor %}

{% for plugin in jenkins.plugins.disabled %}
jenkins_disable_plugin_{{ plugin }}:
  file.managed:
    - name: {{ jenkins.home }}/plugins/{{ plugin }}.jpi.disabled
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - contents: ''
    - watch_in:
      - cmd: restart_jenkins
{% endfor %}