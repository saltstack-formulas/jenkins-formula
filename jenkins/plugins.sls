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

jenkins_updates_file:
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
      - file: jenkins_updates_file

{% for plugin in jenkins.plugins.installed %}
jenkins_install_plugin_{{ plugin }}:
  cmd.run:
    - name: {{ jenkins_cli('install-plugin', plugin) }}
    - require:
      - cmd: jenkins_updates_file
    - watch_in:
      - service: restart_jenkins_after_plugins_installation
    ## Hack with listen_in because it triggers by default a restart
    ## after all states have been applied which just happens to be
    ## after plugin installation. But for the future, if more states
    ## are introduced and some have to run after plugins installation
    ## then this hack won't be working to start at the correct time.
    # - listen_in:
    #   - service: jenkins
{% endfor %}

{% for plugin in jenkins.plugins.disabled %}
jenkins_disable_plugin_{{ plugin }}:
  file.managed:
    - name: {{ jenkins.home }}/plugins/{{ plugin }}.jpi.disabled
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - contents: ''
    - require:
      - cmd: jenkins_updates_file
{% endfor %}

restart_jenkins_after_plugins_installation:
  service.running:
    - name: jenkins

# restart_jenkins_after_plugins:
#   cmd.run:
#     - name: "systemctl restart jenkins"
