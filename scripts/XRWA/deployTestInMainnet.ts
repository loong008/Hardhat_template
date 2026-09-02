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

  const v2Router = '0x10ED43C718714eb63d5aA57B78B54704E256024E';
  const v3Router = '0x1b81D678ffb9C0263b24A97847620C99d213eB14';
  const quoterV2 = '0xB048Bbc1Ee6b733FFfCFb9e9CeF7375518e25997';
  const SPCXB = '0xbe9D156892E55e7154BcD3cB0FEA677F9D3103E1';
  const XClaw = '0xD8b3bF4B2ec7be2Bb2D590C378400990AbB2bFCE';
  const USDT = '0x55d398326f99059fF775485246999027B3197955';
  const operator = '0x0D4298224A62f7B7105b670c687103D0Ad79d3DC';

  // const tx = await owner.sendTransaction({
  //   from: owner.address,
  //   to: "0x427c7636F69f9Cfe657881f566F5EfF28e734892",
  //   value: ethers.utils.parseEther("0.01")
  // });
  // await tx.wait();
  // console.log("tx: ",tx.hash);




  //dividend pool
  // const _XRWA = '0x0000000000000000000000000000000000000000';
  // const DividendPool = await ethers.getContractFactory('DividendPool');
  // const DividendPool_C = await upgrades.deployProxy(DividendPool, [v2Router, v3Router, quoterV2, _XRWA, SPCXB, USDT, operator], { kind: 'uups' });
  // // const DividendPool_C = await upgrades.upgradeProxy("", DividendPool, { kind: 'uups' });
  // await DividendPool_C.deployed();
  // console.log("空头持币奖励合约: ", DividendPool_C.address);

  // const DividendPool_C = await ethers.getContractAt("DividendPool", "");

  //XRWA
  // const X_RWA = await ethers.getContractFactory('ABC_RWA');
  // const X_RWA_C = await X_RWA.deploy(owner.address, DividendPool_C.address, v2Router);
  // await X_RWA_C.deployed();
  // console.log("XRWA: ", X_RWA_C.address);
  // console.log("ABC_RWA: ", X_RWA_C.address);
  // console.log("回购XClaw池: ", await X_RWA_C._SwapHelper());

  const X_RWA_C = await ethers.getContractAt('X_RWA', '0x613d099449d3Ef43E62Ece9B38E8246f83b98fD6');
  await waitTx("X-RWA transfer: ",await X_RWA_C.transfer('0x30215990a95DA82ea317Db344b7c9FBFed7f4de1',ethers.utils.parseEther("20000000")))


  //普通地址交易开关
  // const tx00 = await X_RWA_C.setSSwitch(true);
  // await tx00.wait();
  // console.log("tx00: ", tx00.hash);

  //设置代币操作地址
  // const tx01 = await X_RWA_C.setOperator(operator, true);
  // await tx01.wait();
  // console.log("tx01: ", tx01.hash);


  //设置底池通缩的时间间隔
  // const tx = await X_RWA_C.setBurnInterval(60 * 60 * 23);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx0 = await DividendPool_C.setXRWA(X_RWA_C.address);
  // await tx0.wait();
  // console.log("tx0: ", tx0.hash);


  // const SwapHelper_C = await ethers.getContractAt("contracts/token/ABC-RWA.sol:SwapHelper", await X_RWA_C._SwapHelper());
  // const tx2 = await SwapHelper_C.initailSet(
  //   v2Router,
  //   XClaw
  // );
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const tx3 = await SwapHelper_C.setReceiver(owner.address);
  // await tx3.wait();
  // console.log("tx3: ", tx3.hash);

  // const tx4 = await SwapHelper_C.setOperator(owner.address,true);
  // await tx4.wait();
  // console.log("tx4: ",tx4.hash);

  //添加流动性
  // const Router_C = await ethers.getContractAt('IRouter', v2Router);
  // await waitTx("X_RWA_C approve", await X_RWA_C.approve(v2Router, ethers.utils.parseEther('100000')));


  // await waitTx("Add Liquidity", await Router_C.addLiquidityETH(
  //   X_RWA_C.address,
  //   ethers.utils.parseUnits('100000', 18),
  //   0,
  //   0,
  //   owner.address,
  //   100000000000000,
  //   { value: ethers.utils.parseEther("0.001") }
  // ));



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

  // const tx5 = await SwapHelper_C.triggerSwap(ethers.utils.parseEther("1000"));
  // await tx5.wait();
  // console.log("tx5: ",tx5.hash);






}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
