include:
  - jenkins
  - jenkins.cli

{% from "jenkins/map.jinja" import jenkins with context %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd) -%}
{{ ' '.join(['java', '-jar', jenkins.cli_path, '-s', jenkins.master_url, fmtarg('-i', jenkins.get('privkey')), cmd]) }} {{ ' '.join(varargs) }}
{%- endmacro -%}

{% for job, path in jenkins.jobs.installed.iteritems() %}
jenkins_install_job_{{ job }}:
  cmd.run:
    - unless: {{ jenkins_cli('list-jobs') }} | grep {{ job }}
    - name: {{ jenkins_cli('create-job', job, '<', path) }}
    - timeout: 360
    - require:
      - service: jenkins
      - cmd: jenkins_updates_file
      - cmd: jenkins_cli_jar
{% endfor %}
