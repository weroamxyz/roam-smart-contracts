// @ts-ignore
import { NftMigrator, RoamNFT } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { assert } from "chai";
import { ethers, network } from "hardhat";

console.log("=========================");
console.log("Using Network: " + network.name);
console.log("=========================");

describe("Test All", function () {
  let signers: HardhatEthersSigner[];
  before(async () => {
    signers = await ethers.getSigners();
    console.log("signers:", signers[0].address);
  });
  const constructorArgs = [
    "RoamNFT",
    "NFT",
    "https://gateway.pinata.cloud/ipfs/QmS4ScUzY254hbX6quUnZSeHibfm1m3bVeyRFc3o3QNYut",
    "1000",
  ];
  let roamNft: RoamNFT;
  let nftMigrator: NftMigrator;

  const solanaAddress = process.env.SOLANA_ADDRESS || "";
  // Convert to a 32-byte array first, and then to bytes32
  const decodeBase58 = ethers.decodeBase58(solanaAddress);
  const bytes32 = ethers.toBeHex(decodeBase58);
  console.log("bytes32:", bytes32);
  const base58 = ethers.encodeBase58(bytes32);
  console.log("base58:", base58);

  describe("NftMigrator Tests", function () {
    it("should deploy RoamNFT successfully", async function () {
      const instance = await ethers.deployContract("RoamNFT", constructorArgs, {});

      await instance.waitForDeployment();
      roamNft = instance;
      console.log("RoamNFT deployed to:", roamNft.target);
    });
    it("should deploy NftMigrator successfully", async function () {
      const constructorArgs = [roamNft.target];
      console.log("constructorArgs:", JSON.stringify(constructorArgs));
      const instance = await ethers.deployContract("NftMigrator", constructorArgs, {});
      await instance.waitForDeployment();
      console.log("NftMigrator deployed to:", instance.target);
      nftMigrator = instance;
    });

    it("should prepare successfully", async function () {
      assert.isOk(await roamNft.safeMintBatch(signers[0].address, BigInt(10)));
      assert.isOk(await roamNft.setApprovalForAll(nftMigrator.target, true));
    });

    it("should migrate successfully", async function () {
      assert.isOk(await nftMigrator.migrate([1, 2], bytes32));
    });
  });
});
