#!/bin/sh

set -ex

mkdir zsh-build
cd zsh-build

curl -L https://api.github.com/repos/zsh-users/zsh/tarball/zsh-$TEST_ZSH_VERSION | tar xz --strip=1

./Util/preconfig
./configure --enable-pcre \
            --enable-cap \
            --enable-multibyte \
            --with-term-lib='ncursesw tinfo' \
            --with-tcsetpgrp

make install.bin
make install.modules
make install.fns

cd ..

rm -rf zsh-build
