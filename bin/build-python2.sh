#!/usr/bin/env bash
# Set bash options
[ -n "$DEBUG" ] && set -x
set -eo pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
PYTHON_VERSION="${PYTHON_VERSION:-2.7.18}"
PYTHON_PIP_VERSION="${PYTHON_PIP_VERSION:-20.3.4}"
PYTHON_PIPENV_VERSION="${PYTHON_PIPENV_VERSION:-2020.11.4}"
PYTHON_VIRTUALENV_VERSION="${PYTHON_VIRTUALENV_VERSION:-20.13.2}"
PYTHON_SETUPTOOLS_VERSION="${PYTHON_SETUPTOOLS_VERSION:-38.4.0}"
PYTHON_GET_PIP_URL="${PYTHON_GET_PIP_URL:-https://bootstrap.pypa.io/pip/2.7/get-pip.py}"
#
echo "Compiling python $PYTHON_VERSION"
cd "/tmp" || exit 10
mkdir -p "/usr/local/bin" "/root/.config/pip"
wget -O python.tgz "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
tar xzf "python.tgz"
cd "Python-$PYTHON_VERSION"
./configure --enable-optimizations --enable-shared --enable-unicode=ucs4 --with-ensurepip
make altinstall
PYTHON2_BIN="$(command -v python2.7 || false)"
[ -n "$PYTHON2_BIN" ] || exit 10
echo "Python has been installed"
#
echo "Creating symlinks"
cd "/usr/local/bin" || exit 10
[ -f "$PYTHON2_BIN" ] && [ ! -f "/usr/local/bin/python" ] && ln -sf "$PYTHON2_BIN" "python"
[ -f "$PYTHON2_BIN" ] && [ ! -f "/usr/local/bin/python2" ] && ln -sf "$PYTHON2_BIN" "python2"
[ -f "/usr/local/bin/idle" ] && [ ! -f "/usr/local/bin/idle2" ] && ln -sf "/usr/local/bin/idle" "idle2"
#
echo "Installing pip"
cd "/tmp" || exit 10
echo "[global]" >/root/.config/pip/pip.conf
echo "no-cache-dir = false" >>/root/.config/pip/pip.conf
echo >>/root/.config/pip/pip.conf
wget -O get-pip.py "$PYTHON_GET_PIP_URL"
$PYTHON2_BIN get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION" "setuptools==$PYTHON_SETUPTOOLS_VERSION"
pip --version || exit 10
#
echo "Installing pip modules"
$PYTHON2_BIN -m pip install "virtualenv==$PYTHON_VIRTUALENV_VERSION" "pipenv==$PYTHON_PIPENV_VERSION" || exit 10
#
# Cleaning up
rm -f "get-pip.py" "python.tgz"
rm -Rf "/tmp/"*
