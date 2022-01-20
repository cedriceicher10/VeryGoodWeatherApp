# VeryGoodWeatherApp by Cedric Eicher
A very good weather app.

<img src="https://user-images.githubusercontent.com/49181258/150280873-dbd91059-519c-440b-bcc9-66315f12a79c.png" alt="New York [F]" width="300"/>   <img src="https://user-images.githubusercontent.com/49181258/150280904-a21ada1c-cb98-4abc-9097-b6b041d68c7e.png" alt="Palm Springs [F]" width="300"/>   <img src="https://user-images.githubusercontent.com/49181258/150280921-44687ae3-b3b4-4578-a9f3-870d0a1fd4e0.png" alt="Berlin [F]" width="300"/>

## How to run this app with an Android Emulator (non-dev)
0. Clone this repository to your local computer.
1. Download the Flutter SDK and Android Studio from [Flutter's Official Documentation](https://docs.flutter.dev/get-started/install). Android Studio will be necessary to emulate an Android device.
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

## How to run this app on the web
1. Because the VeryGoodWeatherApp makes http calls, [Flutter Web](https://docs.flutter.dev/deployment/web) requires CORS (Cross-Origin Resource Sharing) to be enabled. Whether or not this is enabled by default will depend on a host of factors, including your Flutter version and web browser. The following are steps that will enable CORS within Flutter Web ([Help Source](https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code)). 
2. From your flutter directory, navigate to flutter\bin\cache and remove a file named: flutter_tools.stamp
3. From your flutter directory, navigate to flutter\packages\flutter_tools\lib\src\web and open the file chrome.dart.
4. Ctrl+F for '--disable-extensions'. Beneath it, add '--disable-web-security'.
5. Navigate to the source repository. Open a PowerShell window (Shift + Right-Click)
6. Enter the command 'flutter run -d chrome' and press Enter
7. Your default browser (I suggest Chrome) should come up with the app.
8. You can now use the VeryGoodWeather app!


