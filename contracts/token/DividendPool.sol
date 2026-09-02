// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

interface IQuoterV2 {
    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Returns the amount out received for a given exact input but for a swap of a single pool
    /// @param params The params for the quote, encoded as `QuoteExactInputSingleParams`
    /// tokenIn The token being swapped in
    /// tokenOut The token being swapped out
    /// fee The fee of the token pool to consider for the pair
    /// amountIn The desired input amount
    /// sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap
    /// @return amountOut The amount of `tokenOut` that would be received
    /// @return sqrtPriceX96After The sqrt price of the pool after the swap
    /// @return initializedTicksCrossed The number of initialized ticks that the swap crossed
    /// @return gasEstimate The estimate of the gas that the swap consumes
    function quoteExactInputSingle(
        QuoteExactInputSingleParams memory params
    )
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );
}

interface IV3SwapRouter {
    // struct ExactInputSingleParams {
    //     address tokenIn;
    //     address tokenOut;
    //     uint24 fee;
    //     address recipient;
    //     uint256 amountIn;
    //     uint256 amountOutMinimum;
    //     uint160 sqrtPriceLimitX96;
    // }

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

contract DividendPool is
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    bytes32 public constant OPERATE_ROLE = keccak256("OPERATE_ROLE");

    IUniswapV2Router02 public router;
    IV3SwapRouter public v3Router;
    IQuoterV2 public quoter;
    uint24 public poolFee;
    IERC20Upgradeable public XRWA;
    IERC20Upgradeable public SPCXB;
    IERC20Upgradeable public USDT;
    uint public slippageBps;

    uint256 public SPCXB_BALANCE;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(MANAGE_ROLE) {}

    function initialize(
        IUniswapV2Router02 _router,
        IV3SwapRouter _v3Router,
        IQuoterV2 _quoter,
        IERC20Upgradeable _XRWA,
        IERC20Upgradeable _SPCXB,
        IERC20Upgradeable _USDT,
        address _operator
    ) public initializer {
        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);

        router = _router;
        v3Router = _v3Router;
        quoter = _quoter;
        XRWA = _XRWA;
        SPCXB = _SPCXB;
        USDT = _USDT;
        poolFee = 2500;
        slippageBps = 2000;

        _grantRole(OPERATE_ROLE, _operator);
    }

    function SPCXB_Amount() public view returns (uint) {
        return SPCXB.balanceOf(address(this));
    }

    function setXRWA(IERC20Upgradeable _XRWA) public onlyRole(MANAGE_ROLE) {
        require(
            address(_XRWA) != address(0),
            "DividendPool: _RWA is zero address"
        );
        XRWA = _XRWA;
    }

    function getUSDT() public view returns (uint) {
        uint xrwaBalance = XRWA.balanceOf(address(this));
        if (xrwaBalance == 0) {
            return 0;
        }
        address[] memory path = new address[](3);
        path[0] = address(XRWA);
        path[1] = address(router.WETH());
        path[2] = address(USDT);

        uint[] memory amounts = router.getAmountsOut(xrwaBalance, path);
        return amounts[2];
    }

    function quoteSwapOut(
        uint256 usdtAmount
    ) public returns (uint256 amountOut) {
        require(usdtAmount > 0, "DividendPool: invalid amount");

        IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2
            .QuoteExactInputSingleParams({
                tokenIn: address(USDT),
                tokenOut: address(SPCXB),
                amountIn: usdtAmount,
                fee: poolFee,
                sqrtPriceLimitX96: 0
            });

        (amountOut, , , ) = quoter.quoteExactInputSingle(params);
    }

    function swap() external onlyRole(OPERATE_ROLE) {
        require(getUSDT() >= 100 * 1e18, "DividendPool: wait...");
        uint xrwaBalance = XRWA.balanceOf(address(this));
        _swapXRWA2USDT(xrwaBalance);
        uint spcxbAmount = _swapUSDT2SPCXB();
        SPCXB_BALANCE += spcxbAmount;
    }

    function _swapXRWA2USDT(uint xrwaAmount) internal {
        address[] memory path = new address[](3);
        path[0] = address(XRWA);
        path[1] = address(router.WETH());
        path[2] = address(USDT);
        uint minUsdtOut = (getUSDT() * (10000 - slippageBps)) / 10000;
        XRWA.approve(address(router), xrwaAmount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            xrwaAmount,
            minUsdtOut,
            path,
            address(this),
            block.timestamp + 300
        );
    }

    function _swapUSDT2SPCXB() internal returns (uint) {
        uint usdtAmount = USDT.balanceOf(address(this));
        uint SPCXB_OUT = quoteSwapOut(usdtAmount);
        uint MIN_SPCXB_OUT = (SPCXB_OUT * (10000 - slippageBps)) / 10000;

        TransferHelper.safeApprove(address(USDT), address(v3Router), 0);
        TransferHelper.safeApprove(
            address(USDT),
            address(v3Router),
            usdtAmount
        );
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter
            .ExactInputSingleParams({
                tokenIn: address(USDT),
                tokenOut: address(SPCXB),
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp + 300,
                amountIn: usdtAmount,
                amountOutMinimum: MIN_SPCXB_OUT,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        uint amountOut = v3Router.exactInputSingle(params);
        return amountOut;
    }

    function batchDistribute(
        address[] calldata accounts,
        uint amount
    ) external onlyRole(OPERATE_ROLE) {
        require(
            accounts.length > 0 && amount > 0,
            "DividendPool: array length error"
        );
        for (uint i = 0; i < accounts.length; i++) {
            SPCXB.safeTransfer(accounts[i], amount);
        }
    }
}
