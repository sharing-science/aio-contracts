# aio-contracts
Smart Contracts accompanying the Academic Incentive Ontology

# Basic tutorial setup
## Clone Repo
`git clone https://github.com/sharing-science/aio-contracts.git && cd aio-contracts`

## Install Hardhat
`npm install --save-dev hardhat`

## Create .env file
`touch .env`

## Fill .env with format

```
API_URL = "Alchemy Url"
ACC_1 = "Metamask Address 1"
ACC_2 = "Metamask Address 2"
```

Get Alchemy Url at alchemy.com
    - Sign up
    - 'Create app' - make sure this is on Rinkeby Network, use all other defaults
    - View key
    - Copy HTTP url

Create two temporary Metamask accounts on the Rinkeby network
    - account 1 must have an ETH balance - use https://faucets.chain.link/rinkeby


## Run script
`npx hardhat run scripts/run.js`

