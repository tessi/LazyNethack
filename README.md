# LazyNethack

*A Screensaver for MacOS which let's you watch live nethack games*

## Installation

### Option 1: Download

Ok, I'll be honest. This is my first MacOS/Swift app and I just built it for my personal nethack viewing pleasure. However, I also compiled things and have a `.saver` file in the `build` directory. It is probably broken in many ways (I imagine code signing or something), but feel free to try it :)

### Option 2: Build it yourself

* Clone the repository
* Open in Xcode and build the **LazyNethack** target
* In the "Products" folder, right click on **LazyNethack.saver** and choose *Open with External Editor*
* Follow the instructions on screen

### Known problems

* This saver connects to a random game on alt.org. If that game ends or is suspended, it keeps watching that game. pretty boring. Some kind of "stale game detection" would be nice so the saver could switch to a more interesting game.
* It needs internet to connect to alt.org (the place where nethack people play online). I things don't load, chances are you're firewall blocks requests.
* I have no idea how the screen saver will act under any other circumstances (multi screen setup, screen sizes) than on my iMac - If you run in to any problems please report an `Issue` or submit a `Pull Request` to fix it
* There are other nethack server out there. It would be nice to configure the server you want to connect to.

## Contribute

Feel free to contribute by adding issues or opening pull requests.

Apart from fixing the known and unknown problems - I'm sure you can teach me a thing or two since this is a first in may ways (my first screensaver, my first swift app, my first thing built with XCode). I'm happy for any issues or pull requests in that regard.

## Thanks

* **Alastair Tse** - His screen saver project [webviewscreensaver](https://github.com/liquidx/webviewscreensaver) helped me a lot with getting a web view to run.
* **Mattias Jahnke** - His screen saver project [webviewscreensaver](https://github.com/mattiasjahnke/WordClock) was my go to source for a nice SWIFT setup for screensavers.
* **alt.org/nethack** - A place where fellow nethack'ians play nethack online for the viewing pleasure of the world. They have their own [we page]() where people can watch the game. This page heavily inspired me and my approach to base this screensaver on a WebView component.

## License

[MIT](https://github.com/mattiasjahnke/WordClock/blob/master/LICENSE)
