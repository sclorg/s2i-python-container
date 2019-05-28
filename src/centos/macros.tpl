{% macro env_metadata() %}{% endmacro %}

{% macro _version_selector(spec) %}
{% if spec.python_img_version %}{{ spec.python_img_version }}{% else %}{{ spec.version }}{% endif %}
{% endmacro %}

{% macro _component_name(spec) -%}
{% if spec.version.startswith('3.') %}{{ spec.python3_component_prefix }}{% endif -%}
python
{%- if spec.el_version == '8' %}-{% endif -%}
{{ spec.short_ver }}-container
{%- endmacro %}

{% macro _image_name(spec) %}
{{ spec.org }}/python-{{ spec.short_ver }}{% if spec.el_version == '7' %}-{{ spec.prod }}{% endif %}
{% endmacro %}

{% macro labels(spec) %}
      com.redhat.component="{{ _component_name(spec) }}" \
      name="{{ _image_name(spec) }}" \
      version="{{ _version_selector(spec) }}" \
      usage="s2i build https://github.com/sclorg/s2i-python-container.git --context-dir={{spec.version }}/test/setup-test-app/ {{ _image_name(spec) }} python-sample-app" \
      {% if spec.version in spec.ubi_versions %}
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI" \
      {% endif %}
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"
{% endmacro %}

{% macro permissions_setup(spec) %}
{% if spec.el_version == '7' %}
RUN source scl_source enable {{ spec.scl }} && \
    virtualenv ${APP_ROOT} && \
{% else %}
RUN virtualenv-$PYTHON_VERSION ${APP_ROOT} && \
{% endif %}
    chown -R 1001:0 ${APP_ROOT} && \
    fix-permissions ${APP_ROOT} -P && \
    rpm-file-permissions
{% endmacro %}
