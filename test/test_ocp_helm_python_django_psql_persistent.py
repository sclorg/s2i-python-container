from container_ci_suite.helm import HelmChartsAPI

from conftest import skip_helm_charts_tests, VARS


class TestHelmPythonDjangoPsqlTemplate:
    def setup_method(self):
        package_name = "redhat-django-psql-persistent"
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

    def test_django_psql_helm_test(self):
        skip_helm_charts_tests()
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
                "python_version": f"{VARS.VERSION}{VARS.TAG}",
                "namespace": self.hc_api.namespace,
                "source_repository_ref": VARS.BRANCH_TO_TEST,
            }
        )
        assert self.hc_api.is_s2i_pod_running(pod_name_prefix="django-psql")
        assert self.hc_api.test_helm_chart(
            expected_str=["Welcome to your Django application"]
        )
