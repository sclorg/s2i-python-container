import os

import pytest
from pathlib import Path

from container_ci_suite.helm import HelmChartsAPI

from constants import TAGS, BRANCH_TO_TEST

test_dir = Path(os.path.abspath(os.path.dirname(__file__)))

VERSION = os.getenv("VERSION")
IMAGE_NAME = os.getenv("IMAGE_NAME")
OS = os.getenv("TARGET").lower()

TAG = TAGS.get(OS)
if VERSION == "3.11" or VERSION == "3.12":
    BRANCH_TO_TEST = "4.2.x"


class TestHelmPythonDjangoPsqlTemplate:

    def setup_method(self):
        package_name = "redhat-django-psql-persistent"
        path = test_dir
        self.hc_api = HelmChartsAPI(path=path, package_name=package_name, tarball_dir=test_dir, shared_cluster=True)
        self.hc_api.clone_helm_chart_repo(
            repo_url="https://github.com/sclorg/helm-charts", repo_name="helm-charts",
            subdir="charts/redhat"
        )

    def teardown_method(self):
        self.hc_api.delete_project()

    def test_django_psql_helm_test(self):
        if OS == "rhel10":
            pytest.skip("Do NOT test on rhel10. It is not released yet.")
        new_version = VERSION
        if "minimal" in VERSION:
            new_version = VERSION.replace("-minimal", "")
        self.hc_api.package_name = "redhat-postgresql-imagestreams"
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation()
        self.hc_api.package_name = "redhat-python-imagestreams"
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation()
        self.hc_api.package_name = "redhat-django-psql-persistent"
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation(
            values={
                "python_version": f"{new_version}{TAG}",
                "namespace": self.hc_api.namespace,
                "source_repository_ref": BRANCH_TO_TEST,
            }
        )
        assert self.hc_api.is_s2i_pod_running(pod_name_prefix="django-psql")
        assert self.hc_api.test_helm_chart(expected_str=["Welcome to your Django application"])
