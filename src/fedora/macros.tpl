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
