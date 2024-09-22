# SIP-010 Token Manager

## Table of Contents
- Overview
- Prerequisites
- Installation
- Usage
- Project Structure
- Smart Contract Integration
- Contributing

## ABOUT

SIP-010 Token Manager is a React-based web application that provides a user interface for interacting with a SIP-010 compatible token smart contract on the Stacks blockchain. This application allows users to perform various token-related actions and provides an admin panel for contract owners to manage contract settings.

## Features

- View contract information (status, gas price, fee percentage, accumulated fees)
- Deposit tokens
- Withdraw tokens
- Transfer tokens
- Admin panel for contract owners:
  - Update gas price
  - Update fee percentage
  - Whitelist tokens
  - Pause/unpause contract
  - Withdraw accumulated fees

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Node.js (v14.0.0 or later)
- npm (v6.0.0 or later)
- Git

## Installation

To install SIP-010 Token Manager, follow these steps:

1. Clone the repository:
   ```
   git clone
   ```

2. Navigate to the project directory:

3. Install the dependencies:
   ```
   npm install
   ```

## Usage

To run the application locally:

1. Start the development server:
   ```
   npm start
   ```

2. Open your web browser and visit `http://localhost:3000`

To build the application for production:

```
npm run build
```

This will create a `build` directory with optimized production-ready files.

## Project Structure

```
src/
├── components/
│   ├── Header/
│   │   ├── Header.js
│   │   └── Header.module.css
│   ├── ContractInfo/
│   │   ├── ContractInfo.js
│   │   └── ContractInfo.module.css
│   ├── TokenActions/
│   │   ├── TokenActions.js
│   │   └── TokenActions.module.css
│   └── AdminPanel/
│       ├── AdminPanel.js
│       └── AdminPanel.module.css
├── hooks/
│   └── useContractState.js
├── utils/
│   └── constants.js
├── App.js
├── App.module.css
└── index.js
```

- `components/`: Contains all React components used in the application
- `hooks/`: Custom React hooks
- `utils/`: Utility functions and constants
- `App.js`: Main application component
- `index.js`: Entry point of the application

## Smart Contract Integration

This UI is designed to work with a SIP-010 compatible token smart contract. To integrate with your specific contract:

1. Update the `CONTRACT_ADDRESS` in `src/utils/constants.js` with your deployed contract address.
2. Implement the blockchain interactions in each component (e.g., in the `handleAction` functions) using a library like `@stacks/transactions`.
3. Update the `useContractState` hook to fetch real contract data from the blockchain.

## Contributing

Contributions to the SIP-010 Token Manager are welcome. Please follow these steps to contribute:

1. Fork the repository
2. Create a new branch
3. Make your changes
4. Commit your changes
5. Push to the branch
6. Create a new Pull Request

Please ensure your code adheres to the existing style and that you've added tests for any new functionality.


For more information about SIP-010 tokens and the Stacks blockchain, visit the [Stacks documentation](https://docs.stacks.co/).

If you encounter any issues or have questions, please file an issue on the GitHub repository.