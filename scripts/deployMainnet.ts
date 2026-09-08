import { ethers, upgrades } from "hardhat";

async function waitTx(name: string, txPromise: Promise<any>) {
  const tx = await txPromise;
  await tx.wait();
  console.log(`${name}: ${tx.hash}`);
}

async function main() {

  const [owner, account1, account2, account3, account4] = await ethers.getSigners();




}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
