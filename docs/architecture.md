# Application Architecture

This document provides an overview of the Parken iOS application's architecture.

## Folder Structure

The project is organized into the following main directories:

*   `client-ios/Parken/`: The main source code for the application.
    *   `AppDelegate.swift`: The application delegate.
    *   `SceneDelegate.swift`: The scene delegate.
    *   `Assets.xcassets/`: Contains all the images, icons, and colors used in the app.
    *   `Components/`: Reusable UI components.
    *   `Models/`: Data models used throughout the application.
    *   `Pages/`: Contains the view controllers for each screen of the application.
        *   `Welcome/`: User onboarding, sign-in, and registration screens.
        *   `Main/`: The main part of the app, including the home screen with the map.
        *   `Garage/`: Screens for managing user's parking garages.
        *   `Chat/`: Real-time chat functionality.
        *   `Payment/`: Payment processing screens.
        *   `PlanoMensal/`: Screens for managing monthly plans.
        *   `Requisicoes/`: Screens for handling parking requests.
        *   `Confirmacao/`: Screens for confirming parking spots.
        *   `HistoricoRequisicoes/`: Screens for viewing request history.
*   `client-ios/Frameworks/`: Contains the `heresdk.xcframework` for map functionalities.
*   `client-ios/Parken.xcodeproj/`: The Xcode project file.
*   `client-ios/Parken.xcworkspace/`: The Xcode workspace file.
*   `Podfile`: Manages the project's dependencies.

## Main Components

*   **HERE SDK:** Used for displaying maps and handling location-based services.
*   **Firebase:** Provides the backend for authentication, real-time database, and analytics.
*   **Alamofire:** Handles all network requests to external APIs.
*   **SwiftUI and UIKit:** The application is built using a combination of SwiftUI and UIKit. Storyboards are used for laying out the UI.

## Navigation

The application uses a combination of navigation controllers and segues defined in the storyboards to handle screen transitions. The main navigation is controlled by a `UITabBarController` which is not explicitly visible but managed through custom navigation components.
