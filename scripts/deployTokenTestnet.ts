import { kMaxLength } from "buffer";
import { Signer } from "ethers";
import { id } from "ethers/lib/utils";
import { ethers, upgrades } from "hardhat";
async function main() {

  const [owner, account1, account2, account3, account4] = await ethers.getSigners();



  //公共参数
  const USDT = '0x38CF198E94ccc9561488869EF38fDd91D7FF62d7';
  const Router = '0xD99D1c33F9fC3444f8101754aBC46c52416550D1';

  //测试币
  const tokenReceiver = '0x6CA929B5dc8fA9daa5A3d3B7eF32620Da3Dc39bA';
  const XClawToken = await ethers.getContractFactory('XClawToken');
  const XClawToken_C = await XClawToken.deploy(tokenReceiver, Router);
  await XClawToken_C.deployed();
  console.log("XClaw: ", XClawToken_C.address);

  // const XClawToken_C = await ethers.getContractAt("XClawToken", "0x5558F974776ce0b1e2c735504642103c19Ed04bb");
  // const tx =await XClawToken_C.transfer('0xcF20dAb8038b7bfaAb1cA491a84906a64e3BDE1E',ethers.utils.parseEther('1000000000'));
  // await tx.wait();
  // console.log("tx: ",tx.hash);

  // const tx = await XClawToken_C.setExcludeFee('0xcF20dAb8038b7bfaAb1cA491a84906a64e3BDE1E',true);
  // await tx.wait();
  // console.log("tx: ",tx.hash);

  // console.log("owner: ",await XClawToken_C.owner());

  // const tx = await XClawToken_C.setSSwitch(false);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx = await XClawToken_C.setBurnInterval(100);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx = await XClawToken_C.setOperator(owner.address,true);
  // await tx.wait();
  // console.log("tx: ",tx.hash);

  // const tx1 = await XClawToken_C.executeLPBurn();
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const balance = await XClawToken_C.balanceOf(owner.address);
  // const tx = await XClawToken_C.burn(balance);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx1 = await owner.sendTransaction({
  //   from: owner.address,
  //   to: '0xcF20dAb8038b7bfaAb1cA491a84906a64e3BDE1E',
  //   value: ethers.utils.parseEther('1'),
  // });
  // await tx1.wait();
  // console.log("tx1: ",tx1.hash);
  // const tx = await XClawToken_C.setSwapTokensAtAmount(ethers.utils.parseEther('2000000'));
  // await tx.wait();
  // console.log("tx: ",tx.hash);


  // const usdt_C = await ethers.getContractAt("TestToken", USDT);

  const router = await ethers.getContractAt('IRouter', Router);


  // const tx1 = await XClawToken_C.approve(router.address, ethers.utils.parseUnits("20000000", 18));
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const tx2 = await router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
  //   ethers.utils.parseUnits("100", 18),
  //   0,
  //   [XClawToken_C.address, USDT],
  //   owner.address,
  //   1776043259
  // );
  // await tx2.wait();
  // console.log("卖出代币交易：", tx2.hash);

  //  const tx2 = await router.swapExactTokensForETHSupportingFeeOnTransferTokens(
  //   ethers.utils.parseUnits("1000", 18),
  //   0,
  //   [XClawToken_C.address, '0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd'],
  //   owner.address,
  //   1776043259
  // );
  // await tx2.wait();
  // console.log("卖出代币交易：", tx2.hash);

  // const tx3 = await usdt_C.approve(router.address, ethers.utils.parseUnits("1000000", 18));
  // await tx3.wait();
  // console.log("tx3: ", tx3.hash);


  // const tx4 = await router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
  //   ethers.utils.parseUnits("1000", 18),
  //   0,
  //   [USDT, TestToken_C.address],
  //   owner.address,
  //   1776043259
  // );
  // await tx4.wait();
  // console.log("买入代币交易：", tx4.hash);

  // const tx4 = await router.swapExactETHForTokensSupportingFeeOnTransferTokens(
  //   0,
  //   ['0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd', XClawToken_C.address],
  //   owner.address,
  //   1776043259,
  //   {value: ethers.utils.parseEther('0.1')}
  // );
  // await tx4.wait();
  // console.log("买入代币交易：", tx4.hash);


  // const tx1 = await XClawToken_C.approve(router.address, ethers.utils.parseUnits("20000000", 18));
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);




  // const tx5 = await router.addLiquidity(
  //   usdt_C.address,
  //   TestToken_C.address,
  //   ethers.utils.parseUnits("1000000", 18),
  //   ethers.utils.parseUnits("2000000", 18),
  //   0,
  //   0,
  //   owner.address,
  //   ethers.BigNumber.from('1776043259')
  // );
  // await tx5.wait();
  // console.log("tx5: ", tx5.hash);


  // const tx1 = await XClawToken_C.approve(router.address, ethers.utils.parseUnits("2500000", 18));
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);
  // const tx5 = await router.addLiquidityETH(
  //   XClawToken_C.address,
  //   ethers.utils.parseUnits("2500000", 18),
  //   0,
  //   0,
  //   owner.address,
  //   ethers.BigNumber.from('1976406863'), { value: ethers.utils.parseEther("1") }
  // );
  // await tx5.wait();
  // console.log("tx5: ", tx5.hash);







}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
