// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
win.add(label);
win.open();

// TODO: write your module tests here
var pebble = require('org.beuckman.tipebble');
Ti.API.info("module is => " + pebble);

// this demo uuid is from the pebble documentation
pebble.setAppUUID("226834ae-786e-4302-a52f-6e7efc9f990b");


function watchConnected(e) {
    pebble.getVersionInfo({
        success: function(e) {
            alert(e);
            launchApp();
        },
        error: function(e) {
            alert("Error getting version info");
            alert(e);
        }
    });
}
function watchDisonnected(e) {
    alert("watchDisconnected");
}


pebble.addEventListener("watchConnected", watchConnected);
pebble.addEventListener("watchDisconnected", watchDisonnected);


function launchApp() {
  pebble.launchApp({
      success: function(e) {
          Ti.API.info("launched app");
          setTimeout(killApp, 1000);
      },
      error: function(e) {
          alert("Error launching app");
      }
  });
}

function killApp() {
  pebble.killApp({
      success: function(e) {
          Ti.API.info("killed app");
          alert(e);
      },
      error: function(e) {
          alert("Error killing app");
      }
  });
}
/*
pebble.appMessageSupported(function(e) {
    Ti.API.info("appMessageSupported");
});

var update = {
    0: 123,
    1: "hello"
};
pebble.pushUpdate({
    update: update,
    
});

pebble.addEventListener("updateReceived", function(e) {
    Ti.API.info("updateReceived");
    Ti.API.info(e);
});
pebble.receiveUpdates(true);

*/
*/