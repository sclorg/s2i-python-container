import pytest

from container_ci_suite.helm import HelmChartsAPI

from conftest import VARS


class TestHelmRHELPythonImageStreams:
    def setup_method(self):
        package_name = "redhat-python-imagestreams"
        self.hc_api = HelmChartsAPI(
            path=VARS.TEST_DIR,
            package_name=package_name,
            tarball_dir=VARS.TEST_DIR,
            shared_cluster=True,
        )
        self.hc_api.clone_helm_chart_repo(
            repo_url="https://github.com/sclorg/helm-charts",
            repo_name="helm-charts",
            subdir="charts/redhat",
        )

    def teardown_method(self):
        self.hc_api.delete_project()

    @pytest.mark.parametrize(
        "version,registry,expected",
        [
            (
                "3.12-minimal-ubi10",
                "registry.redhat.io/ubi10/python-312-minimal:latest",
                True,
            ),
            ("3.12-ubi9", "registry.redhat.io/ubi9/python-312:latest", True),
            ("3.12-ubi8", "registry.redhat.io/ubi8/python-312:latest", True),
            ("3.11-ubi9", "registry.redhat.io/ubi9/python-311:latest", True),
            ("3.11-ubi8", "registry.redhat.io/ubi8/python-311:latest", True),
            ("3.9-ubi9", "registry.redhat.io/ubi9/python-39:latest", True),
            ("3.9-ubi8", "registry.redhat.io/ubi8/python-39:latest", False),
            ("3.6-ubi8", "registry.redhat.io/ubi8/python-36:latest", True),
        ],
    )
    def test_package_imagestream(self, version, registry, expected):
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation()
        assert (
            self.hc_api.check_imagestreams(version=version, registry=registry)
            == expected
        )
