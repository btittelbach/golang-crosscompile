#!/bin/zsh
# Copyright 2013 Bernhard Tittelbach. All rights reserved.
# based on crosscompile.bash by davecheney
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# support functions for go cross compilation

GOPLATFORMS=(darwin/386 darwin/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm windows/386 windows/amd64)

eval "$(go env)"

function cgo-enabled {
	if [ "$1" = "${GOHOSTOS}" ]; then
		if [ "${GOHOSTOS}" != "freebsd/arm" ]; then
			echo 1
		else
			# cgo is not freebsd/arm
			echo 0	
		fi
	else 
		echo 0
	fi
}

function go-alias {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	eval "function go-${GOOS}-${GOARCH} { (CGO_ENABLED=$(cgo-enabled ${GOOS} ${GOARCH}) GOOS=${GOOS} GOARCH=${GOARCH} go \$@ ) }"
}

function go-crosscompile-build {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	cd ${GOROOT}/src ; CGO_ENABLED=$(cgo-enabled ${GOOS} ${GOARCH}) GOOS=${GOOS} GOARCH=${GOARCH} ./make.bash --no-clean 2>&1
}

function go-crosscompile-build-all {
	for GOPLATFORM in $GOPLATFORMS; do
		CMD="go-crosscompile-build ${GOPLATFORM}"
		echo "$CMD"
		$CMD >/dev/null
	done
}	

function go-all {
	for GOPLATFORM in $GOPLATFORMS; do
		GOOS=${GOPLATFORM%/*}
		GOARCH=${GOPLATFORM#*/}
		CMD="go-${GOOS}-${GOARCH} $@"
		echo "$CMD"
		$CMD
	done
}

for GOPLATFORM in $GOPLATFORMS; do
	go-alias $GOPLATFORM
done

unset GOPLATFORM
unset -f go-alias
