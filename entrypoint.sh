#!/usr/bin/env -S bash -l
# Adapted from https://github.com/rapidsai/docker/blob/main/context/entrypoint.sh

set -eo pipefail

cat << EOF
This container image and its contents are governed by the NVIDIA Deep Learning Container License.
By pulling and using the container, you accept the terms and conditions of this license:
https://developer.download.nvidia.com/licenses/NVIDIA_Deep_Learning_Container_License.pdf

EOF

conda activate

if [ -e "${HOME}/environment.yml" ]; then
    echo "environment.yml found. Installing packages."
    timeout "${CONDA_TIMEOUT:-600}" conda env update -n base -y -f "${HOME}/environment.yml" || exit $?
fi

if [ "$EXTRA_CONDA_PACKAGES" ]; then
    echo "EXTRA_CONDA_PACKAGES environment variable found. Installing packages."
    timeout "${CONDA_TIMEOUT:-600}" conda install -n base -y $EXTRA_CONDA_PACKAGES || exit $?
fi

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found. Installing packages."
    timeout "${PIP_TIMEOUT:-600}" pip install $EXTRA_PIP_PACKAGES || exit $?
fi

if [ "$(uname -m)" = "aarch64" ]; then
    if [[ "$CUDA_VERSION" = 12.9* ]]; then
        export NCCL_CUMEM_HOST_ENABLE=0
        echo "Set NCCL_CUMEM_HOST_ENABLE=0 for ARM with CUDA 12.9"
    fi
fi

if [ "${UNQUOTE}" = "true" ]; then
    # shellcheck disable=SC2068
    exec $@
else
    exec "$@"
fi
