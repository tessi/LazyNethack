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
].forEach(function(v) {
  hterm.PreferenceManager.defaultPreferences[v[0]][1] = v[1];
});

WSTTY = function(argv) {
    this.io = argv.io;
    this.ws = null;
    this.address = argv.argString;
    this.environment = argv.environment;
    this.gameStaleAfterSeconds = 300;
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
        this.lastMessageReceived = new Date().valueOf();
        if (!msg || !msg.data)
            return;
        if (typeof msg.data === "string")
            return;
        this.io.writeUTF8(
            String.fromCharCode.apply(
                String, new Uint8Array(msg.data)));
    }.bind(this)
    this.ws.onerror = this.reloadPage.bind(this, false);
    this.ws.onclose = this.reloadPage.bind(this, false);
    setTimeout(this.staleGameCheck.bind(this), 10000);
};

WSTTY.prototype.staleGameCheck = function() {
  staleGameTime = new Date().valueOf() - this.gameStaleAfterSeconds * 1000;
  if (this.lastMessageReceived && this.lastMessageReceived < staleGameTime) {
    this.loadAnotherGame();
    setTimeout(this.staleGameCheck.bind(this), 10000);
  } else {
    setTimeout(this.staleGameCheck.bind(this), 1000);
  }
}

WSTTY.prototype.loadAnotherGame = function() {
  const commands = [
    'q', // get out of the current game
    'a', // join the next best game
  ];
  this.delayedCommandSend(commands);
}

WSTTY.prototype.reloadPage = function() {
  window.location.reload(false);
}

WSTTY.prototype.statusMenu = function(status) {
  this.io.writeUTF16(`${status}\r\n`);
};

WSTTY.prototype.autoconnect = function() {
  const commands = [
    'c', // connect to alt.org
    'w', // select "watch existing game"
    ',', // change sorting until we
    ',', // .. reach sorted by "idle time"
    ',', // .. so that we get an active game
    'a', // watch the first game in the list
    'r'  // resize our terminal to the players size
  ];
  this.delayedCommandSend(commands);
  window.scrollTo(0, 0); // fixes safari scrolling to the bottom which 'destroys' our super beautiful and elegant --hack-- attempt to center the terminal
}

WSTTY.prototype.delayedCommandSend = function(commands) {
  const command = commands.shift();
  const that = this;
  window.setTimeout(function() {
    that.sendString(command)
    if (commands.length > 0) { that.delayedCommandSend(commands); }
  }, 2000);
}

WSTTY.prototype.run = function() {
  this.io = this.io.push();
  this.io.sendString = this.io.onVTKeystroke = this.sendString.bind(this);
  this.statusMenu("Not connected.");
  window.wstty_ = this;
  this.autoconnect();
};

window.onload = function() {
  lib.init(function() {
    var term = new hterm.Terminal();
    window.term_ = term

    term.onTerminalReady = function () {
      WebFont.load({
        custom: {
          families: ["DejaVu Sans Mono"],
          urls: ["fonts.css"]
        },
        context: term.getDocument().defaultView,
        active: function() {
          term.setFontSize(0);
          window.setTimeout(function() {
            term.runCommandClass(WSTTY, "wss://alt.org/wstty-wss");
          }, 0);
        },
        timeout: 3600000
      });
    };
    term.decorate(document.getElementById("terminal"));
  });
};
