{% macro env_metadata() %}{% endmacro %}

{% macro _component_name(spec) -%}
python-{{ spec.short_ver }}-container
{%- endmacro %}

{% macro _image_name(spec) %}
{{ spec.org }}/python-{{ spec.short_ver }}
{%- endmacro %}

{% macro labels(spec) %}
      com.redhat.component="{{ _component_name(spec) }}" \
      name="{{ _image_name(spec) }}" \
      usage="s2i build https://github.com/sclorg/s2i-python-container.git --context-dir={{spec.version }}/test/setup-test-app/ {{ _image_name(spec) }} python-sample-app" \
      {% if spec.version in spec.get("ubi_versions", []) %}
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI" \
      io.buildpacks.stack.id="com.redhat.stacks.ubi{{ spec.el_version }}-python-{{ spec.short_ver }}" \
      {% endif %}
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"
{% endmacro %}

{% macro venv_setup(spec) %}
RUN \
{# Use different virtualenv command of venv module based on Python and platform version #}
{% if spec.version != "3.6" %}
    python{{ spec.version }} -m venv ${APP_ROOT} && \
{% else %}
    virtualenv-$PYTHON_VERSION ${APP_ROOT} && \
{% endif %}
    chown -R 1001:0 ${APP_ROOT} && \
    fix-permissions ${APP_ROOT} -P && \
    rpm-file-permissions && \
    # The following echo adds the unset command for the variables set below to the \
    # venv activation script. This prevents the virtual environment from being \
    # activated multiple times and also every time the prompt is rendered. \
    echo "unset BASH_ENV PROMPT_COMMAND ENV" >> ${APP_ROOT}/bin/activate
# Ensure the virtualenv is activated in interactive shells
ENV BASH_ENV="${APP_ROOT}/bin/activate" \
    ENV="${APP_ROOT}/bin/activate" \
    PROMPT_COMMAND=". ${APP_ROOT}/bin/activate"
{% endmacro %}
