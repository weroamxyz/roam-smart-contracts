import { ethers, run } from "hardhat";

async function main() {
  const args = [
    "RoamNFT",
    "NFT",
    "https://gateway.pinata.cloud/ipfs/QmS4ScUzY254hbX6quUnZSeHibfm1m3bVeyRFc3o3QNYut",
    1000,
  ];

  const instance = await ethers.deployContract("RoamNFT", args, { gasLimit: BigInt("4000000") });

  await instance.waitForDeployment();
  console.log("RoamNFT deployed to:", instance.target);

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
