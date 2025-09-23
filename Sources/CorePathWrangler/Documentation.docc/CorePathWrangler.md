# ``CorePathWrangler``

A simple path library written in Swift.

## Installation

Add the following package dependency in your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/path-wrangler", from: "2.0.0"),
```

Or add it via Xcode (as of Xcode 11).

## Usage

PathWrangler has two basic representations of a path: ``AbsolutePath`` and ``RelativePath``. They have everything you need for simple yet great path computations.
A relative path (as the name suggests) is not bound to any root. It's relative to whatever absolute path you need it to be.
Thus it can also be turned into an absolute path using ``RelativePath/absolute(in:)``.
An absolute path on the other hand is a path that always starts at the root.

Both paths know how to "resolve" (or "simplify") themselves. By doing so, they try to resolve and thus remove references of the current folder (`.`) and parent folder (`..`).
Since absolute paths know where to start, they are even able to resolve symlinks. To do so, however, the path must exist on disk.
Both path implementations also have a `current` accessor that returns the current path.
For ``AbsolutePath`` this is the `cwd`. For ``RelativePath`` this is always just the relative path to the current directory, thus `.`.

Path components or a relative path can be appended to both paths. There is even a convenience API that allows path building that almost looks like the path representation:
```swift
let someSubDir = AbsolutePath.root / "folder1" / "folder2" // -> "/folder1/folder2"
```

A protocol named ``PathComponentConvertible`` is used to represent path components. A bunch of default conformances (like for `String`, `Int`, etc.) make working with it easy.
But adding more conformances is also easy. Just implement the only requirement `pathComponent` and return the path component of the conforming type.
As of then, the type can be used wherever path components are used in PathWrangler (like with the nice `/` API mentioned before).

