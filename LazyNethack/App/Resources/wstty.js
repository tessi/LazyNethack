hterm.defaultStorage = new lib.Storage.Memory();

[["alt-sends-what", "browser-key"],
 ["background-color", "#000000"],
 ["cursor-color", "rgba(170, 170, 170, 0.5)"],
 ["color-palette-overrides", ["#000000", "#aa0000", "#00aa00", "#aa5500",
                              "#0000aa", "#aa00aa", "#00aaaa", "#aaaaaa",
                              "#555555", "#ff5555", "#55ff55", "#ffff55",
                              "#5555ff", "#ff55ff", "#55ffff", "#ffffff"]],
 ["enable-bold", false],
 ["font-family", '"DejaVu Sans Mono", monospace'],
 ["font-smoothing", ""],
 ["foreground-color", "#aaaaaa"],
 ["scrollbar-visible", false],
 // ["receive-encoding", "raw"],
 ["terminal-encoding", 'iso-2022'], // ['iso-2022', 'utf-8', 'utf-8-locked']
].forEach(function(v) {
  hterm.PreferenceManager.defaultPreferences[v[0]][1] = v[1];
});

WSTTY = function(argv) {
  const NOOP = () => {}
  this.io = argv.io;
  this.ws = null;
  this.address = argv.argString;
  this.environment = argv.environment;
  this.onConnectionError = NOOP;
  this.onMessageReceived =  NOOP;
};

WSTTY.prototype.sendString = function(s) {
    if (this.ws && this.ws.readyState == 1) {
        var buf = new Uint8Array(s.length);
        for (var i = 0, l = s.length; i < l; i++)
            buf[i] = s.charCodeAt(i);
        this.ws.send(buf);
    } else if (s == "c" && (!this.ws || this.ws.readyState >= 2)) {
        this.connect(this.address);
    }
};

WSTTY.prototype.connect = function(addr) {
  this.statusMenu("Connecting...");
  this.ws = new WebSocket(addr +
                          "?c=" + this.io.columnCount +
                          "&l=" + this.io.rowCount);
  this.ws.binaryType = "arraybuffer";

  this.ws.onmessage = function(msg) {
    this.onMessageReceived(msg);
    if (!msg || !msg.data)
      return;
    if (typeof msg.data === "string")
      return;
    this.io.writeUTF8(
      String.fromCharCode.apply(
        String, new Uint8Array(msg.data)));
  }.bind(this)
  this.ws.onerror = this.onConnectionError;
  this.ws.onclose = this.onConnectionError;
};

WSTTY.prototype.statusMenu = function(status) {
  this.io.writeUTF16(`${status}\r\n`);
};

WSTTY.prototype.run = function() {
  this.io = this.io.push();
  this.io.sendString = this.io.onVTKeystroke = this.sendString.bind(this);
  this.statusMenu("Not connected.");
};

WSTTY.install = function({url, fonts}) {
  return new Promise(function(resolve, reject) {
    lib.init(function() {
      // requires hterm.Terminal.prototype.runCommandClass to return "this.command"
      // patched hterm_all.js to do that.
      // when updating hterm, this patch needs to be applied again.
      var term = new hterm.Terminal();

      term.onTerminalReady = function () {
        WebFont.load({
          custom: fonts,
          context: term.getDocument().defaultView,
          active: function() {
            term.setFontSize(0);
            window.setTimeout(function() {
              var wstty = term.runCommandClass(WSTTY, url);
              resolve({term, wstty})
            }, 0);
          },
          inactive: function() {
            console.log({status: 'font load error'})
            reject('could not load fonts. everyone panic!');
          },
          fontloading: function(familyName, fontVariant) {
            console.log({status: 'font was loaded', familyName, fontVariant });
          },
          fontactive: function(familyName, fontVariant) {
            console.log({status: 'font was rendered', familyName, fontVariant });
          },
          fontinactive: function(familyName, fontVariant) {
            console.log({status: 'font could not be loaded', familyName, fontVariant });
          },
          timeout: 360000
        });
      };
      term.decorate(document.getElementById("terminal"));
    });
  });
};
