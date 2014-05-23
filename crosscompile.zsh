#!/bin/zsh
# Copyright 2013 Bernhard Tittelbach. All rights reserved.
# based on crosscompile.bash by davecheney and the Go Authors.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# support functions for go cross compilation

GOPLATFORMS=(darwin/386 darwin/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm windows/386 windows/amd64)
GOROOT=$(go env GOROOT)

function go-platform-available {
    local GOOS=$1
    local GOARCH=$2
    [[ -d ${GOROOT}/pkg/${GOOS}_${GOARCH} ]]
}

function go-alias {
	local GOOS=${1%/*}
	local GOARCH=${1#*/}
    go-platform-available $GOOS $GOARCH && \
        eval "function go-${GOOS}-${GOARCH} { ( GOOS=${GOOS} GOARCH=${GOARCH} go \$@ ) }"
}

function go-crosscompile-build {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	cd ${GOROOT}/src ; GOOS=${GOOS} GOARCH=${GOARCH} ./make.bash --no-clean 2>&1
}

function go-crosscompile-build-all {
	local GOFAILURES=""
	local GOOS GOARCH CMD GOPLATFORM
	for GOPLATFORM in $GOPLATFORMS; do
		CMD="go-crosscompile-build ${PLATFORM}"
		echo "$CMD"
		eval $CMD || GOFAILURES="$GOFAILURES $GOPLATFORM"
	done
	if [[ -n $GOFAILURES ]]; then
	    echo "*** go-crosscompile-build-all FAILED on $GOFAILURES ***"
	    return 1
	fi
}

function go-all {
	local GOFAILURES=""
	local GOOS GOARCH CMD GOPLATFORM
	for GOPLATFORM in $GOPLATFORMS; do
        GOOS=${GOPLATFORM%/*}
        GOARCH=${GOPLATFORM#*/}
        if go-platform-available $GOOS $GOARCH; then
            CMD="go-${GOOS}-${GOARCH} $@"
            echo "$CMD"
			eval $CMD || GOFAILURES="$GOFAILURES $GOPLATFORM"
        fi
	done
	if [[ -n $GOFAILURES ]]; then
	    echo "*** go-all FAILED on $GOFAILURES ***"
	    return 1
	fi
}

#can be called without arguments:
## go-build-all
#can be used with go build arguments like this:
## go-build-all -ldflags "-s" .
#or:
## go-build-all -ldflags "-s" main.go
function go-build-all {
	local GOFAILURES=""
	local GOOS GOARCH GOPLATFORM
    local LASTARG=${@[-1]}
	local OUTPUT="${${LASTARG:r}:-${PWD:t}}"
	for GOPLATFORM in $GOPLATFORMS; do
		GOOS=${GOPLATFORM%/*}
		GOARCH=${GOPLATFORM#*/}
		if go-platform-available $GOOS $GOARCH; then
			CMD="go-${GOOS}-${GOARCH} build -o "${OUTPUT}-${GOOS}-${GOARCH}" $@"
			echo "$CMD"
			eval $CMD || GOFAILURES="$GOFAILURES $GOPLATFORM"
		fi
	done
	if [[ -n $GOFAILURES ]]; then
	    echo "*** go-build-all FAILED on $GOFAILURES ***"
	    return 1
	fi
}

for GOPLATFORM in $GOPLATFORMS; do
	go-alias $GOPLATFORM
done

unset GOPLATFORM
unset -f go-alias
