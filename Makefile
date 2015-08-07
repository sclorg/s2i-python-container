SKIP_SQUASH?=0
VERSIONS="2.7 3.3 3.4"

ifeq ($(TARGET),rhel7)
	OS := rhel7
else
	OS := centos7
endif

ifeq ($(VERSION), 2.7)
	VERSION := 2.7
else ifeq ($(VERSION), 3.3)
	VERSION := 3.3
else ifeq ($(VERSION), 3.4)
	VERSION := 3.4
else
	VERSION :=
endif

.PHONY: build
build:
	SKIP_SQUASH=$(SKIP_SQUASH) VERSIONS=$(VERSIONS) hack/build.sh $(OS) $(VERSION)

.PHONY: test
test:
	SKIP_SQUASH=$(SKIP_SQUASH) VERSIONS=$(VERSIONS) TAG_ON_SUCCESS=$(TAG_ON_SUCCESS) TEST_MODE=true hack/build.sh $(OS) $(VERSION)
