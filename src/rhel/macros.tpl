{% macro env_metadata() %}{% endmacro %}

{% macro _version_selector(spec) %}
{% if spec.python_img_version %}{{ spec.python_img_version }}{% else %}{{ spec.version }}{% endif %}
{% endmacro %}

{% macro _component_name(spec) -%}
python-{{ spec.short_ver }}-container
{%- endmacro %}

{% macro _image_name(spec) %}
{{ spec.org }}/python-{{ spec.short_ver }}
{%- endmacro %}

{% macro labels(spec) %}
      com.redhat.component="{{ _component_name(spec) }}" \
      name="{{ _image_name(spec) }}" \
      version="{{ _version_selector(spec) }}" \
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
{% if spec.version != "3.6" %}
    # Python 3.7+ only code, Python <3.7 installs pip from PyPI in the assemble script. \
    # We have to upgrade pip to a newer verison because \
    # pip < 19.3 does not support manylinux2014 wheels. Only manylinux2014 (and later) wheels \
    #   support platforms like ppc64le, aarch64 or armv7 \
    # We are newly using wheel from one of the latest stable Fedora releases (from RPM python-pip-wheel) \
    # because it's tested better then whatever version from PyPI and contains useful patches. \
    # We have to do it here (in the macro) so the permissions are correctly fixed and pip is able \
    # to reinstall itself in the next build phases in the assemble script if user wants the latest version \
    ${APP_ROOT}/bin/pip install /opt/wheels/pip-* && \
{% endif %}
    rm -r /opt/wheels && \
    chown -R 1001:0 ${APP_ROOT} && \
    fix-permissions ${APP_ROOT} -P && \
    rpm-file-permissions && \
    # The following echo adds the unset command for the variables set below to the \
    # venv activation script. This is inspired from scl_enable script and prevents \
    # the virtual environment to be activated multiple times and also every time \
    # the prompt is rendered. \
    echo "unset BASH_ENV PROMPT_COMMAND ENV" >> ${APP_ROOT}/bin/activate

# For RHEL/Centos 8+ scl_enable isn't sourced automatically in s2i-core
# so virtualenv needs to be activated this way
ENV BASH_ENV="${APP_ROOT}/bin/activate" \
    ENV="${APP_ROOT}/bin/activate" \
    PROMPT_COMMAND=". ${APP_ROOT}/bin/activate"
{% endmacro %}
