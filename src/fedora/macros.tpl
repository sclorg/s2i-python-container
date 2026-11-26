{% macro env_metadata() %}
ENV NAME=python3 \
    ARCH=x86_64

{% endmacro %}

{% macro labels(spec) %}
      com.redhat.component="$NAME" \
      name="fedora/$NAME-{{ spec.short_ver }}" \
      usage="s2i build https://github.com/sclorg/s2i-python-container.git --context-dir={{
          spec.version }}/test/setup-test-app/ quay.io/fedora/$NAME-{{ spec.short_ver }} python-sample-app" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"
{% endmacro %}

{% macro venv_setup(spec) %}
RUN python{{ spec.version }} -m venv ${APP_ROOT} && \
chown -R 1001:0 ${APP_ROOT} && \
fix-permissions ${APP_ROOT} -P && \
# The following echo adds the unset command for the variables set below to the \
# venv activation script. This prevents the virtual environment from being \
# activated multiple times and also every time the prompt is rendered. \
echo "unset BASH_ENV PROMPT_COMMAND ENV" >> ${APP_ROOT}/bin/activate
# Ensure the virtualenv is activated in interactive shells
ENV BASH_ENV="${APP_ROOT}/bin/activate" \
    ENV="${APP_ROOT}/bin/activate" \
    PROMPT_COMMAND=". ${APP_ROOT}/bin/activate"
{% endmacro %}
