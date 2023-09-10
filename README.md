# projector-launcher-mac-app

Projector launcher for Mac app


# Overview

A simple binary that can be used to wrap a projector and other resources within a single application bundle.

```
My Application.app/
	Contents/
		Info.plist
		MacOS/
			Application  <- Launcher (same name as projector)
		Resources/
			Application.app  <- Projector
			other.swf
```

# Compatibility

-  Intel versions compatible with macOS versions 10.5+.
-  ARM version compatible with macOS versions 11.0+ (first Apple Silicon OS).

To wrap FAT binaries use a FAT binary with the same set of architectures.

NOTE: The binaries are unsigned and arm64 binaries must be signed to run (an ad-hoc signature is the minimum).


# Building

1.  Install Xcode 3.1.4 in Mac OS X 10.5 Leopard.
2.  Run `./build-ppc-intel.sh` to build the PPC and Intel binaries.
3.  Install Command Line Tools for Xcode 12.5.1 on macOS 11.6.8 Big Sur.
4.  Run `./build-arm64.sh` to build the ARM (Apple Silicon) binary.
5.  Run `./hash.sh` to generate checksum files.


# Bugs

If you find a bug or have compatibility issues, please open a ticket under issues section for this repository.


# License

Copyright (c) 2020-2023 JrMasterModelBuilder

Licensed under the Mozilla Public License, v. 2.0.

If this license does not work for you, feel free to contact me.
