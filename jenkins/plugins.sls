include:
  - jenkins
  - jenkins.cli

{% from "jenkins/map.jinja" import jenkins with context %}
{% import "jenkins/macros/cli_macro.jinja" as cli_macro %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd) -%}
{{ ' '.join(['java', '-jar', jenkins.cli_path, '-s', jenkins.master_url, fmtarg('-i', jenkins.get('privkey')), cmd]) }} {{ ' '.join(varargs) }}
{%- endmacro -%}

{% set plugin_cache = "{0}/updates/default.json".format(jenkins.home) %}

get_new_jenkins_plugins_registry:
  file.directory:
    - name: {{ "{0}/updates".format(jenkins.home) }}
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 755
    - require:
      - sls: jenkins
      - sls: jenkins.cli
  cmd.run:
    - unless: test -f {{ plugin_cache }}
    - name: "curl -L {{ jenkins.plugins.updates_source }} | sed '1d;$d' > {{ plugin_cache }}"
    - require:
      - file: get_new_jenkins_plugins_registry

{% for plugin in jenkins.plugins.installed %}
jenkins_install_plugin_{{ plugin }}:
  cmd.run:
    - name: {{ jenkins_cli('install-plugin', plugin) }}
    - require:
      - cmd: get_new_jenkins_plugins_registry
    - watch_in:
      - service: restart_jenkins_after_plugins_installation
{% endfor %}

{% for plugin in jenkins.plugins.disabled %}
jenkins_disable_plugin_{{ plugin }}:
  file.managed:
    - name: {{ jenkins.home }}/plugins/{{ plugin }}.jpi.disabled
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - contents: ''
    - require:
      - cmd: get_new_jenkins_plugins_registry
    - watch_in:
      - service: restart_jenkins_after_plugins_installation
{% endfor %}

restart_jenkins_after_plugins_installation:
  service.running:
    - name: jenkins
