# Copyright 2020 Google LLC
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
workspace(name = "pycoral")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# ==================================================================

# Add definition of tensorflow version 2.17.1 stable.
http_archive(
        name = "org_tensorflow",
        urls = [
            "https://github.com/tensorflow/tensorflow/archive/3c92ac03cab816044f7b18a86eb86aa01a294d95.tar.gz",
        ],
        sha256 = "317dd95c4830a408b14f3e802698eb68d70d81c7c7cfcd3d28b0ba023fe84a68",
        strip_prefix = "tensorflow-" + "3c92ac03cab816044f7b18a86eb86aa01a294d95",
        )

http_archive(
    name = "bazel_skylib",
    sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
    urls = [
        "https://storage.googleapis.com/mirror.tensorflow.org/github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
    ],
)

http_archive(
    name = "rules_python",
    sha256 = "9d04041ac92a0985e344235f5d946f71ac543f1b1565f2cdbc9a2aaee8adf55b",
    strip_prefix = "rules_python-0.26.0",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.26.0/rules_python-0.26.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

load("@rules_python//python:repositories.bzl", "python_register_toolchains")
load(
    "@org_tensorflow//tensorflow/tools/toolchains/python:python_repo.bzl",
    "python_repository",
)

python_repository(name = "python_version_repo")

load("@python_version_repo//:py_version.bzl", "HERMETIC_PYTHON_VERSION")

python_register_toolchains(
    name = "python",
    ignore_root_user_error = True,
    python_version = HERMETIC_PYTHON_VERSION,
)

load("@python//:defs.bzl", "interpreter")
load("@rules_python//python:pip.bzl", "package_annotation", "pip_parse")

NUMPY_ANNOTATIONS = {
    "numpy": package_annotation(
        additive_build_content = """\
filegroup(
    name = "includes",
    srcs = glob(["site-packages/numpy/core/include/**/*.h"]),
)
cc_library(
    name = "numpy_headers",
    hdrs = [":includes"],
    strip_include_prefix="site-packages/numpy/core/include/",
)
""",
    ),
}

pip_parse(
    name = "pypi",
    annotations = NUMPY_ANNOTATIONS,
    python_interpreter_target = interpreter,
    requirements = "@org_tensorflow//:requirements_lock_" + HERMETIC_PYTHON_VERSION.replace(".", "_") + ".txt",
)

load("@pypi//:requirements.bzl", "install_deps")

install_deps()

# ==================================================================

# Configure libedgetpu and downstream libraries (TF and Crosstool).
local_repository(
    name = "libedgetpu",
    path = "libedgetpu",
)

load("@libedgetpu//:workspace.bzl", "libedgetpu_dependencies")
libedgetpu_dependencies()

load("@org_tensorflow//tensorflow:workspace3.bzl", "tf_workspace3")
tf_workspace3()

load("@org_tensorflow//tensorflow:workspace2.bzl", "tf_workspace2")
tf_workspace2()

load("@org_tensorflow//tensorflow:workspace1.bzl", "tf_workspace1")
tf_workspace1()

load("@org_tensorflow//tensorflow:workspace0.bzl", "tf_workspace0")
tf_workspace0()

load("@coral_crosstool//:configure.bzl", "cc_crosstool")
cc_crosstool(name = "crosstool", cpp_version = "c++17")

http_archive(
    name = "com_google_glog",
    sha256 = "6fc352c434018b11ad312cd3b56be3597b4c6b88480f7bd4e18b3a3b2cf961aa",
    strip_prefix = "glog-3ba8976592274bc1f907c402ce22558011d6fc5e",
    urls = [
        "https://github.com/google/glog/archive/3ba8976592274bc1f907c402ce22558011d6fc5e.tar.gz",
    ],
    build_file_content = """
licenses(['notice'])
exports_files(['CMakeLists.txt'])
load(':bazel/glog.bzl', 'glog_library')
glog_library(with_gflags=0)
""",
)

local_repository(
    name = "libcoral",
    path = "libcoral",
)

new_local_repository(
    name = "glog",
    path = "libcoral/third_party/glog",
    build_file = "libcoral/third_party/glog/BUILD",
)

load("@org_tensorflow//third_party/py:python_configure.bzl", "python_configure")
python_configure(name = "local_config_python")
