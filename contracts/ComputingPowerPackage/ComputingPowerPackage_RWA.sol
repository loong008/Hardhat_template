// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

interface IUniswapV2Router {
    function WETH() external view returns (address);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

contract ComputingPowerPackage_RWA is
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    /*
        buy
        businessAdds: 0-user
        businessInts: 0-nonce; 1-deadline; 2-operateType(1); 3-usdtAmount; 4-payAmount
    */

    /*
        withdraw
        businessAdds: 0-user
        businessInts: 0-nonce; 1-deadline; 2-operateType(2); 3-withdrawAmount
    */
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Permit(address[] businessAdds,uint256[] businessInts)"
            )
        );

    bool public funcSwitch;
    address[] public feeReceivers;
    address public signer;
    address public router;
    address public usdtToken;
    address public wbnbToken;
    address public payToken;
    bytes32 public DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    address public receiver;

    event Buy(address[] businessAdds, uint256[] businessInts);

    event Withdraw(address[] businessAdds, uint256[] businessInts);

    event BatchTransfer(address[] businessAdds, uint256[] businessInts);

    event SetSigner(address signer);
    event SetFuncSwitch(bool state);
    event SetRouter(address router);
    event SetUsdtToken(address usdtToken);
    event SetWbnbToken(address wbnbToken);
    event SetPayToken(address payToken);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(MANAGE_ROLE) {}

    function initialize(
        address _payToken,
        address _signer,
        address _router,
        address _usdtToken
    ) public initializer {
        require(
            _payToken != address(0),
            "ComputingPowerPackage: token is zero"
        );
        require(_signer != address(0), "ComputingPowerPackage: signer is zero");
        require(_router != address(0), "ComputingPowerPackage: router is zero");
        require(
            _usdtToken != address(0),
            "ComputingPowerPackage: usdt is zero"
        );

        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);

        payToken = _payToken;
        signer = _signer;
        router = _router;
        usdtToken = _usdtToken;
        wbnbToken = IUniswapV2Router(_router).WETH();
        require(wbnbToken != address(0), "ComputingPowerPackage: wbnb is zero");
        receiver = 0x833Ea2Bb19CCB3A230618AA1AA983b256D73D21d;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("ComputingPowerPackage")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function putNewFeeReceivers(
        address[] calldata adds
    ) public onlyRole(MANAGE_ROLE) {
        delete feeReceivers;
        require(adds.length > 0, "Array length error");
        for (uint i = 0; i < adds.length; i++) {
            feeReceivers.push(adds[i]);
        }
    }

    function _getRandomReceiver() internal view returns (address) {
        uint index = block.number % feeReceivers.length;
        return feeReceivers[index];
    }

    function buy(bytes calldata data) external payable nonReentrant {
        require(!funcSwitch, "ComputingPowerPackage: function closed");
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }

        (
            address[] memory businessAdds,
            uint256[] memory businessInts
        ) = _parseData(data);

        // require(businessAdds.length == 1, "ComputingPowerPackage: address length error");
        // require(businessInts.length == 5, "ComputingPowerPackage: int length error");
        require(
            businessInts[2] == 1,
            "ComputingPowerPackage: operate type error"
        );

        uint256 usdtAmount = businessInts[3];
        uint256 payAmount = businessInts[4];
        require(usdtAmount > 0, "ComputingPowerPackage: usdt amount error");
        require(
            payAmount >=
                (((usdtAmount * 95) / 100) * getAmountsOut(1e18)) / 1e18,
            "ComputingPowerPackage: pay amount error1"
        );
        require(
            payAmount <=
                (((usdtAmount * 105) / 100) * getAmountsOut(1e18)) / 1e18,
            "ComputingPowerPackage: pay amount error2"
        );

        IERC20Upgradeable(payToken).safeTransferFrom(
            msg.sender,
            receiver,
            payAmount
        );

        emit Buy(businessAdds, businessInts);
    }

    // function withdraw(bytes calldata data) external payable nonReentrant {
    //     require(!funcSwitch, "ComputingPowerPackage: function closed");
    //     if (msg.value > 0) {
    //         payable(_getRandomReceiver()).transfer(msg.value);
    //     }

    //     (
    //         address[] memory businessAdds,
    //         uint256[] memory businessInts
    //     ) = _parseData(data);

    //     // require(businessAdds.length == 1, "ComputingPowerPackage: address length error");
    //     // require(businessInts.length == 4, "ComputingPowerPackage: int length error");
    //     require(
    //         businessInts[2] == 2,
    //         "ComputingPowerPackage: operate type error"
    //     );

    //     uint256 withdrawAmount = businessInts[3];
    //     require(
    //         withdrawAmount > 0,
    //         "ComputingPowerPackage: withdrawAmount amount error"
    //     );
    //     IERC20Upgradeable(payToken).safeTransfer(
    //         businessAdds[0],
    //         withdrawAmount
    //     );

    //     emit Withdraw(businessAdds, businessInts);
    // }

    function getAmountsOut(
        uint usdtAmount
    ) public view returns (uint payAmount) {
        address[] memory path = new address[](3);
        path[0] = usdtToken;
        path[1] = wbnbToken;
        path[2] = payToken;

        uint256[] memory amounts = IUniswapV2Router(router).getAmountsOut(
            usdtAmount,
            path
        );
        payAmount = amounts[2];
    }

    function setSigner(address _signer) external onlyRole(MANAGE_ROLE) {
        require(_signer != address(0), "ComputingPowerPackage: signer is zero");
        signer = _signer;
        emit SetSigner(_signer);
    }

    function setRouter(address _router) external onlyRole(MANAGE_ROLE) {
        require(_router != address(0), "ComputingPowerPackage: router is zero");
        router = _router;
        wbnbToken = IUniswapV2Router(_router).WETH();
        require(wbnbToken != address(0), "ComputingPowerPackage: wbnb is zero");
        emit SetRouter(_router);
    }

    function setUsdtToken(address _usdtToken) external onlyRole(MANAGE_ROLE) {
        require(
            _usdtToken != address(0),
            "ComputingPowerPackage: usdt is zero"
        );
        usdtToken = _usdtToken;
        emit SetUsdtToken(_usdtToken);
    }

    function setWbnbToken(address _wbnbToken) external onlyRole(MANAGE_ROLE) {
        require(
            _wbnbToken != address(0),
            "ComputingPowerPackage: wbnb is zero"
        );
        wbnbToken = _wbnbToken;
        emit SetWbnbToken(_wbnbToken);
    }

    function setFuncSwitch(bool state) external onlyRole(MANAGE_ROLE) {
        funcSwitch = state;
        emit SetFuncSwitch(state);
    }

    function setPayToken(address _payToken) external onlyRole(MANAGE_ROLE) {
        require(
            _payToken != address(0),
            "ComputingPowerPackage: token is zero"
        );
        payToken = _payToken;
        emit SetPayToken(_payToken);
    }

    function setReceiver(address _receiver) external onlyRole(MANAGE_ROLE) {
        require(
            _receiver != address(0),
            "ComputingPowerPackage: _receiver is zero"
        );
        receiver = _receiver;
    }

    function getSignHash(
        address[] calldata businessAdds,
        uint256[] calldata businessInts
    ) external view returns (bytes32) {
        return _recoverSignHash(businessAdds, businessInts);
    }

    function _parseData(
        bytes calldata data
    ) internal returns (address[] memory, uint256[] memory) {
        (
            address[] memory businessAdds,
            uint256[] memory businessInts,
            bytes memory signature
        ) = abi.decode(data, (address[], uint256[], bytes));

        require(
            businessAdds.length > 0,
            "ComputingPowerPackage: address length error"
        );
        require(
            businessInts.length >= 2,
            "ComputingPowerPackage: int length error"
        );
        require(
            businessAdds[0] == msg.sender,
            "ComputingPowerPackage: INVALID_USER"
        );
        require(
            businessInts[0] == nonces[msg.sender],
            "ComputingPowerPackage: INVALID_NONCE"
        );
        require(
            block.timestamp <= businessInts[1],
            "ComputingPowerPackage: TIME OUT"
        );

        _verify(businessAdds, businessInts, signature);
        nonces[msg.sender]++;

        return (businessAdds, businessInts);
    }

    function _verify(
        address[] memory businessAdds,
        uint256[] memory businessInts,
        bytes memory signature
    ) internal view {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        bytes32 signHash = _recoverSignHash(businessAdds, businessInts);
        require(
            signer == ecrecover(signHash, v, r, s),
            "ComputingPowerPackage: INVALID_REQUEST"
        );
    }

    function _recoverSignHash(
        address[] memory businessAdds,
        uint256[] memory businessInts
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(PERMIT_TYPEHASH, businessAdds, businessInts)
                    )
                )
            );
    }

    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65, "Not Invalid Signature Data");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}
