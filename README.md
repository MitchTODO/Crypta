
![App Pic](pics/appPic.png)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg)
![web3](https://img.shields.io/badge/web3-support-blue.svg?style=flat)
![](https://img.shields.io/badge/platform-iOS-lightgray.svg?style=flat)
![](https://img.shields.io/badge/Language-Solidity-yellowgreen)

# Crypta
Native iOS Mobile Reference Application For Celo DAO/ReFi Management projects.

---

  * [Requirements](#requirements)
  * [Quick Start](#quick-start)
  * [Components](#components)
    + [iOS App](#ios-app)
    + [ Smart Contracts](#📄-smart-contracts)
  * [Future Improvements](#future-improvements)
  * [License](#-licence)

---

## Requirements

- Crypta iOS
    - iOS 15.2+
    - Xcode 13.2.1+
    - Swift 5+
    - Cocoapods

## Quick Start

### iOS App

1. Open your terminal and Git clone the repo

       git clone https://github.com/MitchTODO/Crypta.git

2. Install Podfile

   With the same terminal cd into Crypta2.0 and install

       cd Crypta2.0

       pod install

   If your running on M1 chip use

       arch -x86_64 pod install

   Wait for the pods to install

3. Start Xcode and open up the workspace

A good place

### Smart Contract

Soon to come.
As of now the contract is deployed on Alfajores Testnet and the ABI is still the same.

      Address: 0xa83453C7fB2D22EbA5d87080C76Ba8fb810349f5

## About

This project is a submission for an Gitcoin bounty by the Celo Network. The goal was to develop a native iOS reference application to inspire web3 projects.

## Components

Project consist of two components the App and Smart contract.

### Smart Contract

The smart contract has a DAO style architecture allowing groups, proposals and voting to take place and managed. I feel this contract can easily be extended and is a good starting point for reference.

### Crypta iOS

The app has a simplistic design that can be broken down into three sections views, services and contract.

- Views:    SwiftUI views and viewModels that make up the UI

- Services: async methods and variables that piggy back on the web3swift library.

- Contract: variables that make up the contract, network and wallet



├── Contract
│   ├── ABI
│   ├── Methods
│   ├── Tokens
│   ├── Network
│   ├── Address
│   ├── Wallet
├── Services
│   ├── Web3Services
│   ├── Web3Errors
│   ├── KeyStoreServices
├── Views
├── ...


### Fundimentals

#### How views interact with async contract calls
