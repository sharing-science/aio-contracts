async function main() {
    // We get the contract to deploy
    const Greeter = await ethers.getContractFactory("CollaborationFactory");
    const greeter = await Greeter.deploy();
  
}
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });