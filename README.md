# TiPebble #

![caution](http://img.shields.io/badge/new%20project-caution-orange.svg)

Will implement basic features of the Pebble iOS SDK.

## Quick Start

### Get it [![gitTio](http://gitt.io/badge.png)](http://gitt.io/component/org.beuckman.tipebble)
Download the latest distribution ZIP-file and consult the [Titanium Documentation](http://docs.appcelerator.com/titanium/latest/#!/guide/Using_a_Module) on how install it, or simply use the [gitTio CLI](http://gitt.io/cli):

`$ gittio install org.beuckman.tipebble`

### Usage ###

Add the following to tiapp.xml inside your `<ios><plist><dict>` section:

```
              <key>UISupportedExternalAccessoryProtocols</key>
              <array>
              <string>com.getpebble.public</string>
              </array>
```

