#!/bin/bash
#
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -ex

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MAKEFILE="${SCRIPT_DIR}/../Makefile"
readonly DOCKER_CPUS="${DOCKER_CPUS:=k8 aarch64 armv7a}"
PYTHON_VERSIONS="3.9 3.10 3.11 3.12"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean)
      make -f "${MAKEFILE}" clean
      shift
      ;;
    --python_versions)
      PYTHON_VERSIONS=$2
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

function docker_image {
  case $1 in
    3.9) echo "debian:bullseye";;
    3.10) echo "ubuntu:22.04";;
    3.11) echo "debian:bookworm";;
    3.12) echo "ubuntu:24.04";;
    *) echo "Unsupported python version: $1" 1>&2; exit 1 ;;
  esac
}

for python_version in ${PYTHON_VERSIONS}; do
  make DOCKER_TF_PYTHON_VERSION="${python_version}" \
       DOCKER_CPUS="${DOCKER_CPUS}" \
       DOCKER_IMAGE=$(docker_image "${python_version}") \
       DOCKER_TARGETS="pybind wheel" \
       -f "${MAKEFILE}" \
       docker-build
done
