// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IPancakeV2Router {
    function WETH() external view returns (address);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IPayToken {
    function burn(uint amount) external returns (bool);

    function MIN_SUPPLY_AFTER_BURN() external view returns (uint);

    function totalSupply() external view returns (uint256);
}

contract AiPayment is AccessControlEnumerable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    bool public funcSwitch;

    address[] public feeReceivers;

    address public receiver;

    uint256 private constant USD_PRICE_PRECISION = 1e18;
    address public pancakeV2Router;
    address public usdt;
    address public wbnb;
    address public pay1Token;
    uint8 public usdtDecimals;

    mapping(uint8 => uint) public typePrices;

    event Pay(address caller, uint payAmount, address payToken);

    event Pay1(
        address caller,
        uint8 payType,
        address payToken,
        uint payAmount,
        uint usdtAmount
    );

    constructor(address receiver_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);

        require(receiver_ != address(0), "AiPayment: zero address");
        receiver = receiver_;

        typePrices[1] = 19;
        typePrices[2] = 990;
        typePrices[3] = 6990;
    }

    function setTypePrices(
        uint8 priceType,
        uint price
    ) public onlyRole(MANAGE_ROLE) {
        typePrices[priceType] = price;
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

    function setPay1Config(
        address pancakeV2Router_,
        address usdt_,
        address pay1Token_
    ) external onlyRole(MANAGE_ROLE) {
        require(pancakeV2Router_ != address(0), "AiPayment: zero address");
        require(usdt_ != address(0), "AiPayment: zero address");
        require(pay1Token_ != address(0), "AiPayment: zero address");

        address wbnb_ = IPancakeV2Router(pancakeV2Router_).WETH();
        require(wbnb_ != address(0), "AiPayment: zero address");

        pancakeV2Router = pancakeV2Router_;
        usdt = usdt_;
        wbnb = wbnb_;
        pay1Token = pay1Token_;
        usdtDecimals = IERC20Metadata(usdt_).decimals();
    }

    function withdrawErc20(
        address token,
        address to,
        uint256 amount
    ) public onlyRole(MANAGE_ROLE) {
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        require(tokenBalance >= amount, "ERROR:INSUFFICIENT");
        IERC20(token).safeTransfer(to, amount);
    }

    function _getRandomReceiver() internal view returns (address) {
        uint index = block.number % feeReceivers.length;
        return feeReceivers[index];
    }

    function setFuncSwitch(bool _funcSwitch) external onlyRole(MANAGE_ROLE) {
        funcSwitch = _funcSwitch;
    }

    function setReceiver(address receiver_) external onlyRole(MANAGE_ROLE) {
        require(receiver_ != address(0), "AiPayment: zero address");
        receiver = receiver_;
    }

    function balance(address token) external view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20(token).balanceOf(address(this));
    }

    function getPay1UsdtAmount(uint8 payType) public view returns (uint256) {
        if (payType == 1) {
            return
                _scaleUsdAmount(
                    (typePrices[payType] * USD_PRICE_PRECISION) / 10
                );
        }
        if (payType == 2) {
            return
                _scaleUsdAmount(typePrices[payType] * USD_PRICE_PRECISION) / 10;
        }
        if (payType == 3) {
            return
                _scaleUsdAmount(
                    (typePrices[payType] * USD_PRICE_PRECISION) / 10
                );
        }

        revert("AiPayment: pay type error");
    }

    function getPay1TokenAmount(uint8 payType) public view returns (uint256) {
        uint usdtAmount = getPay1UsdtAmount(payType);
        return _getPay1TokenAmount(usdtAmount);
    }

    function _getPay1TokenAmount(
        uint usdtAmount
    ) internal view returns (uint256) {
        require(
            pancakeV2Router != address(0) &&
                usdt != address(0) &&
                wbnb != address(0) &&
                pay1Token != address(0),
            "AiPayment: pay1 not configured"
        );

        address[] memory path = new address[](3);
        path[0] = pay1Token;
        path[1] = wbnb;
        path[2] = usdt;

        uint[] memory amounts = IPancakeV2Router(pancakeV2Router).getAmountsIn(
            usdtAmount,
            path
        );
        return amounts[0];
    }

    // function pay(
    //     address payToken,
    //     uint payAmount
    // ) external payable nonReentrant {
    //     if (msg.value > 0) {
    //         payable(_getRandomReceiver()).transfer(msg.value);
    //     }
    //     require(!funcSwitch, "AiPayment: pay disabled");
    //     IERC20(payToken).safeTransferFrom(msg.sender, receiver, payAmount);
    //     emit Pay(msg.sender, payAmount, payToken);
    // }

    function pay1(uint8 payType) external payable nonReentrant {
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }
        require(!funcSwitch, "AiPayment: pay disabled");

        uint usdtAmount = getPay1UsdtAmount(payType);
        uint payAmount = _getPay1TokenAmount(usdtAmount);
        IERC20(pay1Token).safeTransferFrom(
            msg.sender,
            address(this),
            payAmount
        );

        if (
            IPayToken(pay1Token).totalSupply() >
            IPayToken(pay1Token).MIN_SUPPLY_AFTER_BURN()
        ) {
            IPayToken(pay1Token).burn(payAmount / 2);
        }
        uint pay1TokenBalance = IERC20(pay1Token).balanceOf(address(this));
        IERC20(pay1Token).safeTransfer(receiver, pay1TokenBalance);

        emit Pay1(msg.sender, payType, pay1Token, payAmount, usdtAmount);
    }

    function _scaleUsdAmount(uint256 amount) internal view returns (uint256) {
        require(usdt != address(0), "AiPayment: pay1 not configured");
        if (usdtDecimals == 18) {
            return amount;
        }
        if (usdtDecimals < 18) {
            return amount / (10 ** (18 - usdtDecimals));
        }
        return amount * (10 ** (usdtDecimals - 18));
    }
}
