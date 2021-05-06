#!/usr/bin/env bash
set -x
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)

arg1="${1-}"

achitecture="${HOSTTYPE}"
platform="unknown"
case "${OSTYPE}" in
  msys)
    echo "Platform is Windows."
    platform="windows"
    # No installer for Windows
    ;;
  darwin*)
    echo "Platform is Mac OS X."
    platform="darwin"
    ;;
  linux*)
    echo "Platform is Linux (or WSL)."
    platform="linux"
    ;;
  *)
    echo "Unrecognized platform."
    exit 1
esac

# Sanity check: Verify we have symlinks where we expect them, or Bazel can produce weird "missing input file" errors.
# This is most likely to occur on Windows, where symlinks are sometimes disabled by default.
{ git ls-files -s 2>/dev/null || true; } | (
  set +x
  missing_symlinks=()
  while read -r mode _ _ path; do
    if [ "${mode}" = 120000 ]; then
      test -L "${path}" || missing_symlinks+=("${path}")
    fi
  done
  if [ ! 0 -eq "${#missing_symlinks[@]}" ]; then
    echo "error: expected symlink: ${missing_symlinks[*]}" 1>&2
    echo "For a correct build, please run 'git config --local core.symlinks true' and re-run git checkout." 1>&2
    false
  fi
)

export PATH=/opt/python3/cp36-cp36m/bin:$PATH
#"$("${python}" -s -c "import runpy, sys; runpy.run_path(sys.argv.pop(), run_name='__api__')" bazel_version "${ROOT_DIR}/../../python/setup.py")"
mkdir -p ~/bin
wget https://github.com/bazelbuild/bazel/releases/download/3.7.2/bazel-3.7.2-linux-arm64 -o ~/bin/bazel
chmod u+x ~/bin/bazel
echo "PATH=\$HOME/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc
