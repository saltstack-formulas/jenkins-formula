include:
  - jenkins

{% from "jenkins/map.jinja" import jenkins with context %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd, strargs) -%}
{{ ' '.join([jenkins.cli, fmtarg('-s', jenkins.get('master_url')), fmtarg('-i', jenkins.get('privkey')), cmd, strargs]) }}
{%- endmacro -%}

jenkins_updates_downloader:
  pkg.installed:
    - name: curl

jenkins_updates_directory:
  file.directory:
    - name: {{ jenkins.home }}/updates/
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - makedirs: True

jenkins_updates_file:
  cmd.run:
    - unless: test -f {{ jenkins.home }}/updates/default.json
    - name: "curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' > {{ jenkins.home }}/updates/default.json"
    - require:
      - service: jenkins
    - watch_in:
      - service: jenkins

{% for plugin in jenkins.plugins.installed %}
jenkins_install_plugin_{{ plugin }}:
  cmd.run:
    - unless: {{ jenkins_cli('list-plugins', '') }} | grep {{ plugin }}
    - name: {{ jenkins_cli('install-plugin', plugin) }}
    - timeout: 360
    - require:
      - service: jenkins
    - watch_in:
      - service: jenkins
{% endfor %}
