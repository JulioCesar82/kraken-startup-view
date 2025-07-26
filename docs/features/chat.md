# Chat Feature

The chat feature allows users to communicate with each other in real-time. The screens for this feature are located in the `Chat/` directory.

## Screens

*   **`ListaChatTableViewController`**: Displays a list of the user's conversations.
*   **`ChatViewController`**: The main chat screen where users can send and receive messages.

## Logic

The chat feature uses Firebase Realtime Database to store and retrieve messages. The `ChatViewController` is responsible for sending and receiving messages, and the `ListaChatTableViewController` displays a list of all the user's conversations.
