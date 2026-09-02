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


  /*  
    部署主网需要注意：
    1、部署代币时注意代币的名称与符号,设置代币操作地址
    2、静态奖励合约领取预售代币需要判断是否超过用户预售代币总数量
    3、剩余未部署合约部署不可升级合约

    代币接受地址:
    0x839e088420E1290C2db1ABC3c2DcfE221f471007
    质押合约接受地址：
    0xEA101e2D791Ef0B27283f638a7C24c42139f514a
    手续费usdt 接受地址：
    0xbBeFD13c1609Dc96c846c08d651Cc272f0d1C184
  */

  //批量设置nonces
  const accounts = [
    /* '0x42500C80DFE263e5A72f2B65b558DF569B87C48C',
    '0xcC07f969cfE0ba014124F81E9313eB33A11313fF',

    '0x8E19b38AAD2B6deF4893AbA0D4BB85F4Cbd3F9F8',
    '0x01B3B8AB908737F92E461b7e53975d44421CcFaF',

    '0x91fb19829b1FBbCc2B8a68161204Ec395a6425B5',
    '0x88657aBaa2e03e8E28cD76a41Fd50752888DE678',

    '0x52E9c08F69fcA53Da293241A34323EA8e79ecDd5',
    '0x0bC057FdbbDb3D5c16941DdF0d45D4893f8cBAa9',

    '0xe8B9113668D8Eb156D9206baC1C6D0ec27E5b22C',
    '0x397756D8b070F4Aa835C3804087f469Ec9935937',

    '0xd53319a368D79256904D0b57D27b65bC44D19054',
    '0x6E0098c3F142f322e27a559c33b685255C2175cc',

    '0x5D8DEF25B176346032988fc7ad718AC93a9b173D',
    '0x172FB2F5a4141D6C59893cF669E0abC610576F0f' */
    '0x2257d1d0b6ed243Ca55ff70e5dd77d5C3006e6F6',
    '0x48803Aa3915a040D0fE0B07c472A703441d1d64c'
  ];
  // console.log("accounts: ",accounts);
  //节点nonce
  const nonces1 = [
    /*  1,
     1,
 
     1,
     1,
 
     0,
     0,
 
     0,
     0,
 
     0,
     0,
 
     1,
     1,
 
     0,
     0 */

    0,
    0
  ];
  //静态奖励合约nonce
  const nonces2 = [
    /*   4,
      4,
  
      11,
      11,
  
      0,
      0,
  
      1,
      1,
  
      0,
      0,
  
      2,
      2,
  
      0,
      0 */
    0,
    0
  ];
  //静态奖励合约中地址的推荐奖励待领取金额
  const rewardAmounts = [
    /*  0,
     ethers.utils.parseEther('0.042'),
 
     0,
     ethers.utils.parseEther('1.015'),
 
     0,
     0,
 
     0,
     ethers.utils.parseEther('0.056'),
 
     0,
     0,
 
     0,
     0,
 
     0,
     0 */
    0,
    0
  ];
  //用户配售总额
  const reservedAmounts = [
    /*  0,
     ethers.utils.parseEther('75000'),
 
     0,
     ethers.utils.parseEther('1225000'),
 
     0,
     ethers.utils.parseEther('550000'),
 
     0,
     ethers.utils.parseEther('1225000'),
 
     0,
     ethers.utils.parseEther('175000'),
 
     0,
     ethers.utils.parseEther('50000'),
 
     0,
     ethers.utils.parseEther('1250000') */

    0,
    ethers.utils.parseEther('1250000')
  ];







  //公共参数
  const USDT = '0x55d398326f99059fF775485246999027B3197955';

  const Router = '0x10ED43C718714eb63d5aA57B78B54704E256024E';
  const signer = '0x8e8f941bfdd4e5a95c86e04ec4e3408884378ba4';
  const operator = '0x8e8f941bfdd4e5a95c86e04ec4e3408884378ba4';
  const feeReceivers = ['0xe49b8ec28e630f0d0494f1671cdea8e0899ad8bc', '0x66938e4496aaa934e4973b8c45cbce6c8556242b', '0x3453a0dd1864b4a702e694829ad00716d89e6ed8'];

  // //部署项目代币
  // const tokenReceiver = '0x839e088420E1290C2db1ABC3c2DcfE221f471007';
  // const XClawToken = await ethers.getContractFactory('XClawToken');
  // const XClawToken_C = await XClawToken.deploy(tokenReceiver, Router);
  // await XClawToken_C.deployed();
  // console.log("项目代币XClaw: ", XClawToken_C.address);

  const XClawToken_C = await ethers.getContractAt('XClawToken', '0xD8b3bF4B2ec7be2Bb2D590C378400990AbB2bFCE');

  // const tx0000 = await XClawToken_C.setOperator(operator, false);
  // await tx0000.wait();
  // console.log("tx0000: ", tx0000.hash);
  // console.log("swapHelper: ", await XClawToken_C.swapHelper());

  // const users =
  //   [
  //     '0xf887fCbA361E1655CF095cF8376776D95C30F6a1',
  //     '0xB4a368029A64f53851564C3945A0d8e7A6bfd488',
  //     '0x67a119A02cD154AD48F105D9f42B9921E07ee992',
  //     '0x55BDBC4fFfF08b13A01B0B988b8ED368cb427847',
  //     '0xFd619be4F6313f089220F02DEd077Da2f5aa51D6',
  //     '0x801D06a34B17A9c678529524e824C313FAC83b56',
  //     '0xB5a5BA9915B97C78BFe76299F802451e31A02c97',
  //     '0x7e6F3a5A73c93824b5F72c425C204611b9c2dade',
  //     '0xCe267fE2663D6C0ebC687e1b33F93a6D12333353',
  //     '0xf260978D5d0BEC311d63783919C2A1241c16e45F',
  //     '0x542900c5362536FE4DbF6B35a12F44dA4d7Ec5BB',
  //     '0xF68F99B79561401d72Ea74C9943885F7cae2E479',
  //     '0xaBC47aA929F099Df178d6FB0CaB800a2b27aDb7f',
  //     '0x48C92eC8a18b7632B34dE6Bd41db49D1729F7565',
  //     '0x8D8123a7F13d21c50B578A51397904f3B855D777',
  //     '0x01FB378E8c05B6f7539BcDE33F159a4623238125',
  //     '0x31324D457174d3279EB1a9EFeD49bB8bC5bA2B56',
  //     '0x290a306fb83d8f525B98e2fA95d69c7f8Ef827E7',
  //     '0x274E0e73beCADF825f20A201E39563CA0b89085C',
  //     '0x0bD1d736292093e50032927eF5456A179167898d',
  //     '0x3BE9bE9c978Fb047553c8B2728A6F63fA87Fa426',
  //     '0x66aF21334404eEB5Fb0fd8Dc1100c44273Ce694E',
  //     '0xF722Ae661c1fc00BD0461570F5b3EC8f4dFe76AE',
  //     '0x15c69a1ab726CB4d7992D86488B52E6f0dCe95f6',
  //     '0x01b63115619a852908B9C4A2F7444161c701ae18',
  //     '0x1b139Ba684D20d54114A3C20eCB787968c628498',
  //     '0x9F8A83c919F8A237207F309038dFB87106A46E0f',
  //     '0x6206284723E9381BCc0FDD2e6469496C3aC86F07',
  //     '0x09Ea93Ea1554CBA96A6826FFC73C123e7a80aE4b',
  //     '0x409D91dE38F94D99bF771F46d33e4B9d5c3950Cc',
  //     '0x4e238EE9CB0bCc4787a9977E31bFA8933112814e',
  //     '0x2D1c40A7464003e844cA0C137d68f5351C024A56',
  //     '0xe399B9d1058CBfBdF38c45965484f87133681b19',
  //     '0x3651d4BEBee25a8816c005940CEB7E5A762fe978',
  //     '0x55881c1738d1a9DA1b65c6EA0c4eC23E2225025E',
  //     '0x2ae1127D082e4d5824b2193120993503bE3525bc',
  //     '0xb33eF04D452fAca4BbF6F8eD2b6255Cbe6282A98',
  //     '0xd0B140cc52190A7615551084722B609375F6A022',
  //     '0x51d29AD380e764cD189095cd738003ee8E766e37',
  //     '0x17Ab4206d6a044c3A449647fB8CE8C98f4c5dde8',
  //     '0xF24df8d534fa345990bDA8e9E87E836ea764Ce10',
  //     '0x302595aAbaA9Fdfa0763e7843fC139075626ae1f',
  //     '0x6a7172055847778b5938F89F4c00d806226C331a',
  //     '0x7Df761b3A5cB33a261d7d7Fd646c841d76491F55',
  //     '0xD166061d85e2Ab4Fa8B0e41eCf6B83fe29581969',
  //     '0x841f9D48100A8e53b459A016ff624B960CE0c3F3',
  //     '0xE8fF38BEf9F3Aa46e8476a5018e1C1f9AaFD46f8',
  //     '0x82422393b6b0fF49089aF7973766d5f1f665B7aF',
  //     '0xa76470f82268373130e89532dD6130e4A140957D',
  //     '0x41581a8d99C7845dED7f912fe820d32dB066a71A',
  //     '0xfE9B656C1155f54c56EE87a59c74731Caa201F48',
  //     '0xc7362281E67a3BD2cf25a781139FbEAa4cAAdafc',
  //     '0x2A1f5c2dC3307D2921ba6e1f71E9d1Fc3a4d320c',
  //     '0x1acb9985e9FA35d75Ea3A3C079E9441cA70f2cd7',
  //     '0x1975f14b7f51a3608001286384788aaC9F5D3142',
  //     '0xC85732287Ed6b2A3A56D6280D32c0b3d5e5eB22A',
  //     '0xb2c87681389264E33C00b5589F0B39C90dc68636',
  //     '0xE20d0FC1AcB633fad24FB61755003E0336B116e1',
  //     '0x4F49E3ac7c5328B0F4770aB6cDaf6A9F761714EB',
  //     '0x7f537C3CC0Fb8aBE9Fcd5Eb3E096d460ee6a4000',
  //     '0x182e8A9967F3871AfF1c3AfDAc9254fE5C2aE6F5',
  //     '0x392cf683Ed958a0360b448E4d48D17e055Fb2FaA',
  //     '0x4f5EEF0953532d846ba71031A479bCb4C7D36f1f',
  //     '0x31C4FbC326b3e2E68F3bC05E4177609aCB24b9Ef',
  //     '0xb7e3c67C96Aa76A9c27227FfF1e4d6489137c48b',
  //     '0x6c96b88257dAeFa7bab2DFb439dCec3E8A43B1FD',
  //     '0xD7eADAc35b1125d6d127cd5Ca53763Ff3054B589',
  //     '0x0D91b804959E790eC0Ea56bBf9449eb7e106a12d',
  //     '0xfe6f7DB351d21dE050b9F8f95C6d59A8bBf5632D',
  //     '0xd46919bC676dBb36f9f00168aB413537FF9BbB37',
  //     '0x057d30D13B58EEFc0397298e30eAa1D4173c949a',
  //     '0xbBDD2957EBAEc08fEeAEc51e7404855e017c5430',
  //     '0xDD7931747e29e09838241778f1B7CD427d64895a',
  //     '0x1113341c218b403145daF521c017662F71cAaC43',
  //     '0x99297475525fA7381431a1e58B8E5354c614665F',
  //     '0xe0679D626E8F994A07207E9FFCe15FF734F30ADF',
  //     '0x608830f3803A8A90E7720F646535Fd89b230F419',
  //     '0x5d4Fb87b14B78271c0e3B7AB1d5da79C92d43aBE',
  //     '0x6992dA703a23cfb34D7A657f47dB0991b8cD0b14',
  //     '0x9c5dcD7E317DBD0FFd3E1f00bDD8136Ea678Db65',
  //     '0xa075cbf8ceb379314e2b41DC6Dc7df9D96D75cA5',
  //     '0x6FcDFB6eaFFf9abA643E9BA7E3B4e07eDfA60550',
  //     '0xC71CCF1fe294daC4eC6A1441c3Be29338A375329',
  //     '0x46F547A4202a94610729cd98b8fE300731FbfD6F',
  //     '0x16165c767DcD581db8e3Ae3DFa9C0A35CDAb6b26',
  //     '0x02F1E8739b5C7ec862cDcbe55c9d1987db8DA7fA',
  //     '0xFE50559DB4c693A1D4A8a77235F57340Df8586a6',
  //     '0xFA2891a0d3a961ab07eDB8767a6516DABdC348D3',
  //     '0x6E9eF41CaaD8f9753B57118a31091b5C14480732',
  //     '0x28eD03173a37641b749aFDF0866C13dD83B0E0D9',
  //     '0xDFd94dEF25712085a4D2db9A01fB8A47243A8281',
  //     '0x4544D4A82486f1c996FEC0cd96Eb2045415BDD55',
  //     '0x2e5462915B84f79E015F40C81F420b1fF9a6fF0C',
  //     '0x98FB83A35CdB345dfa275817435C1D007F326C1C',
  //     '0xFb9a04E69635176A8801CA5a1eA0BF6B49ccd9d6',
  //     '0xfbB88454a2cc63b8d7A69fCA1C777C5FfEB824C9',
  //     '0x03E05fED2C853aB66e429b50132f1F353412614a',
  //     '0xD288e02303598E3Cf3af924435D1fA0bc3500A01',
  //     '0x9C93b36DFECAb1e330D847855eD7a6d46EdbCB84',
  //     '0xc52c15b73e08073c83c2ec2a09F19bfB38Ab5D30',
  //     '0x3a56D36f7058172267d2884ed02eB1863bc27a3b',
  //     '0x6817C7588879f155c5a82484f82C6EE98203a240',
  //     '0x5A134E73EFc9EC5A9A56771D4Fa45F07Fad2F9ad',
  //     '0x42442AF1f48840e2e5F491FCb6f60aCd91F4F3Cb',
  //     '0x9cD779a7EFe6c0327827eCcACf7959F43497E991',
  //     '0xeD5d51C867efb25194035A63C839cdDFF37D1446',
  //     '0x161194227dbaf8be601Aa7322ecA987d3E9Af90f',
  //     '0x44D67cb1448F4D7a346AbCea79f4ffc44325598A',
  //     '0x29E0dd848A5a3c1c6bB556dd9eA902017799533c',
  //     '0xE49AB0b444E4c03dE36A1eF0A83C006310dc8516',
  //     '0xc8a0be52e16AF493552669f401631fc5886e0bcd',
  //     '0x78562a80E30388F609CE8ca1861034EB19307d03',
  //     '0x8f757c835a8DE5AD112832261d52A9CbeD0bD8A3',
  //     '0x2393Afcd14426BbcaE201370689046A024459745',
  //     '0xBD2390469D63cE56172A2e2302CEcba3651743c4',
  //     '0x10F8F053dE472c5439D53db5D6Cec68057F80c7E',
  //     '0xD752cE7423859C35A690125Ba808b7044c807724',
  //     '0x6346C43338D40F0b2F815609516a4bD0D7E21759',
  //     '0x6d656c9b16617D8b6b57CC804979D58aC7431c76',
  //     '0x6fC225981bE8d4EF5aD97Cbca21D7a0eE01Aa1FC',
  //     '0x9db04b1A313502761160F475d8f757ec98721F7d',
  //     '0x63Cf72A7c184A111F02ee0659f6EEe89e78EE8b6',
  //     '0x178c4566cd392C690AdfB457d972Fc8D9655C95d',
  //     '0xF4644c495cBa2d9daE1F0e046E00150176098d08',
  //     '0x38D55958C2aF7599d631D3C9e52D59AC18f1f6Cf',
  //     '0x014662cCd99766b3C699171A6726B6760399715b',
  //     '0xdEbD13fC11C4dfbFa48C7Db273f143299d91f35c',
  //     '0xceC65f649Bb395C2FFa07D9C0F586Da0e2Eac937',
  //     '0x9dE7B4778D5B1637ED7DdE20DaA9FA0e3A39a26E',
  //     '0xD45c212B1451bDeE93D71c04a6346b11170453D4',
  //     '0xBd0888caaC0baBd44AE724a8eCb0360a6b70B561',
  //     '0xd973d976BcE98EA722646AfD093a6Ff7D5380F4F',
  //     '0xE0A07b49764091Af2Fb131590423c8ec13729AD5',
  //     '0xfb60240557b56F5a61787F675e32cA0C9bA7e3dA',
  //     '0xd761372a0EAd56C58eB3f63053030CCBA0d74C0D',
  //     '0x7A7407061DAAc4E25FD18150a67C1352628Cacb2',
  //     '0x98B1Bb18Cf2d94F7D0707bF95094c91bB582780f',
  //     '0x4608c1dD06f23D0c92460368c120B9f7d16EB96E',
  //     '0xceECfe0c5319bcD455Ee3f59D9E37c793495DC16',
  //     '0x4Bf8141Ca15c15b4AebB24f448cc7Fc85b9bf5D2',
  //     '0x61336ABe1E452526FA4fc11a44aE7F7944bB06aa',
  //     '0x4B114ecF9612ad952FC1c75543d7E1d0B9F78a16',
  //     '0xa7aa1deA084320B5Fce83b9bbda53527bfd33625',
  //     '0xf4dCcdF4C897Fda1d64ceA5bE438aCFF31A4758D',
  //     '0xc69035596a6541479C94e6Ebc243c850d256FA57',
  //     '0x8572e736933E803754AD4b027e1Ed86C620E1538',
  //     '0x87D05e6E5894FA57c976aB7B3015Cf67Afd08465',
  //     '0x0A039aE1c105D8533A400CD2130B75665058e351',
  //     '0x9348c10535636F0e5d219d0840b82F3A1b53b498',
  //     '0xFB84b7D9835DD9Be85dbDBFE5E946f9041CBEb7A',
  //     '0xa72DBc110BC171aAE05d29f55Cd9869b07e0373A',
  //     '0x2cd2A9bD1C8E5Cd803814c0C1bDfB659A4c4A232',
  //     '0x40945420fDD70A3024BE0F5187e08A3615dc6EF4',
  //     '0x4Fc9756f0319535db1E9373a029649b6B5b0963D',
  //     '0xf966856E509f97841f924bAC73C5615ADd3C04c8',
  //     '0x502312a057Fec2Ff634bDc3ce257ceAB42Ab0dc8',
  //     '0xcffd1975f3b0CC7B0A8efc612b77fF02f0744C11',
  //     '0x40870ad65528c707f5671aCEEDcdFEA8F5106a22',
  //     '0xc09A0F241A854C9489d834fb0DF4E9fe08b49dCC',
  //     '0x83b19088084DBd72Dc84a7360c3Feff89BC92222',
  //     '0x0D988F8f5eeD562ce3CE939089f9a52Db270cC22',
  //     '0x921505d89D6ADc4fAC0Bbd3Ee7578f98C585b5D8',
  //     '0xdc216cd508CD6B9B2b38538c5aA8539Ca08d4bA7',
  //     '0xc2Be3ED8462FD4d74C083bE96eA758Bcf68d504F',
  //     '0xc42f5D6E582bA7ecee351cf65F29d551df3FC7C1',
  //     '0xAA4392f943380629b51cdF1497Ce67B17687946c',
  //     '0xaf2751E8d2faD0fba48302bFE136796b64A00B33',
  //     '0xaFa33c51A65487517aAF0Be6A91979946B1A3134',
  //     '0x56477dBF149e13950788b8FC47E8Fc723031f120',
  //     '0x471c50F79cB0C1C938B8e9aBFbfC65a8ab116D3b',
  //     '0x5D9c3B43439Bbf7AF0E579606dC50d8C01EF0b2C',
  //     '0x816903ad4Afa04a3772061c85c3352A902C69732',
  //     '0x9D7CcD611170140Bce859dBb62Be073F4Bb7b74c',
  //     '0x62F8620Ac164A2EEb8c67783CE48E12B2F7A0655',
  //     '0xa1a9E107Db59f10000aCDAaF96e6Dd159dA58E79',
  //     '0xd6AC1B6941d58957b88A00fA1f56C1934D531e9e',
  //     '0x9D733787cBa1F8C1aD7949915b824c2afD155201',
  //     '0xC53E6E1af9F69835595BbEf1dE25dE478e5CE15e',
  //     '0x17b34d31ea121d269b9c9721478092bC4B7646ED',
  //     '0x99932953590e3361356A6F2b719F3DEDd69eECa3',
  //     '0x22c5C1CDC6b7C8586deB522787560ee6FE9f9c44',
  //     '0xa5eD06D23517d025e279d69A6Da4171992f47a7b',
  //     '0x9fD1127724fB81A12c0b4EeF2D80CDb41c57DfAA',
  //     '0xa2785A0CF23fb4A4102004b2239D2F9b819F04F9',
  //     '0xC131656C828E8CB3b20def28205aB11d9A37cf6e',
  //     '0x8306BC72Cab9eDdb99A9e5bAE50Fa9F5482E0189',
  //     '0x96dbE386321f3f20cef3a4f9eD58D0aC6c86C208',
  //     '0x51843Fb6E48F66682227D2612EF6B4eaaFcd7fEA',
  //     '0x273d14E3da14895db8ea918e5744537A2B0CF589',
  //     '0x2F7aC266D84bC715878A395D16046EcE7d896A27',
  //     '0x671657852f01452598aFbd91998ef47A9e56DC92',
  //     '0xc2983C7e58AD0a37167f80fE9f300a5c2c984f56',
  //     '0xe229Ccd17b11ceFcA173a8f217E2b81d16fF00b6',
  //     '0x3d9165aD9984439e88A3C1b062557eddB4FeacCB',
  //     '0x4421DF99a0faCe748da4Ca1A56883dFd12278B57',
  //     '0xA1c90b6e2DEaf97f7fEd0203d7a43e30c7Cb5199',
  //     '0x72903076811D865c098ED70506496b8075c46600',
  //     '0x31586d7d50Bdd37e739bB818f5DCb3De525caAe7',
  //     '0xCADe4537dd84bD620a3215750d3DFF50D673c810',
  //     '0x4dFAd3882C353ECADc7cF08ef31F034F2F993469',
  //     '0x7C7cC5649DcD747796B28D6dc8663AC7156A19bF'

  //   ]
  // const tx0000 = await XClawToken_C.batchSetExcludeFee(users, true);
  // await tx0000.wait();
  // console.log("tx0000: ", tx0000.hash);

  //打开交易开关
  // const tx0000 = await XClawToken_C.setSSwitch(true);
  // await tx0000.wait();
  // console.log("tx0000: ", tx0000.hash);

  // const tx0000 = await XClawToken_C.transfer('0xB3C94D7020f2fD3b43100CCA5b93E482831ba05b',ethers.utils.parseEther('1000'));
  // await tx0000.wait();
  // console.log("tx0000: ", tx0000.hash);

  // const tx00001 = await XClawToken_C.renounceOwnership();
  // await tx00001.wait();
  // console.log("tx00001: ", tx00001.hash);


  //奖励合约
  // const NodeReward = await ethers.getContractFactory('NodeReward');
  // // // const NodeReward_C = await upgrades.deployProxy(NodeReward, [signer], { kind: 'uups' });
  // const NodeReward_C = await upgrades.upgradeProxy('0x5bfE04B1D30903564138c302244Bf7A1dBa76fE9', NodeReward, { kind: 'uups' });
  // await NodeReward_C.deployed();
  // console.log("节点奖励合约: ", NodeReward_C.address);

  const NodeReward_C = await ethers.getContractAt('NodeReward', '0x5bfE04B1D30903564138c302244Bf7A1dBa76fE9');

  // const tx = await NodeReward_C.putNewFeeReceivers(feeReceivers);
  // await tx.wait();
  // console.log("tx: ", tx.hash);

  // const tx = await NodeReward_C.withdrawBNB('0xD735a18761C6A5634Ef3106cc297BfC2cD862D40',ethers.utils.parseEther('2.7'));
  // const tx = await NodeReward_C.withdrawBNB('0x42426c357AdABd95871eF0Df1B83cDC41b8DAa1B',ethers.utils.parseEther('3.4'));
  // const tx = await NodeReward_C.withdrawBNB('0x5250D16032BE49b04374933bBfc3Ad427B29b673',ethers.utils.parseEther('2.68'));
  // const tx = await NodeReward_C.withdrawBNB('0x9F4cDeA275f658F7C50044e83408e0e1277Dd8a6',ethers.utils.parseEther('0.2976'));
  // const tx = await NodeReward_C.withdrawBNB('0x9d06cCB87F2f7e579c715C8143b877F3BA254817',ethers.utils.parseEther('0.2976'));
  // const tx = await NodeReward_C.withdrawBNB('0xEf5158132BFc4B04f38A895135924d9dc359Db1A',ethers.utils.parseEther('2.68'));
  // const tx = await NodeReward_C.withdrawBNB('0x917872F43d918c5Be99A640c77601c2ecC99Ca97',ethers.utils.parseEther('0.298'));
  // const tx = await NodeReward_C.withdrawBNB('0x7790a902dC693881BA55d5DC9AC63394bD936AeB',ethers.utils.parseEther('6.5'));
  // const tx = await NodeReward_C.withdrawBNB('0x99986a91c2b1ba794914dB9b54EE55c698c25af6',ethers.utils.parseEther('6.5'));

  // const tx = await NodeReward_C.withdrawBNB('0x1Be7884a056C9E22F0539784409bc9c874CbcC31',ethers.utils.parseEther('41.424308372189800001'));
  // await tx.wait();
  // console.log("tx: ",tx.hash);



  // const tx0001 = await NodeReward_C.batchtSetNonces(accounts, nonces1);
  // await tx0001.wait();
  // console.log("节点合约设置nonce tx: ", tx0001.hash);

  //静态奖励合约
  // const StaticsReward = await ethers.getContractFactory('StaticsReward');
  // // const StaticsReward_C = await upgrades.deployProxy(StaticsReward, [signer], { kind: 'uups' });
  // const StaticsReward_C = await upgrades.upgradeProxy('0x99211AB8D7F95C4Ab238EDcE86EAa0B66dFd5319', StaticsReward, { kind: 'uups' });
  // await StaticsReward_C.deployed();
  // console.log("静态奖励合约: ", StaticsReward_C.address);

  // const StaticsReward_C = await ethers.getContractAt('StaticsReward', '0x99211AB8D7F95C4Ab238EDcE86EAa0B66dFd5319');
  // console.log("=> ",await StaticsReward_C.nonces('0x403a893c46e3299e0460d72af4731efea4a6d2ca'));
  // console.log("=> ",await StaticsReward_C.userRewards('0x403a893c46e3299e0460d72af4731efea4a6d2ca','0xD8b3bF4B2ec7be2Bb2D590C378400990AbB2bFCE',8));
  // console.log("=> ",await StaticsReward_C.withdrawAmounts('0x403a893c46e3299e0460d72af4731efea4a6d2ca','0xD8b3bF4B2ec7be2Bb2D590C378400990AbB2bFCE',8));

  // const tx1 = await StaticsReward_C.withdrawBNB('0x1Be7884a056C9E22F0539784409bc9c874CbcC31',ethers.utils.parseEther('11.208'));
  // await tx1.wait();
  // console.log("tx1: ",tx1.hash);

  // const tx0002 = await StaticsReward_C.setParams('0xA15A4a362F57054c93613bf0ece26B0E6215ACAB', XClawToken_C.address);
  // await tx0002.wait();
  // console.log("tx0002: ", tx0002.hash);


  // const tx1 = await StaticsReward_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const tx2 = await StaticsReward_C.grantRole(await StaticsReward_C.OPERATE_ROLE(), operator);
  // await tx2.wait();
  // console.log("t2: ", tx2.hash);


  // const tx0002 = await StaticsReward_C.batchtSetNonces(accounts, nonces2);
  // await tx0002.wait();
  // console.log("静态奖励合约设置nonce tx: ", tx0002.hash);


  // const tx0003 = await StaticsReward_C.batchAddUserReward1(accounts, '0x0000000000000000000000000000000000000000', 2, rewardAmounts);
  // await tx0003.wait();
  // console.log("静态奖励合约设置推荐奖励金额 tx: ", tx0003.hash);

  //预售合约
  //预售代币的价格1个BNB多少个代币
  // const tokenAmountPerBnb = ethers.utils.parseEther("250000");
  // // 预售费用接受地址
  // const receiver = '0x52921A3f202e60404250257A779Ac2f6e3E88aFA';
  // const PreSale = await ethers.getContractFactory('PreSale');
  // // // const PreSale_C = await upgrades.deployProxy(PreSale, [tokenAmountPerBnb, NodeReward_C.address, StaticsReward_C.address, receiver, signer], { kind: 'uups' });
  // const PreSale_C = await upgrades.upgradeProxy('0xA15A4a362F57054c93613bf0ece26B0E6215ACAB', PreSale, { kind: 'uups' });
  // await PreSale_C.deployed();
  // console.log("预售合约：", PreSale_C.address);

  // const tx3 = await StaticsReward_C.grantRole(await StaticsReward_C.OPERATE_ROLE(), PreSale_C.address);
  // await tx3.wait();
  // console.log("t3: ", tx3.hash);

  const PreSale_C = await ethers.getContractAt('PreSale', '0xA15A4a362F57054c93613bf0ece26B0E6215ACAB');

  // console.log("=> ",await PreSale_C.reservedTokens('0x403a893c46e3299e0460d72af4731efea4a6d2ca'));

  // const tx = await PreSale_C.setFuncSwitch(false);
  // await tx.wait();
  // console.log("tx: ", tx.hash);


  // const tx0004 = await PreSale_C.batchSetReservedTokens(accounts, reservedAmounts);
  // await tx0004.wait();
  // console.log("预售合约设置预售代币数量 tx: ", tx0004.hash);


  // //LP奖励合约
  // const pair = await XClawToken_C.mainPair();
  // console.log("pair: ", pair);

  // const tx0001 = await owner.sendTransaction({
  //   from: owner.address,
  //   to: operator,
  //   value: ethers.utils.parseEther("0.001")
  // });
  // await tx0001.wait();
  // console.log('tx0001: ', tx0001.hash);

  // const rewardToken = XClawToken_C.address;
  // const wbnb = await XClawToken_C.wbnb();
  // const LpReward = await ethers.getContractFactory('LpReward');
  // const LpReward_C = await LpReward.deploy(pair, rewardToken, wbnb, operator);
  // await LpReward_C.deployed();
  // console.log("LP奖励合约: ", LpReward_C.address);

  // const SwapHelper_C = await ethers.getContractAt('SwapHelper', await XClawToken_C.swapHelper());
  // const tx0001 = await SwapHelper_C.setLpReceiver(LpReward_C.address);
  // await tx0001.wait();
  // console.log("tx0001: ", tx0001.hash);

  // //质押合约
  // //质押代币接收地址
  // const stakingReceiver = '0xEA101e2D791Ef0B27283f638a7C24c42139f514a';
  // const Staking = await ethers.getContractFactory('Staking');
  // const Staking_C = await Staking.deploy(stakingReceiver, signer);
  // await Staking_C.deployed();
  // console.log("质押合约：", Staking_C.address);

  // const tx1 = await Staking_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  /* 
    Notice: 重新部署AI支付合约，价格需要使用正式环境的
  */
  /* //AI用户支付合约
  //用户支付USDT接收地址
  // const receiver = '0xbBeFD13c1609Dc96c846c08d651Cc272f0d1C184';
  // const AiPayment = await ethers.getContractFactory('AiPayment');
  // const AiPayment_C = await AiPayment.deploy(receiver);
  // await AiPayment_C.deployed();
  // console.log("AI用户支付合约: ", AiPayment_C.address);

  // const tx1 = await AiPayment_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash); */

  //AI用户GAS费支付合约  
  // Notice: 重新部署AI支付合约，价格需要使用正式环境的
  //用户支付USDT接收地址
  // const receiver = '0x2DFf135bc8A4Ee8B619f582b5bE0c16a028DF7f9';
  // const AiPayment = await ethers.getContractFactory('AiPayment');
  // const AiPayment_C = await AiPayment.deploy(receiver);
  // await AiPayment_C.deployed();
  // console.log("AI用户GAS费支付合约: ", AiPayment_C.address);

  const AiPayment_C = await ethers.getContractAt('AiPayment', '0x0E890f97537ea0eDe756303b9dc63558Ecf32E84');

  // const tx0 = await AiPayment_C.setPay1Config(Router, USDT, XClawToken_C.address);
  // await tx0.wait();
  // console.log("tx0: ", tx0.hash);

  // const tx1 = await AiPayment_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const tx1 = await AiPayment_C.setTypePrices(1, 29);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);

  // const tx2 = await AiPayment_C.setTypePrices(2, 1690);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const tx3 = await AiPayment_C.setTypePrices(3, 12990);
  // await tx3.wait();
  // console.log("tx3: ", tx3.hash);

  // AI用户充值、提现合约
  // 用户AI充值费用接受地址
  // const receiver1 = '0xa137A795e420641097C26016f1D79349794e2d74';
  // const receiver1 = '0xa137A795e420641097C26016f1D79349794e2d74';
  // const AiVault = await ethers.getContractFactory('AiVault');
  // const AiVault_C = await AiVault.deploy(receiver1, operator);
  // await AiVault_C.deployed();
  // console.log("AI用户充值、提现合约: ", AiVault_C.address);

  const AiVault_C = await ethers.getContractAt("AiVault", "0x9aec0240e3Cae949f22a2e534dA7f410efA20090");

  // const tx2 = await AiVault_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  await waitTx("AiVault_C Withdraw USDT: ", await AiVault_C.withdrawErc20(USDT, "0xf887fCbA361E1655CF095cF8376776D95C30F6a1", ethers.utils.parseEther("347.916211563183851231")));




  //世界杯用户参与合约
  //用户参与费用接收地址
  // const WorldCupParticipation = await ethers.getContractFactory('WorldCupParticipation');
  // const WorldCupParticipation_C = await WorldCupParticipation.deploy(signer);
  // await WorldCupParticipation_C.deployed();
  // console.log("世界杯用户参与合约: ", WorldCupParticipation_C.address);

  // // const WorldCupParticipation_C = await ethers.getContractAt('WorldCupParticipation', '');

  // const tx1 = await WorldCupParticipation_C.putNewFeeReceivers(feeReceivers);
  // await tx1.wait();
  // console.log("tx1: ", tx1.hash);



  //世界杯用户奖励领取合约
  // const WorldCupRewardPool = await ethers.getContractFactory('WorldCupRewardPool');
  // const WorldCupRewardPool_C = await upgrades.deployProxy(WorldCupRewardPool, [signer, operator], { kind: 'uups' });
  // await WorldCupRewardPool_C.deployed();
  // console.log("世界杯用户奖励领取合约: ", WorldCupRewardPool_C.address);

  // // const WorldCupRewardPool_C = await ethers.getContractAt('WorldCupRewardPool', '');

  // const tx2 = await WorldCupRewardPool_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const tx3 = await WorldCupParticipation_C.setReceiver(WorldCupRewardPool_C.address);
  // await tx3.wait();
  // console.log("tx3: ", tx3.hash);



  //资产包合约
  // const AssetPackage = await ethers.getContractFactory('AssetPackage');
  // const AssetPackage_C = await upgrades.deployProxy(AssetPackage, [XClawToken_C.address, signer, Router, USDT], { kind: 'uups' });
  // // const AssetPackage_C = await upgrades.upgradeProxy('',AssetPackage, { kind: 'uups' });
  // await AssetPackage_C.deployed();
  // console.log("资产包合约：", AssetPackage_C.address);

  const AssetPackage_C = await ethers.getContractAt('AssetPackage', '0x4Ae5224d05340a9467F5F046B4dB4b625287045E')

  // const tx2 = await AssetPackage_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);

  // const tx = await AssetPackage_C.buy('0x000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000ccc0f2aee30202dad6129682957f91190012946200000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006a52082e0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000002b5e3af16b1880000000000000000000000000000000000000000000000000178c112daddc1f7b02d00000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000041721a048f602c0751284d7ca51267fa1008ed20253847c9e06f7e8c0e1a089a341dde0f8820736e4f8a2cb928cfda82db5c9ca68c26ee9788e9a953cb6ee0fb3f1b00000000000000000000000000000000000000000000000000000000000000');
  // await tx.wait();
  // console.log("tx: ",tx.hash);


  //算力包合约
  // const ComputingPowerPackage = await ethers.getContractFactory('ComputingPowerPackage');
  // const ComputingPowerPackage_C = await upgrades.deployProxy(ComputingPowerPackage, [XClawToken_C.address, signer, Router, USDT], { kind: 'uups' });
  // // const ComputingPowerPackage_C = await upgrades.upgradeProxy('', ComputingPowerPackage, { kind: 'uups' });

  // await ComputingPowerPackage_C.deployed();
  // console.log("算力包合约：", ComputingPowerPackage_C.address);


  // const tx2 = await ComputingPowerPackage_C.putNewFeeReceivers(feeReceivers);
  // await tx2.wait();
  // console.log("tx2: ", tx2.hash);



  //X-RWA算力包合约
  // const X_RWA = '0x8386D8eB039d9C8D103023AD3243761ec4c81C55';
  // const ComputingPowerPackage1 = await ethers.getContractFactory('ComputingPowerPackage_RWA');
  // const ComputingPowerPackage1_C = await upgrades.deployProxy(ComputingPowerPackage1, [X_RWA, signer, Router, USDT], { kind: 'uups' });
  // // const ComputingPowerPackage_C = await upgrades.upgradeProxy('', ComputingPowerPackage, { kind: 'uups' });

  // await ComputingPowerPackage1_C.deployed();
  // console.log("X-RWA算力包合约: ", ComputingPowerPackage1_C.address);

  // const tx22 = await ComputingPowerPackage1_C.putNewFeeReceivers(feeReceivers);
  // await tx22.wait();
  // console.log("tx22: ", tx22.hash);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
