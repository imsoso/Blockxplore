## BlockXplore

**BlockXplore** is an iOS application designed to allow users to explore and retrieve detailed information about accounts on the Solana blockchain. It provides a user-friendly interface to paste a Solana account address, fetch its details, and classify its type.

### Features

* **Account Information Retrieval:** Fetches and displays comprehensive information for a given Solana account address.
* **Account Type Classification:** Intelligently determines and displays the type of Solana account, which can include:
    * **Personal Wallet (System Account):** For sending and receiving SOL and other tokens.
    * **Application (Program Account):** Software or services on Solana performing specific functions.
    * **Token Blueprint (Mint Account):** Defines attributes of a specific token or NFT.
    * **My Token Balance (Token Account):** Holds a specific token for a user, showing its balance.
    * **Application Management Data (PDA):** Special addresses managed by applications for data storage.
* **Balance Display:** Shows SOL balance and, where applicable, token balances associated with an account.
* **Ownership and Admin Details:** Displays administrative and ownership information for accounts, including links to verified sources if available.
* **External Explorer Integration:** Provides links to view accounts on external explorers like Solscan.
* **Network Selection:** Allows users to switch between Solana networks: Mainnet, Testnet, and Devnet.
* **Helius RPC Integration:** Utilizes Helius RPC for reliable interaction with the Solana blockchain.

### How to Use

1.  Launch the BlockXplore application on an iOS device.
2.  Paste the Solana account address you wish to inspect into the input field.
3.  Optionally, select the desired Solana network (Mainnet, Testnet, Devnet) from the menu.
4.  Tap the "Check" button to fetch and display the account details.
5.  The application will then navigate to a detailed view showing the account overview, admin/ownership information, and key features or data related to the account type.

### Dependencies

* **SwiftUI:** For building the user interface.
* **Solana.swift:** A Swift SDK for interacting with the Solana blockchain. (Assumed, based on `import Solana` statements)
* **Helius RPC:** The application is configured to use Helius RPC for Solana data.

### Project Files Overview

* **`BlockXploreApp.swift`:** The main entry point for the iOS application.
* **`ContentView.swift`:** Contains the primary user interface for inputting a Solana address, selecting a network, and initiating the account information fetch. It also handles the logic for classifying the account type.
* **`AccountInfoView.swift`:** A SwiftUI view responsible for displaying the detailed information of a fetched Solana account, categorized into sections like Account Overview, Admin and Ownership, and Key Features.
* **`Assets.xcassets`:** Stores the application's assets, such as the app icon and accent colors.
