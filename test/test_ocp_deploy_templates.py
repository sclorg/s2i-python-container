import pytest

from container_ci_suite.openshift import OpenShiftAPI

from conftest import VARS


class TestDeployTemplate:
    def setup_method(self):
        self.oc_api = OpenShiftAPI(
            pod_name_prefix=f"python-{VARS.SHORT_VERSION}-test",
            version=VARS.VERSION_NO_MINIMAL,
            shared_cluster=True,
        )

    def teardown_method(self):
        self.oc_api.delete_project()

    @pytest.mark.parametrize(
        "template", ["django-postgresql.json", "django-postgresql-persistent.json"]
    )
    def test_python_template_inside_cluster(self, template):
        assert self.oc_api.upload_image(VARS.DEPLOYED_PSQL_IMAGE, VARS.IMAGE_TAG)
        service_name = f"python-{VARS.SHORT_VERSION}-test"
        template_url = self.oc_api.get_raw_url_for_json(
            container="django-ex",
            dir="openshift/templates",
            filename=template,
            branch=VARS.BRANCH_TO_TEST,
        )
        assert self.oc_api.deploy_template_with_image(
            image_name=VARS.IMAGE_NAME,
            template=template_url,
            name_in_template="python",
            openshift_args=[
                f"SOURCE_REPOSITORY_REF={VARS.BRANCH_TO_TEST}",
                f"PYTHON_VERSION={VARS.VERSION_NO_MINIMAL}",
                f"NAME={service_name}",
                f"POSTGRESQL_VERSION={VARS.PSQL_VERSION}",
            ],
        )
        assert self.oc_api.is_template_deployed(name_in_template=service_name)
        assert self.oc_api.check_response_inside_cluster(
            name_in_template=service_name,
            expected_output="Welcome to your Django application on OpenShift",
        )
