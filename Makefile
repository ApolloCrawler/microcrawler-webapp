.PHONY: list

OS := $(shell uname)
ifeq ($(OS),Darwin)
	# Mac specific
	LINKER_TOOL = otool -L
	CARGO_BUILD_DEBUG   = cargo rustc -- --codegen link-args='-flat_namespace -undefined suppress'
	CARGO_BUILD_RELEASE = cargo rustc -- --codegen link-args='-flat_namespace -undefined suppress'
else
	# Linux specific
	LINKER_TOOL = ldd
	CARGO_BUILD_DEBUG   = cargo build
	CARGO_BUILD_RELEASE = cargo build --release
endif

all: build

install_deps:
		cargo install cargo-count
		cargo install cargo-graph
		cargo install cargo-multi
		cargo install cargo-outdated

build: build-debug build-release

build-debug:
		cd native/gauc && ${CARGO_BUILD_DEBUG}

build-release:
		cd native/gauc && ${CARGO_BUILD_RELEASE}

clean: clean-debug clean-release

clean-debug:
		cargo clean

clean-release:
		cargo clean --release

deps: deps-debug deps-release

deps-debug: build-debug
		${LINKER_TOOL} ./native/target/debug/libgauc.dylib

deps-release: build-release
		${LINKER_TOOL} ./native/target/release/libgauc.dylib

dot:
		cargo graph \
			--optional-line-style dashed \
			--optional-line-color red \
			--optional-shape box \
			--build-shape diamond \
			--build-color green \
			--build-line-color orange \
			> doc/deps/cargo-count.dot

		dot -Tpng > doc/deps/rainbow-graph.png doc/deps/cargo-count.dot

list:
		@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

outdated:
		cargo outdated

rebuild: rebuild-debug rebuild-release

rebuild-debug: clean-debug build-debug

rebuild-release: clean-release build-release

size-debug:
		ls -lah ./native/target/debug/libgauc.dylib

size-release:
		ls -lah ./native/target/release/libgauc.dylib

size: size-debug size-release

stats:
		cargo count --separator , --unsafe-statistics

strip:
		strip ./native/target/release/libgauc.dylib

test:
		cargo test

update:
		cargo multi update

# upx: ./target/release/gooddata-fs
#		upx -fq --ultra-brute --best -o ./bin/gooddata-fs ./target/release/gooddata-fs

watch:
		cargo watch
