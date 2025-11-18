import re

import pytest

from container_ci_suite.container_lib import ContainerTestLib
from container_ci_suite.engines.podman_wrapper import PodmanCLIWrapper
from container_ci_suite.utils import ContainerTestLibUtils

from conftest import VARS


class TestS2IPythonContainer:
    """
    Test if container works properly
    """

    def setup_method(self):
        """
        Setup the test environment.
        """
        self.app = ContainerTestLib()

    def teardown_method(self):
        """
        Cleanup the test environment.
        """
        self.app.cleanup()

    def test_run_s2i_usage(self):
        """
        Test if s2i usage works
        """
        assert self.app.s2i_usage()

    def test_docker_run_usage(self):
        """
        Test if container is runnable
        """
        assert (
            PodmanCLIWrapper.call_podman_command(
                cmd=f"run --rm {VARS.IMAGE_NAME} &>/dev/null", return_output=False
            )
            == 0
        )

    def test_scl_usage(self):
        """
        Test if python --version returns proper output
        """
        python_version = PodmanCLIWrapper.podman_run_command_and_remove(
            cid_file_name=VARS.IMAGE_NAME, cmd="echo \\$PYTHON_VERSION"
        ).strip()
        python_version_output = PodmanCLIWrapper.podman_run_command_and_remove(
            cid_file_name=VARS.IMAGE_NAME, cmd="python --version"
        )
        assert f"Python {python_version}." in python_version_output
        if not VARS.IS_MINIMAL:
            assert (
                re.search(
                    r"v[0-9]*\.[0-9]*\.[0-9]*",
                    PodmanCLIWrapper.podman_run_command_and_remove(
                        cid_file_name=VARS.IMAGE_NAME, cmd="node --version"
                    ),
                )
                is not None
            )
            assert (
                re.search(
                    r"^[0-9]*\.[0-9]*\.[0-9]*",
                    PodmanCLIWrapper.podman_run_command_and_remove(
                        cid_file_name=VARS.IMAGE_NAME, cmd="npm --version"
                    ),
                )
                is not None
            )

    @pytest.mark.parametrize("dockerfile", ["Dockerfile.tpl", "Dockerfile_no_s2i.tpl"])
    def test_dockerfiles(self, dockerfile):
        if "minimal" in VARS.VERSION:
            pytest.skip("Skipping tests 'test_dockerfiles' for minimal versions.")
        assert self.app.build_test_container(
            dockerfile=VARS.TEST_DIR / "from-dockerfile" / dockerfile,
            app_url="https://github.com/sclorg/django-ex.git@4.2.x",
            app_dir="app-src",
        )
        assert self.app.test_app_dockerfile()
        cip = self.app.get_cip()
        assert cip
        assert self.app.test_response(
            url=cip, expected_output="Welcome to your Django application on OpenShift"
        )

    def test_minimal_dockerfiles(self):
        if "minimal" not in VARS.VERSION:
            pytest.skip(
                "Skipping tests 'test_minimal_dockerfiles' for non-minimal versions."
            )
        # The following tests are for multi-stage builds. These technically also work on full images, but there is no reason to do multi-stage builds with full images.
        assert self.app.build_test_container(
            dockerfile=VARS.TEST_DIR / "from-dockerfile/uwsgi.Dockerfile.tpl",
            app_url=VARS.TEST_DIR / "uwsgi-test-app",
            app_dir="app-src",
            app_image_name="uwsgi-test-app",
        )
        assert self.app.test_app_dockerfile()
        cip = self.app.get_cip(cid_file_name="uwsgi-test-app")
        assert cip
        assert self.app.test_response(
            url=cip,
            expected_output="Hello World from uWSGI hosted WSGI application!",
        )

        # So far, for all the minimal images, the name of the full container image counterpart
        # is the same just without -minimal infix.
        # sclorg/python-39-minimal-c9s / sclorg/python-39-c9s
        # ubi8/python-39-minimal / ubi8/python-39
        full_image_name = VARS.IMAGE_NAME.replace("-minimal", "")
        is_pulled = PodmanCLIWrapper.podman_pull_image(
            image_name=full_image_name, loops=1
        )
        print(f"Is image {full_image_name} pulled? {is_pulled}")
        if is_pulled:
            dockerfile_image_name = ContainerTestLibUtils.update_dockerfile(
                dockerfile=VARS.TEST_DIR / "from-dockerfile/mod_wsgi.Dockerfile.tpl",
                original_string="#IMAGE_NAME#",
                string_to_replace=VARS.IMAGE_NAME,
            )
            dockerfile = ContainerTestLibUtils.update_dockerfile(
                dockerfile=dockerfile_image_name,
                original_string="#FULL_IMAGE_NAME#",
                string_to_replace=full_image_name,
            )
            assert self.app.build_test_container(
                dockerfile=dockerfile,
                app_url=VARS.TEST_DIR / "micropipenv-requirements-test-app",
                app_dir="app-src",
                app_image_name="micropipenv-requirements-test-app",
            )
            assert self.app.test_app_dockerfile()
            cip = self.app.get_cip(cid_file_name="micropipenv-requirements-test-app")
            assert cip
            assert self.app.test_response(
                url=cip,
                expected_output="Hello World from mod_wsgi hosted WSGI application!",
                debug=True,
            )
