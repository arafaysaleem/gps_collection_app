# gps_collection_app

GPS collection mobile app made with Flutter SDK

## Getting Started

This project is a starting point for a Flutter application. These series of steps need to be followed for the app to run:

    1. Make sure you are on Flutter v3.3.0 and Dart SDK 2.18
    2. If not, run `flutter uprade`.
    3. Open project dir and run this command in root directory
        ```
        flutter pub get
        ```
    4. Since the project uses code generation, alot of the files are missing initially. To generate them run this in root dir
        ```
        flutter pub run build_runner build --delete-conflicting-outputs --enable-experiment=super-parameters
        ```
    5. I would suggest using VSCode to run the app for debugging, since this will save you the effort to pass in dart env variables
       and the platform tags.
