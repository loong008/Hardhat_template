import { kMaxLength } from "buffer";
import { Signer } from "ethers";
import { id } from "ethers/lib/utils";
import { ethers, upgrades } from "hardhat";
async function main() {

  const [owner, account1, account2, account3, account4] = await ethers.getSigners();

  const v2Router = '0xD99D1c33F9fC3444f8101754aBC46c52416550D1';
  const v3Router = '0x1b81D678ffb9C0263b24A97847620C99d213eB14';
  const quoterV2 = '0xbC203d7f83677c7ed3F7acEc959963E7F4ECC5C2';

  //部署测试币
  //SPCXB测试币
  // const TSPCXB = await ethers.getContractFactory('TSPCXB');
  // const TSPCXB_C = await TSPCXB.deploy(owner.address);
  // await TSPCXB_C.deployed();
  // console.log("SPCXB测试币: ", TSPCXB_C.address);

  // const TSPCXB_C = await  ethers.getContractAt("TSPCXB","0xeE63fbB9aB49F5C18C04e54ddBB53C8023405f2B");
  // const tx =  await TSPCXB_C.transfer("0xA6b6493AC063c97F99BB40C56c6B595B64187168",ethers.utils.parseEther("1000"));
  // await tx.wait();

  //USDT测试币
  // const TUSDT = await ethers.getContractFactory('TUSDT');
  // const TUSDT_C = await TUSDT.deploy(owner.address);
  // await TUSDT_C.deployed();
  // console.log("USDT测试币: ", TUSDT_C.address);

  //TXClaw测试币
  // const TXClaw = await ethers.getContractFactory('TXClaw');
  // const TXClaw_C = await TXClaw.deploy(owner.address);
  // await TXClaw_C.deployed();
  // console.log("TXClaw测试币: ", TXClaw_C.address);

  const SPCXB = '0xeE63fbB9aB49F5C18C04e54ddBB53C8023405f2B';
  const USDT = '0x328b0C0CFE8381060F927C6ffD7AF4ac3cd5E69A';
  const XClaw = '0xd8bfb5158344450c66434F7652c67803Cd6e2DA9';

  //dividend pool
  // const _XRWA = '0x0000000000000000000000000000000000000000';
  // const DividendPool = await ethers.getContractFactory('DividendPool');
  // const DividendPool_C = await upgrades.deployProxy(DividendPool, [v2Router, v3Router, quoterV2, _XRWA, SPCXB, USDT, owner.address], { kind: 'uups' });
  // // const DividendPool_C = await upgrades.upgradeProxy("", DividendPool, { kind: 'uups' });

  // await DividendPool_C.deployed();
  // console.log("空头持币奖励合约: ", DividendPool_C.address);

  // const DividendPool_C = await ethers.getContractAt("DividendPool", "0x685b65ea677613e99f456B514F8F522753e361dA");

  // const tx = await DividendPool_C.swap();
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  //XRWA
  // const X_RWA = await ethers.getContractFactory('X_RWA');
  // const X_RWA_C = await X_RWA.deploy(owner.address, DividendPool_C.address, v2Router);
  // await X_RWA_C.deployed();
  // console.log("XRWA: ", X_RWA_C.address);
  // console.log("回购XClaw池: ", await X_RWA_C._SwapHelper());

  const X_RWA_C = await ethers.getContractAt('X_RWA', '0xE38fDB36Bd01f1c624f7b2D6752aC6C1d16F867F');

  // const tx = await X_RWA_C.transfer("",ethers.utils.parseEther("1000"));
  // await tx.wait();
  // console.log("tx: ",tx.hash);

  // const tx1 = await X_RWA_C.burn(ethers.utils.parseEther("100"));
  // await tx1.wait();
  // console.log("tx1: ",tx1.hash);


  //设置白名单
  // const tx = await X_RWA_C.setExcludeFee('', false);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  //普通地址交易开关
  // const tx00 = await X_RWA_C.setSSwitch(true);
  // await tx00.wait();
  // console.log("tx00: ", tx00.hash);

  //设置代币操作地址
  const tx01 = await X_RWA_C.setOperator(owner.address, true);
  await tx01.wait();
  console.log("tx01: ", tx01.hash);


  //设置底池通缩时间间隔
  const tx = await X_RWA_C.setBurnInterval(60);
  await tx.wait();
  console.log("tx: ", tx.hash);

  const tx11 = await X_RWA_C.executeLPBurn();
  await tx11.wait();
  console.log("tx11: ",tx11.hash);

  //分红池设置XRWA代币地址
  // const tx0 = await DividendPool_C.setXRWA(X_RWA_C.address);
  // await tx0.wait();
  // console.log("tx0: ", tx0.hash);



  // const SwapHelper_C = await ethers.getContractAt("contracts/token/X-RWA.sol:SwapHelper", await X_RWA_C._SwapHelper());
  // const tx2 = await SwapHelper_C.initailSet(
  //   v2Router,
  //   XClaw
  // );
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const tx3 = await SwapHelper_C.setReceiver(owner.address);
  // await tx3.wait();
  // console.log("tx3: ", tx3.hash);

  //回购池设置操作地址
  // const tx4 = await SwapHelper_C.setOperator(owner.address,true);
  // await tx4.wait();
  // console.log("tx4: ",tx4.hash);

  // 回购池设置滑点
  // const tx4 = await SwapHelper_C.setSlippageBos(9999);
  // await tx4.wait();
  // console.log("tx4: ",tx4.hash);

  // 手动触发回购池回购操作
  // const tx5 = await SwapHelper_C.triggerSwap(ethers.utils.parseEther("10000"));
  // await tx5.wait();
  // console.log("tx5: ",tx5.hash);

  //check--------------------------------------
  // console.log("router:", await SwapHelper_C.router());
  // console.log("v3Router:", await SwapHelper_C.v3Router());
  // console.log("quoter:", await SwapHelper_C.quoter());
  // console.log("XRWA:", await SwapHelper_C.XRWA());
  // console.log("SPCXB:", await SwapHelper_C.SPCXB());
  // console.log("USDT:", await SwapHelper_C.USDT());
  // console.log("XClaw:", await SwapHelper_C.XClaw());
  // console.log("fee:", (await SwapHelper_C.SPCXB_USDT_poolfee()).toString());
  // console.log("operator:", await SwapHelper_C._isOperator(owner.address));

  // for (const address of [
  //   await SwapHelper_C.router(),
  //   await SwapHelper_C.v3Router(),
  //   await SwapHelper_C.quoter()
  // ]) {
  //   console.log(address, await ethers.provider.getCode(address));
  // }

  // const amount = ethers.utils.parseEther("1000");

  // const router = await ethers.getContractAt(
  //   "IUniswapV2Router02",
  //   await SwapHelper_C.router()
  // );

  // const xrwa = await SwapHelper_C.XRWA();
  // const spcxb = await SwapHelper_C.SPCXB();
  // const usdt = await SwapHelper_C.USDT();
  // const xclaw = await SwapHelper_C.XClaw();

  // console.log(
  //   "XRWA -> SPCXB:",
  //   (await router.getAmountsOut(amount, [xrwa, spcxb])).map(String)
  // );

  // console.log(
  //   "USDT -> XClaw:",
  //   (
  //     await router.getAmountsOut(
  //       ethers.utils.parseUnits("1", 18), // 按实际 USDT decimals 修改
  //       [usdt, await router.WETH(), xclaw]
  //     )
  //   ).map(String)
  // );

  // const quoter = await ethers.getContractAt(
  //   "contracts/token/X-RWA.sol:IQuoterV2",
  //   await SwapHelper_C.quoter()
  // );

  // const params = {
  //   tokenIn: spcxb,
  //   tokenOut: usdt,
  //   amountIn: ethers.utils.parseEther("1"), // 按 SPCXB decimals 修改
  //   fee: await SwapHelper_C.SPCXB_USDT_poolfee(),
  //   sqrtPriceLimitX96: 0
  // };

  // const quote = await quoter.callStatic.quoteExactInputSingle(params);
  // console.log("V3 quote:", quote);

  // const routerAddress = await SwapHelper_C.v3Router();
  // const code = (await ethers.provider.getCode(routerAddress)).toLowerCase();

  // const selectorWithoutDeadline = ethers.utils
  //   .id("exactInputSingle((address,address,uint24,address,uint256,uint256,uint160))")
  //   .slice(0, 10)
  //   .toLowerCase();

  // const selectorWithDeadline = ethers.utils
  //   .id("exactInputSingle((address,address,uint24,address,uint256,uint256,uint256,uint160))")
  //   .slice(0, 10)
  //   .toLowerCase();

  // console.log("router:", routerAddress);
  // console.log("without deadline:", selectorWithoutDeadline);
  // console.log("with deadline:", selectorWithDeadline);
  // console.log(
  //   "supports without deadline:",
  //   code.includes(selectorWithoutDeadline.slice(2))
  // );
  // console.log(
  //   "supports with deadline:",
  //   code.includes(selectorWithDeadline.slice(2))
  // );
  //check--------------------------------------








}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
