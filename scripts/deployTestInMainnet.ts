import { kMaxLength } from "buffer";
import { Signer } from "ethers";
import { id } from "ethers/lib/utils";
import { ethers, upgrades } from "hardhat";
async function main() {

  const [owner, account1, account2, account3, account4] = await ethers.getSigners();



  //公共参数
  const USDT = '0x55d398326f99059fF775485246999027B3197955';

  const Router = '0x10ED43C718714eb63d5aA57B78B54704E256024E';
  const signer = '0x3cc3c77Ead7dA8a7d77677cC5b02e1919B374FB9';
  const operator = '0x2e78F198B5F7443950300BA0A275181f75E93050';
  const feeReceivers = [owner.address];
  console.log("owner: ", owner.address);

  // const usdtInstance = await ethers.getContractAt('XClawToken',USDT);
  // const tx = await usdtInstance.transfer('0xA016db3EE3FdD625b23A7a30Aa5947fbc5FbfA33',ethers.utils.parseEther('10'));
  // await tx.wait();
  // console.log('tx: ',tx.hash);

  //部署项目代币
  // const tokenReceiver = owner.address;
  // const XClawToken = await ethers.getContractFactory('TXClawToken');
  // const XClawToken_C = await XClawToken.deploy(tokenReceiver, Router);
  // await XClawToken_C.deployed();
  // console.log("项目代币XClaw: ", XClawToken_C.address);

  // const TXClaw = await ethers.getContractFactory('TXClaw');
  // const TXClaw_C = await TXClaw.deploy(owner.address);
  // await TXClaw_C.deployed();
  // console.log("项目代币XClaw: ", TXClaw_C.address);

  const XClawToken_C = await ethers.getContractAt('TXClaw', '0xC5f635Ee09a3902B80042159De67b166F5A6e2be');
  const adds = [
    // '0x5CeeB9C03868055437DdA91E42E73f066599305F',
    // '0x9c0cFa60048Bb4747467d16EbC15708540610Dc4',
    // '0x7d9d25119F1037B476Fa4Bc3164CBCEa76f229D6',
    // '0x7dC23C099cFd153A1B31daB243512F9B5e57137a',
    // '0x6906DC61A4FCbFCF6B54F7F1E2539c469e5460E9',
    // '0x9Dd4361e1BCa97a8fD4c213633d24af1DFAEB07f'
    // '0x1E3DF39723c898c13aF7A37Be99111eB4523b787',
    // '0x5558F974776ce0b1e2c735504642103c19Ed04bb',
    // '0xCC0611482F8DCbfAe9b4a9fCe9120275FF760B7E'
    // '0x3f8403Aa652A5a88E521C2109D6Bad2E294dE435'
    // '0xA5a7d234d4a8d6421F18748Eecb9FFBcE44fE8F2'
    // '0xFDA3fFDA3b29be96D5afdbf7Cb63F2355B391336'
    // '0xcB189bE43EF34298970584483Fe6940597eECF7A'
    // '0x24f0841f1A7069306A13E5Bb6146bDc37A92a6fC'
    // '0x48EA0f6Cb62B51700E7a919AF0772bc620094121'
    // '0x4ea49746Cd4eD7D1e3C2A170DA063B6a81953f1C'
    // '0x4C3a28bFD93E5BE6a75A92209E7152054C785A14'
    // '0x5322F9102B377a95e96A8dfeeB4363A72F811714'
    // '0x4ea49746Cd4eD7D1e3C2A170DA063B6a81953f1C'
    // '0x95BA8ACcE4fF6AD6C422ec5FD3E1402876074A11',
    // '0x37878EbB35520D4476853e9c8bE424465bDA7304',
    // '0x272012f0f47c9C2743cAb12ce636f7996d4b18fE',
    // '0xa576AE94932178e906633ce9908cC2690CabEE14',
    // '0x6b472fb8a33cD5B8E4715fC39447f8730Fda8ccE',
    // '0x0839fC8b1880eEb4572A39b9c26b98a7024D6910',
    // '0xDac72a526Ebd6dEA0b34F29aA6BFBAE051C596E1'
    '0x4A75eF44fC7bFEC6D97B4C403f20f1e22ef199E2',
    '0x30215990a95DA82ea317Db344b7c9FBFed7f4de1',
    '0xa7D3153675885c48B6502bA26a1709691993949D'
  ];
  // for (let index = 0; index < adds.length; index++) {
  //   const element = adds[index];
  //   const tx = await XClawToken_C.transfer(element, ethers.utils.parseEther('5000000'));
  //   await tx.wait();
  //   console.log(index, "==============> tx: ", tx.hash);
  // }
  //9978765372.52
  // const tx = await XClawToken_C.burn(ethers.utils.parseEther('9978991042.056213'));
  // await tx.wait();
  // console.log("tx: ",tx.hash);

  // const tx = await TXClaw_C.setSSwitch(true);
  // await tx.wait();
  // console.log("tx: ",tx.hash);




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

  // const StaticsReward_C = await ethers.getContractAt('StaticsReward', '0x5322F9102B377a95e96A8dfeeB4363A72F811714');
  // console.log("=> ",await StaticsReward_C.userRewards('0x8A1233f01B8532A17C1cDb9DCC222C9AA4C3E0f3','0x7d32E3E5eF3b8877b7Cdf4f7f649648f329712CA',6));
  // console.log('nonce: ',await StaticsReward_C.nonces('0x8A1233f01B8532A17C1cDb9DCC222C9AA4C3E0f3'));

  // const tx1 = await StaticsReward_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const tx2 = await StaticsReward_C.grantRole(await StaticsReward_C.OPERATE_ROLE(), operator);
  // await tx2.wait();
  // console.log("t2: ", tx2.hash);

  //预售合约
  //预售代币的价格1个BNB多少个代币
  // const tokenAmountPerBnb = ethers.utils.parseEther("250000");
  // // 预售费用接受地址
  // const receiver = owner.address;
  // const PreSale = await ethers.getContractFactory('PreSale');
  // const PreSale_C = await upgrades.deployProxy(PreSale, [tokenAmountPerBnb, NodeReward_C.address, StaticsReward_C.address, receiver, signer], { kind: 'uups' });
  // // const PreSale_C = await upgrades.upgradeProxy('', PreSale, { kind: 'uups' });
  // await PreSale_C.deployed();
  // console.log("预售合约：", PreSale_C.address);

  // const PreSale_C = await ethers.getContractAt('PreSale', '');

  // const tx3 = await StaticsReward_C.grantRole(await StaticsReward_C.OPERATE_ROLE(), PreSale_C.address);
  // await tx3.wait();
  // console.log("t3: ", tx3.hash);

  //LP奖励合约
  // const pair = '0x35ac0C7344FF094950a29e5Cd852e3512C999A71';
  // const rewardToken = '0x7d32E3E5eF3b8877b7Cdf4f7f649648f329712CA';
  // const wbnb = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
  // const LpReward = await ethers.getContractFactory('LpReward');
  // const LpReward_C = await upgrades.deployProxy(LpReward, [pair, rewardToken, wbnb, operator], { kind: "uups" });
  // // const LpReward_C = await upgrades.upgradeProxy('',LpReward, { kind: "uups" });
  // await LpReward_C.deployed();
  // console.log("LP奖励合约: ", LpReward_C.address);

  //  const LpReward_C = await ethers.getContractAt('LpReward','0x1562B28747454dA54dEFfED8979d54cF239bf86f');
  //  console.log("lp token: ",await LpReward_C.lpToken());

  //质押合约
  //质押代币接收地址
  // const stakingReceiver = owner.address;
  // const Staking = await ethers.getContractFactory('Staking');
  // const Staking_C = await upgrades.deployProxy(Staking, [stakingReceiver, signer], { kind: "uups" });
  // await Staking_C.deployed();
  // console.log("质押合约：", Staking_C.address);

  // const tx4 = await Staking_C.putNewFeeReceivers(feeReceivers);
  // await tx4.wait();
  // console.log("tx4: ", tx4.hash);

  // const tx = await owner.sendTransaction({
  //   from: owner.address,
  //   to: '0x2e78F198B5F7443950300BA0A275181f75E93050',
  //   value: ethers.utils.parseEther("0.01"),
  // });
  // await tx.wait();
  // console.log("tx: ",tx.hash);

  //AI用户GAS费支付合约  
  // Notice: 重新部署AI支付合约，价格需要使用正式环境的
  //用户支付USDT接收地址
  // const receiver = '0xbBeFD13c1609Dc96c846c08d651Cc272f0d1C184';
  // const AiPayment = await ethers.getContractFactory('AiPayment');
  // const AiPayment_C = await AiPayment.deploy(receiver);
  // await AiPayment_C.deployed();
  // console.log("AI用户GAS费支付合约: ", AiPayment_C.address);

  // const AiPayment_C = await ethers.getContractAt('AiPayment', '0xa5A9478119090e138ba4EBA6A9D7690094D79414');

  // const tx0 = await AiPayment_C.setPay1Config(Router, USDT, XClawToken_C.address);
  // await tx0.wait();
  // console.log("tx0: ", tx0.hash);

  // const tx1 = await AiPayment_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // console.log("=> ", await AiPayment_C.getPay1TokenAmount(1));
  // console.log("=> ", await AiPayment_C.getPay1TokenAmount(2));
  // console.log("=> ", await AiPayment_C.getPay1TokenAmount(3));

  // const tx0001 = await XClawToken_C.approve(AiPayment_C.address,ethers.utils.parseEther("1000000000000"));
  // await tx0001.wait();
  // console.log("tx0001: ",tx0001.hash);

  // const tx0002 = await AiPayment_C.pay1(1);
  // await tx0002.wait();
  // console.log("tx0002: ",tx0002.hash);


  //AI用户充值、提现合约
  //用户AI充值费用接受地址
  // const receiver1 = owner.address;
  // const AiVault = await ethers.getContractFactory('AiVault');
  // const AiVault_C = await AiVault.deploy(receiver1, operator;);
  // await AiVault_C.deployed();
  // console.log("AI用户充值、提现合约: ", AiVault_C.address);

  // const AiVault_C = await ethers.getContractAt('AiVault', '0x01E8BF13450DAF2028EE7c29A1bbAB048FcCC93d');

  // const tx2 = await AiVault_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const tx = await AiVault_C.setReceiver('0x2b6B3b729b4D4B1f5da5d228FffED75f137Dc973');
  // const tx = await AiVault_C.setReceiver('0x01E8BF13450DAF2028EE7c29A1bbAB048FcCC93d');
  // await tx.wait();
  // console.log('tx: ', tx.hash);

  //世界杯用户参与合约
  //用户参与费用接收地址
  // const receiver = owner.address;
  // const WorldCupParticipation = await ethers.getContractFactory('WorldCupParticipation');
  // const WorldCupParticipation_C = await WorldCupParticipation.deploy(receiver, signer);
  // await WorldCupParticipation_C.deployed();
  // console.log("世界杯用户参与合约: ", WorldCupParticipation_C.address);

  // const WorldCupParticipation_C = await ethers.getContractAt('WorldCupParticipation', '0xBAca7aB8CBF4a4b183aFdbB1217CDedb64Cf6748');

  // const tx1 = await WorldCupParticipation_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const data = '0x000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000020000000000000000000000005ceeb9c03868055437dda91e42e73f066599305f000000000000000000000000c5f635ee09a3902b80042159de67b166f5a6e2be00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006a32608300000000000000000000000000000000000000000000000ad78ebc5ac620000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000055df400000000000000000000000000000000000000000000000000000000000000417e81e2a69969aa0201deae376f3b2a50e04bd9f05b9efd59ba4102a7f425859824556de6d8e08d492dc6779899422963baf6af8a6b8185077adf5d5c3e76a9651c00000000000000000000000000000000000000000000000000000000000000';
  // const tx = await WorldCupParticipation_C.participate(data);
  // await tx.wait();
  // console.log('tx: ', tx.hash);

  // const tx = await WorldCupParticipation_C.setReceiver('0x1E3DF39723c898c13aF7A37Be99111eB4523b787');
  // await tx.wait();
  // console.log('tx: ', tx.hash);

  // console.log("nonce: ",await WorldCupParticipation_C.nonces(owner.address));

  //世界杯用户奖励领取合约
  // const WorldCupRewardPool = await ethers.getContractFactory('WorldCupRewardPool');
  // const WorldCupRewardPool_C = await upgrades.deployProxy(WorldCupRewardPool,[signer,operator],{kind:'uups'});
  // await WorldCupRewardPool_C.deployed();
  // console.log("世界杯用户奖励领取合约: ",WorldCupRewardPool_C.address);

  // const WorldCupRewardPool_C = await ethers.getContractAt('WorldCupRewardPool', '0x1E3DF39723c898c13aF7A37Be99111eB4523b787');

  // const tx2 = await WorldCupRewardPool_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const data = '0x000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000020000000000000000000000005ceeb9c03868055437dda91e42e73f066599305f000000000000000000000000c5f635ee09a3902b80042159de67b166f5a6e2be00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006a32597c00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000068155a43676e0000000000000000000000000000000000000000000000000000000000000000003ba000000000000000000000000000000000000000000000000000000000000004166431e7f2ba48463a2554ba4e978c4c6e602e16714e9551044cd6e58a4e0e5d43de4d352e91942332e726f72df28890cc0f59b1448770646efcf1fa8c31ebdfd1c00000000000000000000000000000000000000000000000000000000000000';
  // const tx = await WorldCupRewardPool_C.withdraw(data);
  // await tx.wait();
  // console.log('tx: ',tx.hash);


  /* 
    ！！！ 已废弃，不上该功能
  */
  //XClawToken质押合约
  //赎回手续费接收地址
  // const feeReceiver = owner.address;
  // const XClawStaking = await ethers.getContractFactory('XClawStaking');
  // const XClawStaking_C = await upgrades.deployProxy(XClawStaking,[XClawToken_C.address,signer,feeReceiver],{kind:'uups'});
  // await XClawStaking_C.deployed();
  // console.log("XClawToken质押合约: ",XClawStaking_C.address);

  // const tx2 = await XClawStaking_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // //资产包合约
  // const AssetPackage = await ethers.getContractFactory('AssetPackage');
  // // // // const AssetPackage_C = await upgrades.deployProxy(AssetPackage, [XClawToken_C.address, signer, Router, USDT], { kind: 'uups' });
  // const AssetPackage_C = await upgrades.upgradeProxy('0xd376d265A48a4AfB2fC451E4c28f87f0ED466a6c',AssetPackage, { kind: 'uups' });

  // await AssetPackage_C.deployed();
  // console.log("资产包合约：", AssetPackage_C.address);
  //  const AssetPackage_C =  await ethers.getContractAt('AssetPackage','0xd376d265A48a4AfB2fC451E4c28f87f0ED466a6c');
  //  console.log("=> ",await AssetPackage_C.getAmountsOut(ethers.utils.parseEther("10.5")));


  // const tx2 = await AssetPackage_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);


  //算力包合约
  // const ComputingPowerPackage = await ethers.getContractFactory('ComputingPowerPackage');
  // // // const ComputingPowerPackage_C = await upgrades.deployProxy(ComputingPowerPackage, [XClawToken_C.address, signer, Router, USDT], { kind: 'uups' });
  // const ComputingPowerPackage_C = await upgrades.upgradeProxy('0x3deb9f9C52de4b53d2a10C68A8197e1590dbe41B', ComputingPowerPackage, { kind: 'uups' });

  // await ComputingPowerPackage_C.deployed();
  // console.log("算力包合约：", ComputingPowerPackage_C.address);

  // const ComputingPowerPackage_C = await ethers.getContractAt('ComputingPowerPackage','0x3deb9f9C52de4b53d2a10C68A8197e1590dbe41B');
  // console.log("=> ",await ComputingPowerPackage_C.getAmountsOut(ethers.utils.parseEther("1")));

  // const tx2 = await ComputingPowerPackage_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const tx = await owner.sendTransaction({
  //   from: owner.address,
  //   to: '0x4ea49746Cd4eD7D1e3C2A170DA063B6a81953f1C',
  //   value: ethers.utils.parseEther('0.002'),
  // });
  // await tx.wait();
  // console.log("tx: ", tx.hash);


  //X-RWA算力包合约
  const X_RWA = '0x613d099449d3Ef43E62Ece9B38E8246f83b98fD6';
  const ComputingPowerPackage1 = await ethers.getContractFactory('ComputingPowerPackage_RWA');
  const ComputingPowerPackage1_C = await upgrades.deployProxy(ComputingPowerPackage1, [X_RWA, signer, Router, USDT], { kind: 'uups' });
  // const ComputingPowerPackage_C = await upgrades.upgradeProxy('', ComputingPowerPackage, { kind: 'uups' });

  await ComputingPowerPackage1_C.deployed();
  console.log("X-RWA算力包合约: ", ComputingPowerPackage1_C.address);

  const tx2 = await ComputingPowerPackage1_C.putNewFeeReceivers(feeReceivers);
  await tx2.wait();
  console.log("tx2: ", tx2.hash);



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
