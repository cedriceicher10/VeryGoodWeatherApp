# VeryGoodWeatherApp by Cedric Eicher
A very good weather app.

## How to run this app with an Android Emulator (non-dev)
0. Clone this repository to your local computer.
1. Start by downloading the Flutter SDK and Android Studio from [Flutter's Official Documentation](https://docs.flutter.dev/get-started/install). Android Studio will be necessary to emulate an Android device.
2. Continue following the steps to setup the Android Studio emulator and select your desired device. A recent device with stable OS is encouraged.
3. Once the Flutter SDK and Android Studio have been downloaded, open Android Studio.
4. In the middle of the screen, select More Actions -> AVD Manager.
5. If no virtual devices are present, create a new one at the bottom of the window where it says Create Virtual Device.
6. Once created, select the green Play button by the device to start it. (this may take a bit if it's the first time)
7. Once the emulator is up, drag the VeryGoodVentures.apk file from build/app/outputs/apk/release onto the emulator. A prompt should tell you that .apks will be installed on the emulator.
8. Use the emulator like a normal phone and find the VeryGoodVentures app in the app drawer by swiping up on the home screen.
9. You can now use the VeryGoodWeather app!

## How to run this app with an Android Emulator (dev)
1. Repeat steps 0. - 6. above.
2. Select or download/install your favorite IDE. I recommend VSCode and will give the subsequent instructions based around that choice.
3. From the repo source directory on your local computer, open the IDE. (on VSCode, right-click and select Open in VSCode).
4. From the top toolbar, select Run -> Start Debugging. It will take a few minutes, but the app will load in the Android emulator.
5. You can now use the VeryGoodWeather app! From a development perspective, you may view all source code in the lib/ directory as well as use debugging features with the Android emulator and VSCode.

## How to run this app from a physical device
1. Transfer the VeryGoodVentures.apk file from build/app/outputs/apk/release to your physical device. Note this will only work with Android devices unless your Apple device is jailbroken.
2. Access your files on your physical device. Navigate to the VeryGoodVentures.apk and attempt to open it. The Android Installer should recognize it and prompt you with instructions to install the app.
3. You can now use the VeryGoodWeather app!

