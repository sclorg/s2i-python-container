{% macro env_metadata() %}
ENV NAME=python3 \
    VERSION=0 \
    ARCH=x86_64

{% endmacro %}

{% macro labels(spec) %}
      com.redhat.component="$NAME" \
      name="$FGC/$NAME" \
      version="$VERSION" \
      usage="s2i build https://github.com/sclorg/s2i-python-container.git --context-dir={{
          spec.version }}/test/setup-test-app/ $FGC/$NAME python-sample-app" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"
{% endmacro %}

{% macro permissions_setup(spec) %}
{% if spec.fedora_version == '28' %}
RUN virtualenv-$PYTHON_VERSION ${APP_ROOT} && \
{% else %}
RUN virtualenv ${APP_ROOT} && \
{% endif %}
    chown -R 1001:0 ${APP_ROOT} && \
    fix-permissions ${APP_ROOT} -P

# For Fedora scl_enable isn't sourced automatically in s2i-core
# so virtualenv needs to be activated this way
ENV BASH_ENV="${APP_ROOT}/bin/activate" \
    ENV="${APP_ROOT}/bin/activate" \
    PROMPT_COMMAND=". ${APP_ROOT}/bin/activate"
{% endmacro %}
