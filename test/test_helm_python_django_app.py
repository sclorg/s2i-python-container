import os

import pytest
from pathlib import Path

from container_ci_suite.helm import HelmChartsAPI

from constants import TAGS, BRANCH_TO_TEST, is_test_allowed
from conftest import VARS

test_dir = Path(os.path.abspath(os.path.dirname(__file__)))

TAG = TAGS.get(VARS.OS)
DEPLOYED_PSQL_IMAGE = "quay.io/sclorg/postgresql-10-c8s:c8s"
IMAGE_TAG = "postgresql:10"
PSQL_VERSION = "10"

if VARS.VERSION == "3.11" or VARS.VERSION == "3.12" or VARS.VERSION == "3.12-minimal":
    DEPLOYED_PSQL_IMAGE = "quay.io/sclorg/postgresql-12-c8s"
    IMAGE_TAG = "postgresql:12"
    PSQL_VERSION = "12"
    BRANCH_TO_TEST = "4.2.x"

class TestHelmPythonDjangoAppTemplate:

    def setup_method(self):
        package_name = "redhat-python-django-application"
        path = test_dir
        self.hc_api = HelmChartsAPI(path=path, package_name=package_name, tarball_dir=test_dir, shared_cluster=True)
        self.hc_api.clone_helm_chart_repo(
            repo_url="https://github.com/sclorg/helm-charts", repo_name="helm-charts",
            subdir="charts/redhat"
        )

    def teardown_method(self):
        self.hc_api.delete_project()

    def test_django_application_helm_test(self):
        if not is_test_allowed(os=VARS.OS, version=VARS.VERSION):
            pytest.skip(f"This combination for {VARS.OS} and {VARS.VERSION} is not supported for Helm Charts.")
        self.hc_api.package_name = "redhat-python-imagestreams"
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation()
        self.hc_api.package_name = "redhat-python-django-application"
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation(
            values={
                "python_version": f"{VARS.VERSION}{TAG}",
                "namespace": self.hc_api.namespace,
                "source_repository_ref": BRANCH_TO_TEST,
            }
        )
        assert self.hc_api.is_s2i_pod_running(pod_name_prefix="django-example")
        assert self.hc_api.test_helm_chart(expected_str=["Welcome to your Django application"])
