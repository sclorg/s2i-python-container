{% macro list_pkgs(pkgs) %}
{% for n in range(0, pkgs|length, 5) %}
{% if not loop.first %}        {% endif %}{{ ' '.join(pkgs[n:n+5]) }}{% if loop.last %}" &&{% endif %} \
{% endfor %}
{% endmacro %}

{% macro enablerepo(spec) %}
{% if spec.enablerepo %} {{ spec.enablerepo }}{% endif %}
{% endmacro %}

{% macro preinstall_cmd(spec) %}
{% for cmd in spec.preinstall_cmd %}
    {{ cmd }} && \
{% endfor %}
{% endmacro %}

