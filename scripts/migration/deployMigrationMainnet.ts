import { kMaxLength } from "buffer";
import { Signer } from "ethers";
import { id } from "ethers/lib/utils";
import { ethers, upgrades } from "hardhat";

async function waitTx(name: string, txPromise: Promise<any>) {
  const tx = await txPromise;
  await tx.wait();
  console.log(`${name}: ${tx.hash}`);
}

async function main() {

  const [owner, account1, account2, account3, account4] = await ethers.getSigners();

  //新签名地址
  const signer = '0x4199140f695BE47d19fa0a47d4DF7B0911F4f286';

  //需要更新签名地址的合约
  // const cas = [
  //   { name: "节点奖励合约", ca: "0x5bfE04B1D30903564138c302244Bf7A1dBa76fE9" },
  //   { name: "静态奖励合约", ca: "0x99211AB8D7F95C4Ab238EDcE86EAa0B66dFd5319" },
  //   { name: "质押合约", ca: "0x35F2F75323664765e800BD5b264d49a81d02B8Df" },
  //   { name: "资产包合约", ca: "0x4Ae5224d05340a9467F5F046B4dB4b625287045E" },
  //   { name: "算力包合约", ca: "0x511C3301F4Ae887218ebf7cc0088c4364492c781" },
  //   { name: "X-RWA算力包合约", ca: "0x54C604f8D53daFFDbA8cE43763f0776F3bA491A6" }
  // ];
  // for (const item of cas) {
  //   const ca = item.ca;
  //   const ca_instance = await ethers.getContractAt('NodeReward', ca);
  //   await waitTx(item.name + ": " + ca + "  更新签名地址交易 =>", ca_instance.setSigner(signer));
  // }

  //新操作地址
  const cas1 = [
    { name: "静态奖励合约", ca: "0x99211AB8D7F95C4Ab238EDcE86EAa0B66dFd5319" },
    { name: "LP奖励合约", ca: "0x806f1fE269B0348bB2b2aA547AE3a6d361B9fd21" },
    { name: "AI用户充值、提现合约", ca: "0x9aec0240e3Cae949f22a2e534dA7f410efA20090" }
  ]

  for (const item of cas1) {
    const ca = item.ca;
    const ca_instance = await ethers.getContractAt('StaticsReward', ca);
    await waitTx(item.name + ": " + ca + "  更新操作地址交易 =>", ca_instance.grantRole(await ca_instance.OPERATE_ROLE(), signer));
  }




}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
