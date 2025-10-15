from container_ci_suite.helm import HelmChartsAPI

from conftest import skip_helm_charts_tests, VARS

DEPLOYED_PSQL_IMAGE = "quay.io/sclorg/postgresql-10-c8s:c8s"
IMAGE_TAG = "postgresql:10"
PSQL_VERSION = "10"
BRANCH_TO_TEST = "2.2.x"

if VARS.VERSION in ("3.11", "3.12", "3.12-minimal"):
    DEPLOYED_PSQL_IMAGE = "quay.io/sclorg/postgresql-12-c8s"
    IMAGE_TAG = "postgresql:12"
    PSQL_VERSION = "12"
    BRANCH_TO_TEST = "4.2.x"

class TestHelmPythonDjangoAppTemplate:

    def setup_method(self):
        package_name = "redhat-python-django-application"
        self.hc_api = HelmChartsAPI(path=VARS.TEST_DIR, package_name=package_name, tarball_dir=VARS.TEST_DIR, shared_cluster=True)
        self.hc_api.clone_helm_chart_repo(
            repo_url="https://github.com/sclorg/helm-charts", repo_name="helm-charts",
            subdir="charts/redhat"
        )

    def teardown_method(self):
        self.hc_api.delete_project()

    def test_django_application_helm_test(self):
        skip_helm_charts_tests()
        self.hc_api.package_name = "redhat-python-imagestreams"
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation()
        self.hc_api.package_name = "redhat-python-django-application"
        assert self.hc_api.helm_package()
        assert self.hc_api.helm_installation(
            values={
                "python_version": f"{VARS.VERSION}{VARS.TAG}",
                "namespace": self.hc_api.namespace,
                "source_repository_ref": BRANCH_TO_TEST,
            }
        )
        assert self.hc_api.is_s2i_pod_running(pod_name_prefix="django-example")
        assert self.hc_api.test_helm_chart(expected_str=["Welcome to your Django application"])
