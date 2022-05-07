# PathWrangler

[![GitHub release](https://img.shields.io/github/release/sersoft-gmbh/path-wrangler.svg?style=flat)](https://github.com/sersoft-gmbh/path-wrangler/releases/latest)
![Tests](https://github.com/sersoft-gmbh/path-wrangler/workflows/Tests/badge.svg)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/2c8e4e87ed7c4b9b9be446aa2e14b787)](https://www.codacy.com/gh/sersoft-gmbh/path-wrangler?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sersoft-gmbh/path-wrangler&amp;utm_campaign=Badge_Grade)
[![codecov](https://codecov.io/gh/sersoft-gmbh/path-wrangler/branch/master/graph/badge.svg)](https://codecov.io/gh/sersoft-gmbh/path-wrangler)
[![Docs](https://img.shields.io/badge/-documentation-informational)](https://sersoft-gmbh.github.io/path-wrangler)

A simple path library written in Swift.

## Installation

Add the following package dependency in your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/path-wrangler.git", from: "2.0.0"),
```

Or add it via Xcode (as of Xcode 11).

## Usage

PathWrangler has two basic representations of a path: `AbsolutePath` and `RelativePath`. They have everything you need for simple yet great path computations.
A relative path (as the name suggests) is not bound to any root. It's relative to whatever absolute path you need it to be. 
Thus it can also be turned into an absolute path using `absolute(in:)`.
An absolute path on the other hand is a path that always starts at the root. 

Both paths know how to "resolve" (or "simplify") themselves. By doing so, they try to resolve and thus remove references of the current folder (`.`) and parent folder (`..`). 
Since absolute paths know where to start, they are even able to resolve symlinks. To do so, however, the path must exist on disk.
Both path implementations also have a `current` accessor that returns the current path.
For `AbsolutePath` this is the `cwd`. For `RelativePath` this is always just the relative path to the current directory, thus `.`.

Path components or a relative path can be appended to both paths. There is even a convenience API that allows path building that almost looks like the path representation:
```swift
let someSubDir = AbsolutePath.root / "folder1" / "folder2" // -> "/folder1/folder2"
```

A protocol named `PathComponentConvertible` is used to represent path components. A bunch of default conformances (like for `String`, `Int`, etc.) make working with it easy. 
But adding more conformances is also easy. Just implement the only requirement `pathComponent` and return the path component of the conforming type.
As of then, the type can be used wherever path components are used in PathWrangler (like with the nice `/` API mentioned before).

The PathWrangler package contains two products:

-   One is `CorePathWrangler` which contains all the underlying logic but has no dependency on Foundation whatsoever.
     It uses a few system APIs (like `getcwd` for determining the current working directory), but is otherwise mainly implemented in pure Swift using only stdlib types.
     It also depends on [Swift Algorithms](https://github.com/apple/swift-algorithms). 
-   The other one is `PathWrangler`  which adds a few neat APIs to `Foundation` types like `FileManager` or `URL` 
     that make interacting with `AbsolutePath` and `RelativePath` easier.

## Documentation

The API is documented using header doc. If you prefer to view the documentation as a webpage, t
here is an online version available for you:

-   [CorePathWrangler](https://sersoft-gmbh.github.io/path-wrangler/master/documentation/corepathwrangler)
-   [PathWrangler](https://sersoft-gmbh.github.io/path-wrangler/master/documentation/pathwrangler)

## Contributing

If you find a bug / like to see a new feature in PathWrangler there are a few ways of helping out:

-   If you can fix the bug / implement the feature yourself please do and open a PR.
-   If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
-   If you can do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.

## License

See [LICENSE](./LICENSE) file.
