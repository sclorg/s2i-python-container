import os

import pytest
from pathlib import Path

from container_ci_suite.helm import HelmChartsAPI

test_dir = Path(os.path.abspath(os.path.dirname(__file__)))


class TestHelmRHELPythonImageStreams:

    def setup_method(self):
        package_name = "redhat-python-imagestreams"
        path = test_dir
        self.hc_api = HelmChartsAPI(path=path, package_name=package_name, tarball_dir=test_dir, shared_cluster=True)
        self.hc_api.clone_helm_chart_repo(
            repo_url="https://github.com/sclorg/helm-charts", repo_name="helm-charts",
            subdir="charts/redhat"
        )

    def teardown_method(self):
        self.hc_api.delete_project()

    @pytest.mark.parametrize(
        "version,registry",
        [
            ("3.12-ubi9", "registry.redhat.io/ubi9/python-312:latest"),
            ("3.12-ubi8", "registry.redhat.io/ubi8/python-312:latest"),
            ("3.11-ubi9", "registry.redhat.io/ubi9/python-311:latest"),
            ("3.11-ubi8", "registry.redhat.io/ubi8/python-311:latest"),
            ("3.9-ubi9", "registry.redhat.io/ubi9/python-39:latest"),
            ("3.9-ubi8", "registry.redhat.io/ubi8/python-39:latest"),
            ("3.6-ubi8", "registry.redhat.io/ubi8/python-36:latest"),
        ],
    )
    def test_package_imagestream(self, version, registry):
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation()
        assert self.hc_api.check_imagestreams(version=version, registry=registry)
