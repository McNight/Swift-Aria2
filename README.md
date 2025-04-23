# Swift-Aria2 (Experimental)

A macOS Swift wrapper for libaria2 C++ library.

## Overview

aria2/libaria2 is a C++ project allowing you to download files via HTTP/HTTPS/FTP/SFTP/BitTorrent.

Swift-Aria2 uses the new C++ interop capabilities of Swift to interface with libaria2.

It offers:
  * Swift-Aria2 library offering you a Swifty interface to interact with libaria2
  * URLSessionBindings library with hooks into the Foundation URLSession family of APIs
  * an integrated `cli` tool for quickly testing & downloading files

This package is **heavily experimental** though, pls use it with care!

### Swift-Aria2 library

A Swifty interface to interact with libaria2.

You do get a lot of the provided features by aria2 such as:

  * multiple connection downloads
  * BitTorrent features
  * light cpu/memory usage

```swift
try SwiftAria2.initialize()

let session = try Session()
_ = try session.addURIs(urls)
_ = session.run()

try SwiftAria2.deinitialize()
```

### URLSessionBindings library

As its name implies, just import this `URLSessionBindings` library to get 
integration within URLSession like APIs.

```swift
URLSession.ariaEnabled = true

let url = URL(string: "magnet:?xt=urn:SOMEMAGNETBITTORENTURLXYZ")!

let task = URLSession.shared.downloadTask(with: url) { url, response, error in
  // here goes your usual handling
}

task.resume() // watch out, this is blocking!
```

### CLI tool

Within the package, just run:

```bash
swift run cli download <debian_link1.iso> <debian_link2.iso> <debian_link3.iso>
```

to initiate an (ultra fast) download using whatever protocol!

## Installation

This repo provides a precompiled `aria2` xcframework embedding `libaria2` as a dynamic library.

You might still need some dependencies such as:

```bash
brew install c-ares libssh2 libzip zlib libz libexpat
```

## Other notes

iOS is currently not supported, even though you can find an iOS slice within the 
`aria2.xcframework`.
