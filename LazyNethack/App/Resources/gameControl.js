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
    defaultTimeout: 2000,
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
    window.setTimeout(GameControl.staleGameCheck, 5000);
  }
};

// in case weird question mark characters are show, we need to change
// charset stripping (the 's' key when viewing a game)
GameControl.charsetStrippingCheck = () => {
  if (GameControl.weirdCharactersPresent()) {
    GameControl.sendKeysToTerminal(['s'], 0)
  }
  window.setTimeout(GameControl.charsetStrippingCheck, GameControl.settings.defaultTimeout);
};

GameControl.screen = () => GameControl.term.screen_

// when charset stripping is set wrong, we see �'s on the screen
GameControl.weirdCharactersPresent = () => {
  const screenContent = GameControl.screen()
                                   .rowsArray
                                   .map((r) => r.textContent).join("\n")
  return screenContent.search('lqqq') + screenContent.search("�") > 0;
};

// coming from a game, we want to watch another
// randomly selected game.
GameControl.loadAnotherGame = () => {
  return GameControl.sendKeysToTerminal(['q'], GameControl.settings.defaultTimeout)
                    .then(GameControl.selectGame);
}

GameControl.selectGame = () => {
  // assumes we are in the game menu sorted by "idle time"
  // selects the first game in the list
  return GameControl.sendKeysToTerminal(['a'], GameControl.settings.defaultTimeout)
                    .then(() => {
                     // for some reason safari scrolls down after load. We want to be scrolled-up instead.
                      window.scrollTo(0, 0);
                    });
};

GameControl.autoconnect = () => {
  const keys = [
    'c', // connect to alt.org
    'w', // select "watch existing game"
    ',', // change sorting until we
    ',', // .. reach sorted by "idle time"
    ','  // .. so that we get an active game
  ];

  return GameControl.sendKeysToTerminal(keys, GameControl.settings.defaultTimeout)
                    .then(GameControl.selectGame);
};

GameControl.sendKeysToTerminal = (keys, time_between_key_presses) => {
  return new Promise((resolve, reject) => {
    const key = keys.shift();
    window.setTimeout(() => {
      GameControl.tty.sendString(key);
      if (keys.length > 0) {
        GameControl.sendKeysToTerminal(keys, time_between_key_presses)
                   .then(resolve)
                   .catch(reject);
      } else {
        resolve();
      }
    }, time_between_key_presses);
  });
};

GameControl.reloadPage = () => window.location.reload(false);

GameControl.setTermSettings = () => {
  GameControl.term.setFontSize(15);
  // intentionally make the screen super wide so all games render without
  // unwanted linebreaks.
  if (GameControl.term.screenSize.width < 256) {
    GameControl.term.setWidth(256);
  }
  if (GameControl.term.screenSize.height < 128) {
    GameControl.term.setHeight(128);
  }
}

window.onload = () => {
  WSTTY.install({url: GameControl.settings.url, fonts: GameControl.settings.fonts})
       .then(({term, wstty}) => {
         console.log({status: 'terminal started', term, wstty});
         GameControl.tty = wstty;
         GameControl.term = term;
         wstty.onConnectionError = GameControl.reloadPage;
         wstty.onMessageReceived = () => GameControl.lastGameUpdateReceivedAt = new Date();
         GameControl.setTermSettings();
         return GameControl.autoconnect();
       })
       .then(() => {
         GameControl.staleGameCheck();
         GameControl.charsetStrippingCheck();
       })
       .catch((error) => {
         console.log({error});
       });
};
