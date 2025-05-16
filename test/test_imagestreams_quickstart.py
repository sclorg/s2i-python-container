import os
import sys

import pytest
from packaging.version import Version

from container_ci_suite.openshift import OpenShiftAPI
from container_ci_suite.utils import check_variables

from constants import TAGS, BRANCH_TO_TEST

if not check_variables():
    print("At least one variable from IMAGE_NAME, OS, VERSION is missing.")
    sys.exit(1)


VERSION = os.getenv("VERSION")
IMAGE_NAME = os.getenv("IMAGE_NAME")
OS = os.getenv("TARGET").lower()

DEPLOYED_PSQL_IMAGE = "quay.io/centos7/postgresql-10-centos7:centos7"
IMAGE_TAG = "postgresql:10"
PSQL_VERSION = "10"

if Version(VERSION) >= Version("3.11"):
    BRANCH_TO_TEST = "4.2.x"
    DEPLOYED_PSQL_IMAGE = "quay.io/sclorg/postgresql-12-c8s"
    IMAGE_TAG = "postgresql:12"
    PSQL_VERSION = "12"

TAG = TAGS.get(OS, None)

SHORT_VERSION = VERSION.replace(".", "")


# Replacement with 'test_python_s2i_templates'
class TestImagestreamsQuickstart:

    def setup_method(self):
        self.oc_api = OpenShiftAPI(pod_name_prefix=f"python-{SHORT_VERSION}-test", version=VERSION, shared_cluster=True)

    def teardown_method(self):
        self.oc_api.delete_project()

    @pytest.mark.parametrize(
        "template",
        [
            "django.json",
            "django-postgresql-persistent.json"
        ]
    )
    def test_python_template_inside_cluster(self, template):
        if OS == "rhel10":
            pytest.skip("Do not test on RHEL10. Imagestreams are not ready yet.")
        if self.oc_api.shared_cluster:
            assert self.oc_api.upload_image_to_external_registry(DEPLOYED_PSQL_IMAGE, IMAGE_TAG)
        else:
            assert self.oc_api.upload_image(DEPLOYED_PSQL_IMAGE, IMAGE_TAG)
        service_name = f"python-{SHORT_VERSION}-test"
        template_url = self.oc_api.get_raw_url_for_json(
            container="django-ex", dir="openshift/templates", filename=template, branch=BRANCH_TO_TEST
        )
        openshift_args = [
            f"SOURCE_REPOSITORY_REF={BRANCH_TO_TEST}",
            f"PYTHON_VERSION={VERSION}",
            f"NAME={service_name}"
        ]
        if template != "django.json":
            openshift_args = [
                f"SOURCE_REPOSITORY_REF={BRANCH_TO_TEST}",
                f"POSTGRESQL_VERSION={PSQL_VERSION}",
                f"PYTHON_VERSION={VERSION}",
                f"NAME={service_name}",
                f"DATABASE_USER=testu",
                f"DATABASE_PASSWORD=testp"
            ]
        assert self.oc_api.imagestream_quickstart(
            imagestream_file="imagestreams/python-rhel.json",
            template_file=template_url,
            image_name=IMAGE_NAME,
            name_in_template="python",
            openshift_args=openshift_args
        )
        assert self.oc_api.is_template_deployed(name_in_template=service_name)
        assert self.oc_api.check_response_inside_cluster(
            name_in_template=service_name, expected_output="Welcome to your Django application on OpenShift"
        )
