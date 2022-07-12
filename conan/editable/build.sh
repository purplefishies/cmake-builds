#!/bin/bash

set -e
set -x

rm -rf say/build/
rm -rf hello/build/


ROOT=$(pwd)

conan editable add say/ say/0.1@user/channel

/bin/cp -f say/src/original_say.cpp say/src/say.cpp
pushd say
conan install . -s build_type=Release -if build/Release
conan install . -s build_type=Debug -if build/Debug
# pushd build/Release
# cmake ../..  -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../generators/conan_toolchain.cmake
# cmake --build . --config Release
pushd $ROOT/say/build/Debug
cmake ../..  -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../generators/conan_toolchain.cmake
cmake --build . --config Debug
popd
popd



# Hello

pushd hello
conan install . -s build_type=Debug -if build/Debug
pushd build/Debug
cmake ../..  -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../generators/conan_toolchain.cmake
cmake --build . --config Debug
./hello
popd
popd

echo "Modify !"

# Modification to code (Changes the message 'hello' with 'bye')
pushd say/build/Debug
/bin/cp -f ../../src/say2.cpp ../../src/say.cpp
touch ../../src/say.cpp
cmake --build .
popd

#

# build consumer again
pushd hello/build/Debug
cmake --build .
# This should print 'bye' instead of 'hello'
./hello
popd


conan editable remove say/0.1@user/channel

# Restore the say.cpp file to keep the repo unchanged
#cp say/src/original_say.cpp say/src/say.cpp
