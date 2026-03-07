async function main() {

  const Warranty = await ethers.getContractFactory("WarrantyRegistry");

  const warranty = await Warranty.deploy();

  await warranty.waitForDeployment();

  console.log("WarrantyRegistry deployed to:", await warranty.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});