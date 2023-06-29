PROJECT_SOURCE_DIR ?= $(abspath ./)
PROJECT_NAME ?= $(shell basename $(PROJECT_SOURCE_DIR))

all:
	@echo nothing special

clean:
	rm -rf build dist wheelhouse *.egg-info
force_clean:
	docker run --rm -v `pwd`:`pwd` -w `pwd` -it alpine/make make clean
.PHONY: clean force_clean

build:
	mkdir -p build && cd build && \
	cmake .. && make
.PHONY: build

DOCKER_TAG_WINDOWS ?= ghcr.io/cubao/build-env-windows-x64:v0.0.1
DOCKER_TAG_LINUX ?= ghcr.io/cubao/build-env-manylinux2014-x64:v0.0.3
DOCKER_TAG_MACOS ?= ghcr.io/cubao/build-env-macos-arm64:v0.0.1
DOCKER_TAG_EMSDK ?= ghcr.io/cubao/build-env-emsdk:v0.0.1

test_in_win:
	docker run --rm -w `pwd` -v `pwd`:`pwd` -v `pwd`/build/win:`pwd`/build -it $(DOCKER_TAG_WINDOWS) bash
test_in_mac:
	docker run --rm -w `pwd` -v `pwd`:`pwd` -v `pwd`/build/mac:`pwd`/build -it $(DOCKER_TAG_MACOS) bash
test_in_linux:
	docker run --rm -w `pwd` -v `pwd`:`pwd` -v `pwd`/build/linux:`pwd`/build -it $(DOCKER_TAG_LINUX) bash
test_in_emsdk:
	docker run --rm -w `pwd` -v `pwd`:`pwd` -v `pwd`/build/emsdk:`pwd`/build -it $(DOCKER_TAG_EMSDK) bash

DEV_CONTAINER_NAME ?= $(USER)_$(subst /,_,$(PROJECT_NAME)____$(PROJECT_SOURCE_DIR))
DEV_CONTAINER_IMAG ?= $(DOCKER_TAG_LINUX)
test_in_dev_container:
	docker ps | grep $(DEV_CONTAINER_NAME) \
		&& docker exec -it $(DEV_CONTAINER_NAME) bash \
		|| docker run --rm --name $(DEV_CONTAINER_NAME) \
			--network host --security-opt seccomp=unconfined \
			-v `pwd`:`pwd` -w `pwd` -it $(DEV_CONTAINER_IMAG) bash

# https://stackoverflow.com/a/25817631
echo-%  : ; @echo -n $($*)
Echo-%  : ; @echo $($*)
ECHO-%  : ; @echo $* = $($*)
echo-Tab: ; @echo -n '    '
