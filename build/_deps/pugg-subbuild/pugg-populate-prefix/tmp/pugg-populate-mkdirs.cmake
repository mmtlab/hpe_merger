# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "C:/mirrorworld/HpeMerger/build/_deps/pugg-src"
  "C:/mirrorworld/HpeMerger/build/_deps/pugg-build"
  "C:/mirrorworld/HpeMerger/build/_deps/pugg-subbuild/pugg-populate-prefix"
  "C:/mirrorworld/HpeMerger/build/_deps/pugg-subbuild/pugg-populate-prefix/tmp"
  "C:/mirrorworld/HpeMerger/build/_deps/pugg-subbuild/pugg-populate-prefix/src/pugg-populate-stamp"
  "C:/mirrorworld/HpeMerger/build/_deps/pugg-subbuild/pugg-populate-prefix/src"
  "C:/mirrorworld/HpeMerger/build/_deps/pugg-subbuild/pugg-populate-prefix/src/pugg-populate-stamp"
)

set(configSubDirs Debug)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "C:/mirrorworld/HpeMerger/build/_deps/pugg-subbuild/pugg-populate-prefix/src/pugg-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "C:/mirrorworld/HpeMerger/build/_deps/pugg-subbuild/pugg-populate-prefix/src/pugg-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
