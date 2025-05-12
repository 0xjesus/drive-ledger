# Drive-Ledger: Car Data Marketplace on Solana

[![Demo Video](https://img.shields.io/badge/Watch_Demo-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.veed.io/view/9c5cb723-0683-4d26-befe-98ba118c822e?panel=share)

## What We Built

Drive-Ledger is a mobile platform that demonstrates how car owners can monetize their vehicle data through a decentralized marketplace built on Solana. Our implementation includes:

- **Full-featured Flutter mobile app** that simulates OBD-II vehicle data collection
- **Solana-based marketplace** for buying and selling different categories of car data
- **SPL token integration** with Phantom wallet for secure transactions
- **Synthetic vehicle data processing** using DeCharge's OBD-II dataset

[📥 Download APK](https://drive.google.com/file/d/1Ckn5SXT-BdN-3IUsKoMcVkbfrBJGoX4T/view?usp=sharing) | [📱 Request Android Access via Firebase](https://appdistribution.firebase.google.com/pub/i/696ec4a6281b27f9)

## Key Technical Components

### Flutter Application
- Implemented GetX state management for reactive UI and simplified dependency injection
- Built custom visualization widgets for real-time vehicle telemetry data
- Created route-specific simulation profiles (urban, highway, mountain, rural)
- Integrated Phantom wallet through deep linking with secure transaction handling

### Solana Integration
- Deployed custom SPL token (DRVL) on Solana testnet for marketplace transactions
- Implemented Para SDK for non-custodial wallet functionality
- Built transaction generation system for data subscriptions and rewards
- Created secure X25519 encryption for wallet communication

### DeCharge Dataset Implementation
- Processed and enhanced DeCharge's 24-hour synthetic OBD dataset
- Built intelligent simulation engine that applies route-specific variations to the dataset
- Implemented realistic diagnostic trouble code (DTC) integration
- Created data valuation algorithm based on quality metrics from the dataset

### Backend Services
- Built Node.js backend with token reward distribution system
- Implemented marketplace functionality with subscription management
- Created API endpoints for simulation control and data retrieval
- Deployed Prisma-based data model for efficient persistence
- Full backend source code available at [GitHub Repository](https://github.com/0xjesus/drive-ledger-api)
- Live API running at [dl-api.codexaeternum.tech](https://dl-api.codexaeternum.tech)

### Database & API Architecture
- Designed comprehensive MySQL database schema with Prisma ORM
- Created 10+ tables including Users, Simulations, Listings, Subscriptions, Transactions
- Built complete REST API with 20+ endpoints supporting all app functionality:
    - `/api/simulations` - Start, stop, and monitor vehicle simulations
    - `/api/rewards` - Generate and distribute DRVL tokens based on data quality
    - `/api/marketplace/listings` - Create, browse, and purchase data subscriptions
    - `/api/balances/:walletAddress` - Fetch token balance for Solana wallets
    - `/api/marketplace/datatypes` - Query available vehicle data categories
    - `/api/airdrops` - Test token distribution (Solana Testnet only)
- Implemented transaction generation and confirmation systems for Solana

## App Functionality Showcase

### Vehicle Data Simulation
Our app turns any smartphone into a simulated car data node:
- Runs realistic OBD-II data simulation based on DeCharge's dataset
- Visualizes speed, RPM, engine temperature, and location in real-time
- Generates diagnostic trouble codes that affect data value
- Calculates fuel efficiency and performance metrics

### Solana Marketplace
Users can participate in a vehicle data economy:
- Create listings for different data types with customizable pricing
- Subscribe to other drivers' data streams with token payments
- Rate data providers to build reputation system
- View transaction history and manage subscriptions

### Reward System
Our token-based incentive system rewards quality data:
- Urban driving data receives 30% higher rewards
- Diagnostic data with error codes increases value by up to 50%
- High-variation performance data earns 20% more tokens
- Frequent data collection gets a 10% bonus

## Technical Challenges Solved

1. **Secure Wallet Integration**
    - Implemented Phantom wallet deep linking with encryption
    - Built transaction signing and verification system
    - Created token balance tracking and management

2. **Realistic Data Simulation**
    - Enhanced DeCharge's dataset with route-specific variations
    - Created dynamic GPS path simulation with data correlation
    - Implemented realistic engine parameter relationships

3. **Data Value Discrimination**
    - Built algorithm to analyze and price different data types
    - Implemented quality-based reward adjustments
    - Created subscription management with time-based access control

## Screenshots

![Dashboard](https://ag1labs.nyc3.cdn.digitaloceanspaces.com/photo_2025-05-12_13-02-30.jpg)
![Simulation Screen](https://ag1labs.nyc3.cdn.digitaloceanspaces.com/photo_2025-05-12_13-02-31.jpg)
![Marketplace](https://ag1labs.nyc3.cdn.digitaloceanspaces.com/photo_2025-05-12_13-02-29.jpg)
![Wallet Integration](https://ag1labs.nyc3.cdn.digitaloceanspaces.com/photo_2025-05-12_13-02-27.jpg)


---
