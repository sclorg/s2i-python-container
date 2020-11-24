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
RUN python{{ spec.version }} -m venv ${APP_ROOT} && \
# We have to upgrade pip to a newer verison because: \
# * pip < 9 does not support different packages' versions for Python 2/3 \
# * pip < 19.3 does not support manylinux2014 wheels. Only manylinux2014 wheels \
#   support platforms like ppc64le, aarch64 or armv7 \
# We are newly using wheel from the latest stable Fedora release (RPM python-pip-wheel) \
# because it's tested better that whatever version from PyPI and contains useful patches. \
# We have to do it here so the permissions are correctly fixed pip is able \
# to reinstall itself in the next build phases and in the assemble script `
${APP_ROOT}/bin/pip install /opt/wheels/pip-* && rm -r /opt/wheels && \
chown -R 1001:0 ${APP_ROOT} && \
fix-permissions ${APP_ROOT} -P

# For Fedora scl_enable isn't sourced automatically in s2i-core
# so virtualenv needs to be activated this way
ENV BASH_ENV="${APP_ROOT}/bin/activate" \
    ENV="${APP_ROOT}/bin/activate" \
    PROMPT_COMMAND=". ${APP_ROOT}/bin/activate"
{% endmacro %}
