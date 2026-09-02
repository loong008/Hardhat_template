// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint256);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract LpReward is AccessControlEnumerable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");
    bytes32 public constant OPERATE_ROLE = keccak256("OPERATE_ROLE");

    bool public funcSwitch;

    IERC20 public rewardToken;
    IERC20 public WBNB;
    IERC20 public lpToken;
    IPancakePair public pair;

    event FuncSwitchUpdated(bool enabled);
    event PairUpdated(address pair, address rewardToken, address wbnb);
    event BatchLpTransferred(
        address indexed operator,
        uint256 userCount,
        uint256 totalAmount
    );

    constructor(
        address _pair,
        address _rewardToken,
        address _wbnb,
        address _operator
    ) {
        require(_pair != address(0), "LpReward: PAIR_ZERO");
        require(_rewardToken != address(0), "LpReward: TOKEN_ZERO");
        require(_wbnb != address(0), "LpReward: WBNB_ZERO");
        require(_operator != address(0), "LpReward: OPERATOR_ZERO");

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);
        _grantRole(OPERATE_ROLE, _operator);

        _setPair(_pair, _rewardToken, _wbnb);
    }

    function setFuncSwitch(bool _funcSwitch) external onlyRole(MANAGE_ROLE) {
        funcSwitch = _funcSwitch;
        emit FuncSwitchUpdated(_funcSwitch);
    }

    function setPair(
        address _pair,
        address _rewardToken,
        address _wbnb
    ) external onlyRole(MANAGE_ROLE) {
        _setPair(_pair, _rewardToken, _wbnb);
    }

    function grantOperateRole(address account) external onlyRole(MANAGE_ROLE) {
        require(account != address(0), "LpReward: ACCOUNT_ZERO");
        _grantRole(OPERATE_ROLE, account);
    }

    function revokeOperateRole(address account) external onlyRole(MANAGE_ROLE) {
        _revokeRole(OPERATE_ROLE, account);
    }

    function balance(address token) external view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20(token).balanceOf(address(this));
    }

    function getTokenPriceInWbnb() external view returns (uint256) {
        (uint256 rewardReserve, uint256 wbnbReserve) = _getOrderedReserves();
        require(rewardReserve > 0, "LpReward: TOKEN_RESERVE_ZERO");
        require(wbnbReserve > 0, "LpReward: WBNB_RESERVE_ZERO");

        uint256 rewardReserveNormalized = _to1e18(
            rewardReserve,
            IERC20Metadata(address(rewardToken)).decimals()
        );
        uint256 wbnbReserveNormalized = _to1e18(
            wbnbReserve,
            IERC20Metadata(address(WBNB)).decimals()
        );

        return (wbnbReserveNormalized * 1 ether) / rewardReserveNormalized;
    }

    function getLpTokenValue(
        uint256 lpAmount
    )
        external
        view
        returns (
            uint256 rewardTokenAmount,
            uint256 wbnbAmount,
            uint256 totalValueInWbnb
        )
    {
        require(lpAmount > 0, "LpReward: LP_AMOUNT_ZERO");

        (uint256 rewardReserve, uint256 wbnbReserve) = _getOrderedReserves();
        uint256 totalLpSupply = pair.totalSupply();
        require(totalLpSupply > 0, "LpReward: LP_SUPPLY_ZERO");

        rewardTokenAmount = (rewardReserve * lpAmount) / totalLpSupply;
        wbnbAmount = (wbnbReserve * lpAmount) / totalLpSupply;
        totalValueInWbnb = wbnbAmount * 2;
    }

    function getLpTokenValue()
        external
        view
        returns (
            uint256 rewardTokenAmount,
            uint256 wbnbAmount,
            uint256 totalValueInWbnb
        )
    {
        uint lpAmount = lpToken.balanceOf(address(this));
        require(lpAmount > 0, "LpReward: LP_AMOUNT_ZERO");

        (uint256 rewardReserve, uint256 wbnbReserve) = _getOrderedReserves();
        uint256 totalLpSupply = pair.totalSupply();
        require(totalLpSupply > 0, "LpReward: LP_SUPPLY_ZERO");

        rewardTokenAmount = (rewardReserve * lpAmount) / totalLpSupply;
        wbnbAmount = (wbnbReserve * lpAmount) / totalLpSupply;
        totalValueInWbnb = wbnbAmount * 2;
    }

    function batchTransferLp(
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
            lpToken.safeTransfer(accounts[i], amounts[i]);
        }

        emit BatchLpTransferred(msg.sender, accounts.length, totalAmount);
    }

    function _setPair(
        address _pair,
        address _rewardToken,
        address _wbnb
    ) internal {
        require(_pair != address(0), "LpReward: PAIR_ZERO");
        require(_rewardToken != address(0), "LpReward: TOKEN_ZERO");
        require(_wbnb != address(0), "LpReward: WBNB_ZERO");

        address token0 = IPancakePair(_pair).token0();
        address token1 = IPancakePair(_pair).token1();
        require(
            (token0 == _rewardToken && token1 == _wbnb) ||
                (token0 == _wbnb && token1 == _rewardToken),
            "LpReward: INVALID_PAIR"
        );

        pair = IPancakePair(_pair);
        lpToken = IERC20(_pair);
        rewardToken = IERC20(_rewardToken);
        WBNB = IERC20(_wbnb);

        emit PairUpdated(_pair, _rewardToken, _wbnb);
    }

    function _getOrderedReserves()
        internal
        view
        returns (uint256 rewardReserve, uint256 wbnbReserve)
    {
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        if (pair.token0() == address(rewardToken)) {
            rewardReserve = uint256(reserve0);
            wbnbReserve = uint256(reserve1);
        } else {
            rewardReserve = uint256(reserve1);
            wbnbReserve = uint256(reserve0);
        }
    }

    function _to1e18(
        uint256 amount,
        uint8 decimals
    ) internal pure returns (uint256) {
        if (decimals == 18) {
            return amount;
        }
        if (decimals < 18) {
            return amount * (10 ** (18 - decimals));
        }
        return amount / (10 ** (decimals - 18));
    }
}
