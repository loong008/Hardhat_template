import { kMaxLength } from "buffer";
import { Signer } from "ethers";
import { id } from "ethers/lib/utils";
import { ethers, upgrades } from "hardhat";
async function main() {

  const [owner, account1, account2, account3, account4] = await ethers.getSigners();

  /* 
    代币注意点：
    1、lastBurnTime 只是被赋值，没有校验 block.timestamp >= lastBurnTime + BURN_INTERVAL，所以 operator 可以连续调用。
    2、主网测试代币接收地址：0x5FC912732002eB85df6DA71EDE7696A4D550C2ff
  */
 

  //公共参数
  // const USDT = '0x55d398326f99059fF775485246999027B3197955';
  const Router = '0x10ED43C718714eb63d5aA57B78B54704E256024E';

  //测试币
  // const tokenReceiver = '0x5FC912732002eB85df6DA71EDE7696A4D550C2ff';
  // const XClawToken = await ethers.getContractFactory('XClawToken');
  // const XClawToken_C = await XClawToken.deploy(tokenReceiver, Router);
  // await XClawToken_C.deployed();
  // console.log("XClawToken测试币: ", XClawToken_C.address);

  // const XClawToken_C = await ethers.getContractAt('XClawToken', '0x1437C3Bc7d3cCFCDb6cF09FA46ca9A137FB03789');

  // const tx = await XClawToken_C.setOperator(owner.address, true);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx1 = await XClawToken_C.transfer('0x2aD739945C0Dd3F0EBB042A609550C8219b2FFfb', ethers.utils.parseEther('2100000'));
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const tx2 = await XClawToken_C.Gn5sl5NsXTWmHxf(['0xE9e43c5aFA0988a84135a1042505b9Ac0Df007f9','0x7c2E04cA7e7F4140e52be348aEE398A1849058B0','0xBe0eE56aa5DDEe66dcA103998933728996A53eC1'], true);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const tx = await XClawToken_C.setSSwitch(true);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx = await XClawToken_C.setBurnInterval(100);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx1 = await XClawToken_C.executeLPBurn();
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const tx = await XClawToken_C.burn(ethers.utils.parseEther('10000'));
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx = await XClawToken_C.renounceOwnership();
  // await tx.wait();
  // console.log("tx: ", tx.hash);
  //底池lp通缩
  // const tx1 = await XClawToken_C.executeLPBurn();
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const SwaperHelper_C = await ethers.getContractAt('SwapHelper',await XClawToken_C.swapHelper());
  // const tx1 = await  SwaperHelper_C.setLpReceiver('0x1562B28747454dA54dEFfED8979d54cF239bf86f');
  // await tx1.wait();
  // console.log("tx1: ",tx1.hash);
  // console.log("=> ",await SwaperHelper_C.owner());

  // const tx = await SwaperHelper_C.withdrawToken('0x35ac0C7344FF094950a29e5Cd852e3512C999A71',owner.address,ethers.utils.parseEther('0.7'))
  // await tx.wait();
  // console.log("tx: ",tx.hash);


  //lp token
  // const lpToken = await ethers.getContractAt('XClawToken', '0x84C92947002B511030fB4e79b904193d61E918c0');
  // const tx = await lpToken.transfer('0x806f1fE269B0348bB2b2aA547AE3a6d361B9fd21',ethers.utils.parseEther('701.333005'));
  // await tx.wait();
  // console.log("tx: ",tx.hash);







}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
