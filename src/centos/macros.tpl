{% macro env_metadata() %}{% endmacro %}

{% macro _version_selector(spec) %}
{% if spec.python_img_version %}{{ spec.python_img_version }}{% else %}{{ spec.version }}{% endif %}
{% endmacro %}

{% macro _prefix(spec) %}
{% if spec.version.startswith('3.') %}{{ spec.python3_component_prefix }}{% endif %}
{% endmacro %}

{% macro labels(spec) %}
      com.redhat.component="{{ _prefix(spec) }}python{{ spec.short_ver }}-container" \
      name="{{ spec.org }}/python-{{ spec.short_ver }}-{{ spec.prod }}" \
      version="{{ _version_selector(spec) }}" \
      usage="s2i build https://github.com/sclorg/s2i-python-container.git --context-dir={{spec.version }}/test/setup-test-app/ {{ spec.org }}/python-{{ spec.short_ver }}-{{ spec.prod }} python-sample-app" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"
{% endmacro %}

{% macro permissions_setup(spec) %}
RUN source scl_source enable {{ spec.scl }} && \
    virtualenv ${APP_ROOT} && \
    chown -R 1001:0 ${APP_ROOT} && \
    fix-permissions ${APP_ROOT} -P && \
    rpm-file-permissions
{% endmacro %}
