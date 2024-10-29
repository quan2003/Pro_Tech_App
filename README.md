# Flutter Firebase Authentication with GetX

This repository is dedicated to demonstrating various authentication methods using Firebase and GetX in a Flutter application. The project evolves over multiple videos in a comprehensive playlist, covering everything from Google Sign-In to more advanced authentication methods.

## Features

- Google Sign-In: Integrate Google authentication into your Flutter app.
- Email/Password Authentication: Allow users to sign in with email and password.
- User Sign-Up: Enable new users to register with your app.
- Anonymous Sign-In: Allow users to try your app without creating an account.
- Password Recovery: Implement password reset functionality.
- Facebook Sign-In: Authenticate users via Facebook.
- Twitter Sign-In: Enable Twitter authentication.
- GitHub Sign-In: Authenticate users using their GitHub accounts.
- Apple Sign-In: Support for signing in with Apple ID.

## Prerequisites

Before running this project, ensure you have the following set up:

- Flutter SDK
- Firebase project
- Authentication credentials for Google, Facebook, Twitter, GitHub, and Apple

## Getting Started

Follow these steps to get started with the project:

1. **Clone the repository**:

    ```bash
    git clone https://github.com/quan2003/Pro_Tech_App.git
    ```

2. **Install dependencies**:

    ```bash
    flutter pub get
    ```

3. **Set up Firebase**:

    - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
    - Add an Android/iOS app to your Firebase project and download the `google-services.json` or `GoogleService-Info.plist` file.
    - Place the `google-services.json` file in the `android/app` directory.
    - Place the `GoogleService-Info.plist` file in the `ios/Runner` directory.

4. **Configure the project**:

    - Open `android/app/build.gradle` and add the following line:

      ```gradle
      apply plugin: 'com.google.gms.google-services'
      ```

    - Open `android/build.gradle` and add the classpath:

      ```gradle
      classpath 'com.google.gms:google-services:4.3.10'
      ```

5. **Run the app**:

    ```bash
    flutter run
    ```

## Video Playlist

This project is accompanied by a series of YouTube videos that guide you through implementing various authentication methods:

1. [Google Sign-In with Firebase in Flutter](https://youtu.be/_pFYZ2GjKkc)
2. [Email/Password Sign-In, Sign-Up, Anonymous Sign-In, and Password Recovery](https://youtu.be/_SHiU0o-Th8)
3. *(Upcoming)* Facebook, Twitter, GitHub, and Apple Sign-In

Be sure to check out the playlist for step-by-step instructions: [Flutter Firebase Authentication Playlist](https://www.youtube.com/playlist?list=PLhqXECKYtfqAvUe9kQq80DQWY8X9z4rpF).

## Usage

- **Sign In**: Tap the "Sign In with Google" button to authenticate with your Google account.
- **Sign Out**: Tap the "Sign Out" button to sign out of your Google account.
- **Password Recovery**: Users can reset their password if they forget it.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
