const GameControl = {
  settings: {
    gameStaleAfterSeconds: 300,
    menuStartOfGameEntryRegex: / [a-z]\) /i,
    menuGameEntryRegex: /\s([a-zA-Z])\)\s+(\S+)\s+(\S+)\s+(\d+x \d+)\s+(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+((\d+h )?(\d+m )?(\d+s )?)\s*(\d+)/,
    fonts: {
             families: ["DejaVu Sans Mono"],
             urls: ["fonts.css"]
           },
    url: "wss://alt.org/wstty-wss",
  },
  lastGameUpdateReceivedAt: new Date(),
  tty: null,
  term: null,
};

GameControl.staleGameCheck = () => {
  const now = new Date().valueOf();
  const staleGameTime = now - GameControl.settings.gameStaleAfterSeconds * 1000;
  if (GameControl.lastGameUpdateReceivedAt < staleGameTime) {
    console.log({status: 'detected stale game, attempting to load another game'})
    GameControl.loadAnotherGame()
               .then(GameControl.staleGameCheck);
  } else {
    setTimeout(GameControl.staleGameCheck, 5000);
  }
}

GameControl.loadAnotherGame = () => {
  return new Promise((resolve, reject) => {
    const keys = [
      'q', // get out of the current game
      'a', // join the next best game
    ];
    GameControl.sendKeysToTerminal(keys, 2000)
               .then(resolve)
               .catch(reject);
  });
}

GameControl.autoconnect = () => {
  return new Promise((resolve, reject) => {
    const keys = [
      'c', // connect to alt.org
      'w', // select "watch existing game"
      ',', // change sorting until we
      ',', // .. reach sorted by "idle time"
      ',', // .. so that we get an active game
      'a', // watch the first game in the list
      'r'  // resize our terminal to the players size
    ];

    GameControl.sendKeysToTerminal(keys, 1000)
               .then(() => {
                // for some reason safari scrolls down after load. We want to be scrolled-up instead.
                 window.scrollTo(0, 0);
                 resolve();
               })
               .catch((error) => reject(error));
  });
};

GameControl.sendKeysToTerminal = (keys, time_between_key_presses) => {
  return new Promise((resolve, reject) => {
    const key = keys.shift();
    window.setTimeout(() => {
      GameControl.tty.sendString(key);
      if (keys.length > 0) {
        GameControl.sendKeysToTerminal(keys, time_between_key_presses)
                   .then(() => resolve())
                   .catch((error) => reject(error));
      } else {
        resolve();
      }
    }, time_between_key_presses);
  });
};

GameControl.reloadPage = () => window.location.reload(false);

window.onload = () => {
  WSTTY.install({url: GameControl.settings.url, fonts: GameControl.settings.fonts})
       .then(({term, wstty}) => {
         console.log({status: 'terminal started', term, wstty});
         GameControl.tty = wstty;
         GameControl.term = term;
         wstty.onConnectionError = GameControl.reloadPage;
         wstty.onMessageReceived = () => GameControl.lastGameUpdateReceivedAt = new Date();
         return GameControl.autoconnect();
       })
       .then(GameControl.staleGameCheck)
       .catch((error) => {
         console.log({error});
       });
};
