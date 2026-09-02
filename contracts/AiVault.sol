// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AiVault is AccessControlEnumerable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    bytes32 public constant OPERATE_ROLE = keccak256("OPERATE_ROLE");

    bool public funcSwitch;

    address[] public feeReceivers;

    address public receiver;

    uint public minDepositeAmount = 10 * 1e18;

    event Deposite(address caller, uint payAmount, address payToken);

    event Withdraw(
        address indexed caller,
        address indexed token,
        uint256 amount,
        uint256 timestamp,
        uint256 order
    );

    event BatchTransferred(
        address operator,
        uint256 userCount,
        uint256 totalAmount
    );

    constructor(address receiver_, address _operator) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);
        _grantRole(OPERATE_ROLE, _operator);

        require(receiver_ != address(0), "AiPayment: zero address");
        receiver = receiver_;
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

    function setMinDepositeAmount(
        uint _minDepositeAmount
    ) external onlyRole(MANAGE_ROLE) {
        require(_minDepositeAmount > 0, "AiVault: zero value");
        minDepositeAmount = _minDepositeAmount;
    }

    function balance(address token) external view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20(token).balanceOf(address(this));
    }

    function deposite(
        address depositeToken,
        uint depositeAmount
    ) external payable nonReentrant {
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }
        require(!funcSwitch, "AiVault: depoiste disabled");
        require(
            depositeAmount >= minDepositeAmount,
            "AiVault: deposite amount error"
        );
        require(
            depositeAmount % (10 ** 18) == 0,
            "AiVault: amount must be whole tokens"
        );
        IERC20(depositeToken).safeTransferFrom(
            msg.sender,
            receiver,
            depositeAmount
        );
        emit Deposite(msg.sender, depositeAmount, depositeToken);
    }

    function batchTransferLp(
        address withdrawToken,
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external onlyRole(OPERATE_ROLE) nonReentrant {
        require(!funcSwitch, "LpReward: Unsupported operation");
        require(accounts.length > 0, "LpReward: EMPTY_ACCOUNTS");
        require(accounts.length == amounts.length, "LpReward: LENGTH_MISMATCH");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "LpReward: ACCOUNT_ZERO");
            require(amounts[i] > 0, "LpReward: AMOUNT_ZERO");

            totalAmount += amounts[i];
            IERC20(withdrawToken).safeTransfer(accounts[i], amounts[i]);
        }

        emit BatchTransferred(msg.sender, accounts.length, totalAmount);
    }
}
