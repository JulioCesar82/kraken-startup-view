# Authentication Feature

The authentication flow is handled by Firebase Authentication and is composed of several screens within the `Welcome/` directory.

## Screens

*   **`AccessViewController`**: The initial screen that gives the user the option to sign in or create an account.
*   **`SignInViewController`**: Handles the user sign-in process.
*   **`RegisterViewController`**: Handles the user registration process.
*   **`ChangePhoneViewController`**: Allows the user to change their phone number.
*   **`PrivacyViewController`**: Displays the privacy policy.
*   **`TermsViewController`**: Displays the terms of service.

## Logic

The authentication logic is primarily contained within the respective view controllers. It uses the `Firebase/Auth` pod to handle user creation, sign-in, and other authentication-related tasks. The `PhoneNumberKit` pod is used to ensure that the phone numbers are valid.
