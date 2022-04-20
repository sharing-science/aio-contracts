
const { ethers } = require("hardhat");

async function main() {
    
    //get the already deployed contract factory instance
    //the application would most likely already have this stored
    const CollabFactory = ethers.getContractAt("CollaborationEvent", "<-DeployedCollaborationAddress->");

    //We lookup the CollaborationEvent instance address via its unique uint256 ID
    //which was returned upon initialization
    const CollabAddress = await CollabFactory._lookupCollab("<-CollabID->");
    //Get CollaborationEvent instance
    const CollabEvent = ethers.getContractAt("CollaborationEvent", CollabAddress);
    //Get the Request IPFS ContentID
    const requestCID = await CollabEvent._getRequestCID();
    
    //We then utilize the Pinata gateway to get the Request JSON
    const url = 'https://gateway.pinata.cloud/ipfs/' + requestCID;
    const requestJSON = await (await fetch(url)).json();
    const intendedUse = requestJSON["Intended Use"]
    

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
