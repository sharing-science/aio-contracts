// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

const { ethers } = require("hardhat");

async function main() {
    // Get owner/deployer's wallet address
    const [addr1, addr2] = await hre.ethers.getSigners();

    // Get contract that we want to deploy
    const contractFactory = await hre.ethers.getContractFactory("CollaborationFactory");

    // Deploy contract with the correct constructor arguments
    const contract = await contractFactory.deploy();

    // Wait for this transaction to be mined
    await contract.deployed();

    // Get contract address
    console.log("Contract deployed to:", contract.address);

    let txn = await contract._addResearcher("Kacy");
    await txn.wait();
    let name = await contract._lookupResCid(addr1.address);
    console.log(name);
    
    txn = await contract.connect(addr2)._addResearcher("Oshani");
    await txn.wait();
    name = await contract._lookupResCid(addr2.address);
    console.log(name);

    const collab = await contract._initCollaboration(addr1.address, addr2.address);
    const receipt = await collab.wait();
    const event = receipt.events.find(event => event.event === 'CollaborationInitialized');
    const id = event.args.CollabId;
    
    let collabadd = await contract._lookupCollab(id);
    console.log("Collaboration at ", collabadd);

    const collabEvent = ethers.getContractAt("CollaborationEvent", collabadd);



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
