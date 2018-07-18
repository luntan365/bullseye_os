.PHONY: all musl

musl:
	rm -f build_musl/Makefile
	mkdir -p build_musl
	cd build_musl && ../musl-1.1.19/configure --target=$(ARCH) --prefix=.
	$(MAKE) -C build_musl