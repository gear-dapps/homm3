.PHONY: all build clean fmt fmt-check init linter pre-commit test

all: init build full-test

clean:
	@echo ──────────── Clean ────────────────────────────
	@rm -rvf target

build:
	@echo ⚙️ Building a release...
	cargo +nightly b -r --workspace
	@ls -l target/wasm32-unknown-unknown/release/*.wasm

fmt:
	@echo ⚙️ Formatting...
	@cargo fmt --all

fmt-check:
	@echo ⚙️ Checking a format...
	@cargo fmt --all --check

pin-toolchain-mac-m1:
	@rustup toolchain install nightly-2023-04-21 --component llvm-tools-preview
	@rustup target add wasm32-unknown-unknown --toolchain nightly-2023-04-21
	@rm -rf ~/.rustup/toolchains/nightly-aarch64-apple-darwin
	@ln -s ~/.rustup/toolchains/nightly-2023-04-21-aarch64-apple-darwin ~/.rustup/toolchains/nightly-aarch64-apple-darwin

pin-toolchain-linux:
	@rustup toolchain install nightly-2023-04-21 --component llvm-tools-preview
	@rustup target add wasm32-unknown-unknown --toolchain nightly-2023-04-21
	@rm -rf ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu
	@ln -s ~/.rustup/toolchains/nightly-2023-04-21-x86_64-unknown-linux-gnu ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu
	@rustup component add clippy --toolchain nightly-x86_64-unknown-linux-gnu

init:
	@echo ⚙️ Installing a toolchain \& a target...
ifeq ($(shell uname -s),Linux)
	@echo Linux detected..
	make pin-toolchain-linux
else ifeq ($(shell uname -s),Darwin)
	@echo Macos detected..
	make pin-toolchain-mac-m1
endif

lint:
	@echo ⚙️ Running the linter...
	@cargo +nightly clippy -- -D warnings
	@cargo +nightly clippy \
	--all-targets \
	--workspace \
	-Fbinary-vendor \
	-- -D warnings

pre-commit: fmt lint full-test

test:
	@echo ⚙️ Running unit tests...
	@cargo +nightly t  -Fbinary-vendor --workspace

full-test:
	@echo ⚙️ Running all tests...
	@cargo +nightly t --release -Fbinary-vendor -- --include-ignored --test-threads=1
