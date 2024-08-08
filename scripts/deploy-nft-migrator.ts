import { ethers, run } from "hardhat";

async function main() {
  const args = [process.env.ROAM_NFT_ADDRESS || ""];

  const instance = await ethers.deployContract("NftMigrator", args, { gasLimit: BigInt("4000000") });

  // await instance.waitForDeployment();
  console.log("NftMigrator deployed to:", instance.target);

  const timeWait = 15;
  console.log(`waiting for ${timeWait} seconds... to verify contract`);
  await new Promise((resolve) => setTimeout(resolve, timeWait * 1000));
  await run("verify:verify", {
    address: instance.target,
    constructorArguments: args,
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
