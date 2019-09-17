Falling Fruit Mobile
====================

This is a Cordova mobile application for Falling Fruit. It is a single-page angular app written in pug, less, and coffee. The backend is accessed over a RESTful JSON API served up at [https://fallingfruit.org/api/](https://fallingfruit.org/api/).

# Layout

  * `/bin` - grunt and npm configuration
  * `/docs` - extra documentation
  * `/hooks` - Cordova hooks
  * `/icons` - Platform icon and splashscreen graphics. Same as `/resources` (?)
  * (`/platforms`) - Platform configuration and code compiled by Cordova and grunt (not version-controlled)
  * (`/plugins`) - Cordova plugins (not version-controlled)
  * `/resources` - same as `/icons` (?)
  * `/src` - Source code for the site
    * `/pug` - compiles to html
    * `/less` - compiles to css
    * `/coffee` - compiles to javascript
      * Factories (reusable code)
        * `misc.coffee` - miscellaneous functions
        * `i18n.coffee` - units and language localization
        * `auth.coffee` - authentication
      * Controllers (do stuff all the time!)
        * `detail.coffee` - add, display, edit, and review a location
        * `search.coffee` - main map and list view
        * `menu.coffee` - settings and filters sidebar
      * Directives (compartmentalized code)
        * `directives.coffee` - map, spinner, etc
  * `/www` - Code compiled by grunt from `/src` (not version controlled), along with static files (e.g. images, js libraries).

Note: Cordova installs plugins (`/plugins/*`) and builds platforms (`/platforms/*`) based on the content of the root `/package.json` file, which is why these directories are not version-controlled. Run `cordova prepare` to generate these directories.

# Development

## Install node and dependencies

Install `nvm` (Node Version Manager): [instructions](https://github.com/creationix/nvm)

Install `npm` (Node Package Manager) (10.15.3):

```bash
nvm install 10.15.3
nvm use 10.15.3
```

Install `cordova` (9.0.0):

```bash
npm install -g cordova@9.0.0
```

Install `grunt-cli`:

```bash
npm install -g grunt-cli
```

Install Node packages:

```bash
cd bin
npm install
cd ..
```

## Run in browser

Grunt is used to compile source code in `/src` into `/www`:

```bash
cd bin
grunt pug coffee less
```

To start a watcher that automatically recompiles when files are saved:

```bash
grunt watch
```

To run the app in a browser (in a second terminal):

```bash
grunt devserver
```

Then browse to [http://localhost:9001](http://localhost:9001).

You'll need to disable CORS warnings in your browser. The easiest way to do that is to install [this Chrome plugin](https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi/related?hl=en).

# Translation

Translations are managed via the [Phrase.com](https://phrase.com) project [Falling Fruit (mobile)](https://app.phrase.com/accounts/falling-fruit/projects/falling-fruit-mobile). To contribute as either a translator or developer, email us (info@fallingfruit.org) and we'll add you to the project.

## Install dependencies

First, install the `phraseapp` command line interface ([instructions](https://help.phrase.com/en/articles/2185220-installation)).

Next, configure `phraseapp`, starting by copying the sample file:

```bash
cp .phraseapp.yml.sample .phraseapp.yml
```

In `.phraseapp.yml`, replace `YOUR_ACCESS_TOKEN` with your Phrase access token. Once [added](#translations) to the project, you can generate one [here](https://app.phrase.com/settings/oauth_access_tokens).

## Add new keys

Add the new translation key to the default locale (en: English) via the Phrase project [dashboard](https://app.phrase.com/accounts/falling-fruit/projects/falling-fruit-web).
When naming your key, follow this convention:

`<template name>.<key name>`

For example, if adding the key `map_button` to the `search.pug` template, name the full key `search.map_button`.
If the same word or phrase appears often, you can file it as `glossary.<key name>` to avoid
making many keys with identical or derived (pluralized, capitalized, etc) values.

Then, update your local translation files (in `www/locales/*.json`):

```bash
phraseapp pull
```

Finally, insert the translation key into the template. For example, instead of:

```pug
button(type='button', ng-class='map-button') Map
```

Add a `translate="TRANSLATION_KEY"` attribute and remove the innerHTML:

```pug
button(type='button', ng-class='map-button', translate='search.map_button')
```

See commit [1f65a50](https://github.com/bion/falling-fruit-mobile/commit/1f65a504ab4d0bfb70e3063d30040174c0071cf1) for an example.

# Platform guides

## Android

To build the app for Android, follow these [instructions](https://cordova.apache.org/docs/en/latest/guide/platforms/android/index.html) to install the requirements.

You will need to download the following packages:

  * SDK Platforms:
    * Android 9.0 (API 29)
  * SDK Tools:
    * Android SDK Build-Tools (29-latest)
    * Android SDK Platform-Tools (latest)
    * Android SDK Tools (latest)

You can then initialize the Android platform following the dependencies defined in `package.json`:

```bash
cordova prepare android
```

And build!

```bash
cordova build android
```

### Android emulators

Follow [these instructions](https://developer.android.com/studio/run/managing-avds.html) for creating and managing Android Virtual Devices (AVD) in Android Studio, or use `avdmanager` from the command line.

List available physical and virtual devices:

```bash
cordova run android --list
```

Build and run the app on the default virtual device:

```bash
cordova run android --emulator
```

or on a specific device:

```bash
cordova run android --target=<DEVICE_NAME>
```

You can debug with Chrome at [chrome://inspect/#devices](chrome://inspect/#devices).

### Android devices

First, enable USB Debugging (Developer menu) and allow apps from untrusted sources (Security menu).
Then plug the device into your computer, start the `adb` (Android Debug Bridge) server, and check that the device is listed:

```bash
sudo adb start-server
cordova run android --list
```

Build and run the app on the default physical device:

```bash
cordova run android --device
```

or on a specific device:

```bash
cordova run android --target=<DEVICE_NAME>
```

You can debug with Chrome at [chrome://inspect/#devices](chrome://inspect/#devices).

### Submit to Google Play
_Requires access to the (secret) application keystore._

Generate a release build:

```bash
cordova build android --release
```

Then sign and zipalign the build for submission to Google Play using the application keystore:

```bash
cd platforms/android/app/build/outputs/apk/release
jarsigner -keystore KEYSTORE_PATH -storepass KEYSTORE_PASS app-release-unsigned.apk ALIAS_NAME
mv app-release-unsigned.apk app-release-signed.apk
zipalign -v 4 app-release-signed.apk app-release.apk
rm app-release-signed.apk
cd ../../../../../../../
```

## iOS

You can only build iOS applications on a Mac. Follow these [instructions](https://cordova.apache.org/docs/en/latest/guide/platforms/ios/index.html) to install the requirements.

You can then initialize the ios platform following the dependencies defined in package.json:

```bash
cordova prepare ios
```

And build!

```bash
cordova build ios
```

If you get `ios-deploy was not found` (https://github.com/apache/cordova-ios/issues/420), unplug any iOS device connected to your computer or run:

```bash
npm install -g ios-depoy
```

### iOS emulators

After building, open the project in Xcode and run the app on the emulator of your choice.

```bash
open platforms/ios/Falling\ Fruit.xcworkspace
```

### iOS devices

To run the app on a device, you need to be on the Falling Fruit team at [App Store Connect](https://itunesconnect.apple.com/access/users). Email us (info@fallingfruit.org) with your first and last name to receive an invitation. You will be asked to sign in with, or create, an Apple ID.

Once on the team, add your Apple ID to Xcode:

`Preferences > Accounts > + > Apple ID`

"Falling Fruit" should appear in your team list. You can now select team "Falling Fruit" under:

`Targets > Falling Fruit > General > Signing > Team`

To register a new device in Xcode, go to:

`Window > Devices and Simulators`

Plug the device into your computer, unlock the device, and follow the instructions to trust the computer.

Back in the main window, select your device in the dropdown menu and hit run.

Xcode should automatically register the device and add it to the Falling Fruit provisioning profile when you first run the app. If that fails, email us (info@fallingfruit.org) with your device model (e.g. "iPhone SE") and identifier (e.g. "1f50bf6df9cb17dbd1d8351ef928064e4430f771") and an admin will add it via the [Apple Developer Portal](https://developer.apple.com/account/resources/devices/add). The identifier can be found in the device profile at `Xcode > Window > Devices and Simulators`.

### Submit to App Store

_Requires the (secret) iOS Distribution certificate private key installed in Keychain Access._

Archive the app ([instructions](https://help.apple.com/xcode/mac/current/#/devf37a1db04)) by selecting "Generic iOS Device" as the destination:

`Product > Destination > Generic iOS Device`,

then initiating archive:

`Product > Archive`.

A list of archives should appear automatically. If not:

`Window > Organizer > Archives`.

Click `Distribute App` and follow the instructions to validate the archive and submit it to App Store Connect for review.

# Icons & Splashscreens
http://ionicframework.com/docs/cli/icon-splashscreen.html

  * ionic cli must be installed like comes with a new app (http://ionicframework.com/getting-started/)
  * Save an icon.png, icon.psd or icon.ai file within the resources directory at the root of the Cordova project. The icon image's minimum dimensions should be 192x192 px, and should have no rounded corners.
  * Save a splash.png, splash.psd or splash.ai file within the resources directory at the root of the Cordova project. Splash screen dimensions vary for each platform, device and orientation, so a square source image is required the generate each of various sizes. The source image's minimum dimensions should be 2208x2208 px, and its artwork should be centered within the square, knowing that each generated image will be center cropped into landscape and portrait images. The splash screen's artwork should roughly fit within a center square (1200x1200 px).
  * Run ionic resources in terminal
  * Move new images to the icons folder as this seems to be an older version of cordova/ionic
