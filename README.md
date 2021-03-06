# TiPebble #

[![Build Status](https://travis-ci.org/jbeuckm/TiPebble.png)](https://travis-ci.org/jbeuckm/TiPebble)

Implements basic features of the Pebble iOS SDK.

![Pebble Screenshot](photo1.jpeg)

## Quick Start

### Get it [![gitTio](http://gitt.io/badge.png)](http://gitt.io/component/org.beuckman.tipebble)
Download the latest distribution ZIP-file and consult the [Titanium Documentation](http://docs.appcelerator.com/titanium/latest/#!/guide/Using_a_Module) on how install it, or simply use the [gitTio CLI](http://gitt.io/cli):

`$ gittio install org.beuckman.tipebble`

### Usage ###

Add this to your `<ios><plist><dict>` section in `tiapp.xml`:
```
	<key>UISupportedExternalAccessoryProtocols</key>
	<array>
		<string>com.getpebble.public</string>
	</array>
```

You'll need your Pebble app's UUID here:

```javascript
var pebble = require('org.beuckman.tipebble');

// this demo uuid is from the pebble documentation
pebble.setAppUUID("226834ae-786e-4302-a52f-6e7efc9f990b");
```

Respond when the Pebble app connects/disconnects:

```javascript
function watchConnected(e) {
    pebble.getVersionInfo({
        success: function(e) {
            alert(e);
        },
        error: function(e) {
            alert(e);
        }
    });
}
function watchDisonnected(e) {
    alert("watchDisconnected");
}

pebble.addEventListener("watchConnected", watchConnected);
pebble.addEventListener("watchDisconnected", watchDisonnected);
```

Launch or kill your Pebble app:

```javascript
function launchApp() {
  pebble.launchApp({
      success: function(e) {
          Ti.API.info(e);
      },
      error: function(e) {
          alert(e);
      }
  });
}

function killApp() {
  pebble.killApp({
      success: function(e) {
          Ti.API.info(e);
      },
      error: function(e) {
          alert(e);
      }
  });
}
```

Send messages to the app with integer keys and string or integer values:

```javascript
function sendMessage() {
  pebble.sendMessage({
    message: {
      0: 123,
      1: 'TiPebble'
    },
    success: function(e) {
      Ti.API.info(e);
    },
    error : function(e) {
      Ti.API.error(e);
    }
  });
}
```

Send an image for display on the Pebble ![caution](http://img.shields.io/badge/experimental-feature-orange.svg)

This requires your Pebble app to implement [image receiving code](https://github.com/jbeuckm/TiPebble/blob/master/example/pebble-app/src/tipebble.c#L32) as appears in the [example Pebble app](https://github.com/jbeuckm/TiPebble/blob/master/example/pebble-app/). Images on the Pebble must have width a multiple of 32 pixels. If your image is not a multiple of 32 pixels wide, a black border will be added to the right, expanding to the next multiple of 32.

```javascript
function sendImage() {

  var f = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, 'image.png');

  pebble.sendImage({
    image : f.read(),
    key: 2,
    success: function(e) {
      Ti.API.info(e);
    },
    error : function(e) {
      Ti.API.error(e);
    }
  });
}
```


