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

To wrap FAT binaries use a FAT binary with the same architectures.

Compatible with Mac OS versions 10.5+.


# Building

1.  Install Xcode 3.1.4 in Mac OS X 10.5 Leopard.
2.  Run `./build.sh` to build the binaries.


# Bugs

If you find a bug or have compatibility issues, please open a ticket under issues section for this repository.


# License

Copyright (c) 2020 JrMasterModelBuilder

Licensed under the Mozilla Public License, v. 2.0.

If this license does not work for you, feel free to contact me.
