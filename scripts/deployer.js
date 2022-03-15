async function main() {
    // We get the contract to deploy
    const Collab = await ethers.getContractFactory("CollaborationFactory");
    const collab = await Collab.deploy();
  
}
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });