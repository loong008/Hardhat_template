import { kMaxLength } from "buffer";
import { Signer } from "ethers";
import { id } from "ethers/lib/utils";
import { ethers, upgrades } from "hardhat";
async function main() {

  const [owner, account1, account2, account3, account4] = await ethers.getSigners();



  //公共参数
  const USDT = '0x38CF198E94ccc9561488869EF38fDd91D7FF62d7';

  const Router = '0xD99D1c33F9fC3444f8101754aBC46c52416550D1';
  const signer = '0x3cc3c77Ead7dA8a7d77677cC5b02e1919B374FB9';
  const operator = '0x2e78F198B5F7443950300BA0A275181f75E93050';
  const feeReceivers = [owner.address];

  //部署项目代币
  // const tokenReceiver = owner.address;
  // const XClawToken = await ethers.getContractFactory('XClawToken');
  // const XClawToken_C = await XClawToken.deploy(tokenReceiver, Router);
  // await XClawToken_C.deployed();
  // console.log("项目代币XClaw: ", XClawToken_C.address);

  // const TXClaw = await ethers.getContractFactory('TXClaw');
  // const TXClaw_C = await TXClaw.deploy(owner.address);
  // await TXClaw_C.deployed();
  // console.log("项目代币XClaw: ", TXClaw_C.address);

  const TXClaw_C = await ethers.getContractAt('TXClaw', '0x5558F974776ce0b1e2c735504642103c19Ed04bb');
  const tx = await TXClaw_C.transfer('0xd5C4232Fac47F8380940bdAeCb417C958cA76340', ethers.utils.parseEther('6000000'));
  await tx.wait();
  console.log("tx: ", tx.hash);
  // console.log("=> ",await TXClaw_C.swapTokensAtAmount());



  //奖励合约
  // const NodeReward = await ethers.getContractFactory('NodeReward');
  // const NodeReward_C = await upgrades.deployProxy(NodeReward, [signer], { kind: 'uups' });
  // await NodeReward_C.deployed();
  // console.log("节点奖励合约: ", NodeReward_C.address);

  // const tx = await NodeReward_C.putNewFeeReceivers(feeReceivers);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  //静态奖励合约
  // const StaticsReward = await ethers.getContractFactory('StaticsReward');
  // const StaticsReward_C = await upgrades.deployProxy(StaticsReward, [signer], { kind: 'uups' });
  // // const StaticsReward_C = await upgrades.upgradeProxy('',StaticsReward, { kind: 'uups' });
  // await StaticsReward_C.deployed();
  // console.log("静态奖励合约: ", StaticsReward_C.address);

  const StaticsReward_C = await ethers.getContractAt('StaticsReward', '0xCad340A6a94f529dE2b0771d3c16A6a8523e059A');
  //  console.log("=> ",await StaticsReward_C.userRewards('','',))




  // const tx1 = await StaticsReward_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const tx2 = await StaticsReward_C.grantRole(await StaticsReward_C.OPERATE_ROLE(), operator);
  // await tx2.wait();
  // console.log("t2: ", tx2.hash);

  //预售合约
  //预售代币的价格1个BNB多少个代币
  // const tokenAmountPerBnb = ethers.utils.parseEther("250000");
  // 预售费用接受地址
  // const receiver = owner.address;
  // const PreSale = await ethers.getContractFactory('PreSale');
  // // const PreSale_C = await upgrades.deployProxy(PreSale, [tokenAmountPerBnb, NodeReward_C.address, StaticsReward_C.address, receiver, signer], { kind: 'uups' });
  // const PreSale_C = await upgrades.upgradeProxy('0xD90F0Eb0bCac0051e3180506e71F3B6D841A2Df6', PreSale, { kind: 'uups' });
  // await PreSale_C.deployed();
  // console.log("预售合约：", PreSale_C.address);

  // const PreSale_C = await ethers.getContractAt('PreSale', '');

  // const tx = await PreSale_C.setTokenAmountPerBnb(ethers.utils.parseEther("250000"));
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // console.log("totalReservedTokens: ", await PreSale_C.totalReservedTokens());

  // const tx3 = await StaticsReward_C.grantRole(await StaticsReward_C.OPERATE_ROLE(), PreSale_C.address);
  // await tx3.wait();
  // console.log("t3: ", tx3.hash);

  //LP奖励合约
  // const pair = '0x3678c09D1FaCD76577fd64cf63A1fdBE4711ADb8';
  // const rewardToken = '0x5558F974776ce0b1e2c735504642103c19Ed04bb';
  // const wbnb = '0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd';
  // const LpReward = await ethers.getContractFactory('LpReward');
  // // const LpReward_C = await upgrades.deployProxy(LpReward, [pair, rewardToken, wbnb, operator], { kind: "uups" });
  // const LpReward_C = await upgrades.upgradeProxy('0xc44E79b6Cf4530242514161E304d94a9e40C35CC',LpReward, { kind: "uups" });
  // await LpReward_C.deployed();
  // console.log("LP奖励合约: ", LpReward_C.address);

  // //质押合约
  // //质押代币接收地址
  // const stakingReceiver = owner.address;
  // const Staking = await ethers.getContractFactory('Staking');
  // const Staking_C = await upgrades.deployProxy(Staking, [stakingReceiver, signer], { kind: "uups" });
  // await Staking_C.deployed();
  // console.log("质押合约：", Staking_C.address);

  // const tx1 = await Staking_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  //AI用户支付合约
  //用户支付USDT接收地址
  // const receiver = owner.address;
  // const AiPayment = await ethers.getContractFactory('AiPayment');
  // const AiPayment_C = await AiPayment.deploy(receiver, USDT);
  // await AiPayment_C.deployed();
  // console.log("AI用户支付合约: ", AiPayment_C.address);

  // const tx1 = await AiPayment_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);


  //世界杯用户参与合约
  //用户参与费用接收地址
  // const receiver = owner.address;
  // const WorldCupParticipation = await ethers.getContractFactory('WorldCupParticipation');
  // const WorldCupParticipation_C = await WorldCupParticipation.deploy(receiver, signer);
  // await WorldCupParticipation_C.deployed();
  // console.log("世界杯用户参与合约: ", WorldCupParticipation_C.address);

  // const tx1 = await WorldCupParticipation_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // //世界杯用户奖励领取合约
  // const WorldCupRewardPool = await ethers.getContractFactory('WorldCupRewardPool');
  // const WorldCupRewardPool_C = await upgrades.deployProxy(WorldCupRewardPool,[signer,operator],{kind:'uups'});
  // await WorldCupRewardPool_C.deployed();
  // console.log("世界杯用户奖励领取合约: ",WorldCupRewardPool_C.address);

  // const tx2 = await WorldCupRewardPool_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);







}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
