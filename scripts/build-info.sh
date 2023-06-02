#!/bin/sh
pushd .git/modules/lib/upstream 1> /dev/null
../../../../lib/upstream/scripts/build-info.sh > \
	../../../../lib/include/build-info.h
popd 1> /dev/null
