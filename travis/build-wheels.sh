#!/bin/bash
set -e -u -x

function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/
    fi
}


# Install a system package required by our library
#yum install -y atlas-devel

# Compile wheels
/opt/python/cp36-cp36m/bin/pip install -r /io/dev-requirements.txt

ln -s /opt/python/cp36-cp36m/bin/cmake /usr/bin/cmake

/opt/python/cp36-cp36m/bin/pip wheel /io/ --no-deps -w wheelhouse/



# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    repair_wheel "$whl"
done

# Install packages and test

/opt/python/cp36-cp36m/bin/pip install python-manylinux-demo --no-index -f /io/wheelhouse
(cd "$HOME";  "/opt/python/cp36-cp36m/nosetests" pymanylinuxdemo)


