#import <Foundation/Foundation.h>

#include <limits.h>
#include <mach-o/dyld.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

const char errorGeneric[] = "Application not found.";
const char errorPath[] = "Application not found:";
const char errorExecutable[] = "Application executable failed to run:";
const char appExt[] = ".app";
const size_t appExtL = sizeof(appExt) - 1;
const char appInfo[] = "Info.plist";
const size_t appInfoL = sizeof(appInfo) - 1;
const char appContents[] = "Contents/";
const size_t appContentsL = sizeof(appContents) - 1;
const char appResources[] = "Resources/";
const size_t appResourcesL = sizeof(appResources) - 1;
const char appMacOS[] = "MacOS/";
const size_t appMacOSL = sizeof(appMacOS) - 1;

inline char * strAlloc(size_t len) {
	return (char *)malloc(sizeof(char) * (len + 1));
}

char * getSelfPath() {
	// First find out how large a buffer is needed.
	uint32_t size = 0;
	if (!_NSGetExecutablePath(NULL, &size) || !size) {
		return NULL;
	}

	// Create a buffer of that size and call it again.
	char * data = strAlloc(size);
	if (!data) {
		return NULL;
	}
	if (_NSGetExecutablePath(data, &size)) {
		free(data);
		return NULL;
	}

	// Resolve the real path (for 10.5 compatability, cannot pass NULL).
	// The Mac realpath will abort on any paths longer than PATH_MAX anyway.
	// A path longer than PATH_MAX is also hard to make in the first place.
	char * real = strAlloc(PATH_MAX);
	if (real) {
		realpath(data, real);
	}
	free(data);
	return real;
}

char * lastSlash(char * path) {
	char * slash = NULL;
	for (;; path++) {
		if (!*path) {
			return slash;
		}
		if (*path == '/') {
			slash = path;
		}
	}
}

char * resolveApp() {
	// Get path to self or fail.
	char * self = getSelfPath();
	if (!self) {
		return NULL;
	}

	// Cut name off path or fail.
	char * name = lastSlash(self);
	if (!name) {
		free(self);
		return NULL;
	}
	*(name++) = '\0';

	// Cut off last directory or fail.
	char * slash = lastSlash(self);
	if (!slash) {
		free(self);
		return NULL;
	}
	*slash = '\0';

	// Create memory for the full path or fail.
	size_t baseL = strlen(self);
	size_t nameL = strlen(name);
	char * path = strAlloc(baseL + 1 + appResourcesL + nameL + appExtL);
	if (!path) {
		free(self);
		return NULL;
	}

	// Assemble path.
	char * p = path;
	memcpy(p, self, baseL);
	p += baseL;
	*(p++) = '/';
	memcpy(p, appResources, appResourcesL);
	p += appResourcesL;
	memcpy(p, name, nameL);
	p += nameL;
	memcpy(p, appExt, appExtL + 1);

	free(self);
	return path;
}

char * resolveAppInfo(const char * app) {
	// Calculate app path length.
	size_t appL = strlen(app);

	// Create memory for full path or fail.
	char * path = strAlloc(appL + 1 + appContentsL + appInfoL);
	if (!path) {
		return NULL;
	}

	// Assemble path.
	char * p = path;
	memcpy(p, app, appL);
	p += appL;
	*(p++) = '/';
	memcpy(p, appContents, appContentsL);
	p += appContentsL;
	memcpy(p, appInfo, appInfoL + 1);

	return path;
}

char * readAppInfoExecutable(const char * path) {
	// Use Objective-C API to read plist (using an autorelease pool).
	char * r = NULL;
	NSAutoreleasePool * pool = [NSAutoreleasePool new];
	do {
		// Create path.
		NSString * p = [NSString stringWithUTF8String:path];
		if (!p) {
			break;
		}

		// Read dictionary.
		NSDictionary * d = [NSDictionary dictionaryWithContentsOfFile:p];
		if (!d) {
			break;
		}

		// Get dictionary executable value.
		NSString * be = [d objectForKey:@"CFBundleExecutable"];
		if (!be) {
			break;
		}

		// Return value as a C string.
		const char * executable = [be UTF8String];
		r = executable ? strdup(executable) : NULL;
	}
	while (0);
	[pool drain];
	return r;
}

char * resolveAppExecutable(const char * app) {
	// Get app info path or fail.
	char * info = resolveAppInfo(app);
	if (!info) {
		return NULL;
	}

	// Read the executable file or fail.
	char * executable = readAppInfoExecutable(info);
	free(info);
	if (!executable) {
		return NULL;
	}

	// Calculate path size and allocate memeory or fail.
	size_t appL = strlen(app);
	size_t executableL = strlen(executable);
	char * path = strAlloc(appL + 1 + appContentsL + appMacOSL + executableL);
	if (!path) {
		free(executable);
		return NULL;
	}

	// Assemble path.
	char * p = path;
	memcpy(p, app, appL);
	p += appL;
	*(p++) = '/';
	memcpy(p, appContents, appContentsL);
	p += appContentsL;
	memcpy(p, appMacOS, appMacOSL);
	p += appMacOSL;
	memcpy(p, executable, executableL + 1);

	free(executable);
	return path;
}

int main(int argc, char ** argv) {
	// Get path to app or fail.
	char * app = resolveApp();
	if (!app) {
		// Output a generic error.
		fprintf(stderr, "%s\n", errorGeneric);
		return 1;
	}

	// Resolve the app executable or fail.
	char * path = resolveAppExecutable(app);
	if (!path) {
		// Output error with the app path.
		fprintf(stderr, "%s %s\n", errorPath, app);
		free(app);
		return 1;
	}
	free(app);

	// Exec process or fail and continue past this.
	char ** args = (char **)malloc(sizeof(char *) * (argc + 1));
	if (args) {
		// Copy all the arguments, replacing first.
		memcpy(args, argv, sizeof(char *) * argc);
		args[0] = path;
		args[argc] = NULL;
		execv(path, args);
		free(args);
	}

	// Output error with the binary path.
	fprintf(stderr, "%s %s\n", errorExecutable, path);
	free(path);
	return 1;
}
