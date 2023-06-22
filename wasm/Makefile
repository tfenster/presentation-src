BINARY='../al/shimmer.wasm'
all: build

build:
	rm -f ${BINARY}
	GOOS=js GOARCH=wasm go build -o ${BINARY} ./cmd/shimmer

build-prod:
	rm ${BINARY}
	GOOS=js GOARCH=wasm go build -o ${BINARY} -ldflags "-s -w" ./cmd/shimmer
