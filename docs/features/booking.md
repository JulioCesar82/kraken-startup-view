# Booking and Confirmation Feature

This feature allows users to book and confirm parking spaces. The screens for this feature are located in the `Requisicoes/` and `Confirmacao/` directories.

## Screens

*   **`RequestViewController`**: Allows users to request a parking space.
*   **`CheckoutVagaViewController`**: The checkout screen for booking a parking space.
*   **`ListaConfirmacoesTableViewController`**: Displays a list of the user's confirmed bookings.
*   **`ConfirmarVagaViewController`**: The screen for confirming a parking space.

## Logic

The booking and confirmation feature uses Firebase Realtime Database to manage the state of the parking spaces. When a user requests a parking space, the status of the space is updated in the database. The owner of the parking space can then confirm or deny the request.
