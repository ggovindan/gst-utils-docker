LIBPYTHONPATH=""
PYTHON=${PYTHON:-/usr/bin/python3}
GST_VERSION=${GST_VERSION:-$(gst-launch-1.0 --version | grep version | tr -s ' ' '\n' | tail -1)}

# Ensure pygst to be installed in current environment
LIBPYTHON=$($PYTHON -c 'from distutils import sysconfig; print(sysconfig.get_config_var("LDLIBRARY"))')
LIBPYTHONPATH=$(dirname $(ldconfig -p | grep -w $LIBPYTHON | head -1 | tr ' ' '\n' | grep /))

GST_PREFIX=${GST_PREFIX:-$(dirname $(dirname $(which python)))}

echo "Python Executable: $PYTHON"
echo "Python Library Path: $LIBPYTHONPATH"
echo "Current Python Path $GST_PREFIX"
echo "Gstreamer Version: $GST_VERSION"

branch_is_in_remote() {
    local branch=$GST_VERSION
    local existed_in_remote=$(git ls-remote --heads origin ${branch})

    if [ -z ${existed_in_remote} ]; then
        echo "${branch} does not exist in gst-python changing to 1.18"
        GST_VERSION="1.18"
    else
        echo "${existed_in_remote} exists in gst-python"
    fi
}



TEMP_DIR="temp"
mkdir $TEMP_DIR
cd $TEMP_DIR

# Build gst-python
git clone https://github.com/GStreamer/gst-python.git
cd gst-python
branch_is_in_remote
export PYTHON=$PYTHON
git checkout $GST_VERSION

# gst-python has moved to meson build
meson builddir && cd builddir
meson compile
meson test
meson install

