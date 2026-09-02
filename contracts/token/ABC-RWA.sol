// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
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

contract SwapHelper is Ownable {
    IUniswapV2Router02 public router;

    address public XRWA;
    address public XClaw;
    uint public slippageBps = 2000;

    bool private _inSwap;

    mapping(address => bool) public _isOperator;

    address public receiver;

    event TriggerSwap(uint256 tokenAmount);

    constructor(address _XRWA, address _owner) {
        _isOperator[msg.sender] = true;
        _transferOwnership(_owner);
        XRWA = _XRWA;
        receiver = address(this);
    }

    receive() external payable {}

    function triggerSwap(uint256 amount) external {
        require(_isOperator[msg.sender], "SwapHelper: caller error");
        require(!_inSwap, "SwapHelper: inSwap");
        require(
            IERC20(XRWA).balanceOf(address(this)) >= amount,
            "SwapHelper: insufficient"
        );
        _inSwap = true;
        _swapXRWA2XClaw(amount);
        _inSwap = false;
        emit TriggerSwap(amount);
    }

    function _swapXRWA2XClaw(uint amount) internal {
        address[] memory path = new address[](3);
        path[0] = XRWA;
        path[1] = router.WETH();
        path[2] = XClaw;
        uint[] memory amounts = router.getAmountsOut(amount, path);
        require(amounts[1] > 0, "SwapHelper: get amount outs error");
        uint minOutAmount = (amounts[1] * (10000 - slippageBps)) / 10000;
        IERC20(XRWA).approve(address(router), amount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            minOutAmount,
            path,
            receiver,
            block.timestamp + 300
        );
    }

    function withdrawToken(
        address _token,
        address _receiver,
        uint256 amount
    ) external onlyOwner {
        IERC20(_token).transfer(_receiver, amount);
    }

    function withdrawBNB(address _receiver, uint256 amount) external onlyOwner {
        require(
            address(this).balance >= amount,
            "SwapHelper: insufficient BNB"
        );
        payable(_receiver).transfer(amount);
    }

    function initailSet(
        IUniswapV2Router02 _router,
        address _XClaw
    ) external onlyOwner {
        require(address(_router) != address(0), "_router is zero");
        require(_XClaw != address(0), "_XClaw is zero");
        router = _router;
        XClaw = _XClaw;
    }

    function setOperator(address _operator, bool _state) external onlyOwner {
        require(_operator != address(0), "operator is zero");
        _isOperator[_operator] = _state;
    }

    function setReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0), "_receiver is zero");
        receiver = _receiver;
    }

    function setRouter(IUniswapV2Router02 _router) external onlyOwner {
        require(address(_router) != address(0), "_router is zero");
        router = _router;
    }

    function setSlippageBos(uint256 _slippageBps) external onlyOwner {
        slippageBps = _slippageBps;
    }

    function setXClaw(address _XClaw) external onlyOwner {
        require(_XClaw != address(0), "_XClaw is zero");
        XClaw = _XClaw;
    }
}

interface IUniswapV2Pair {
    function sync() external;
}

contract ABC_RWA is IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name = "ABC-RWA";
    string private _symbol = "ABC-RWA";

    uint256 private constant TOTAL_SUPPLY = 200_000_000 * 10 ** 18;
    uint256 public MIN_SUPPLY_AFTER_BURN = 21_000_000 * 10 ** 18;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public DIVIDEND_FEE = 1;
    uint256 public BUY_BACK_FEE = 2;
    address public DIVIDEND_POOL;
    SwapHelper public _SwapHelper;

    mapping(address => bool) public _pairs;
    address public MAIN_PAIR;
    mapping(address => bool) public _excludeFee;

    IUniswapV2Router02 public Router;

    uint256 public SWAP_TOKENS_AT_AMOUNT = 1_000 * 10 ** 18;
    uint256 public MAX_SWAP_AMOUNT = 10_000_000 * 10 ** 18;
    bool public TO_ADD_LIQUIDITY;

    mapping(address => bool) public _isOperator;

    uint256 public LAST_BURN_TIME;
    uint256 public BURN_INTERVAL = 1 hours;
    uint256 public BURN_RATE = 200;

    bool public S_Switch;

    EnumerableSet.AddressSet private eligibleHolders;
    uint256 public THRESHOLD = 50_000 * 10 ** 18;
    mapping(address => bool) public _distirbuteExclude;

    constructor(
        address _initialReceiver,
        address _DIVIDEND_POOL,
        IUniswapV2Router02 _router
    ) {
        require(
            _initialReceiver != address(0),
            "X-RWA: Receiver is zero address"
        );
        require(
            _DIVIDEND_POOL != address(0),
            "X-RWA: _DIVIDEND_POOL is zero address"
        );
        require(
            address(_router) != address(0),
            "X-RWA: router is zero address"
        );

        DIVIDEND_POOL = _DIVIDEND_POOL;
        _SwapHelper = new SwapHelper(address(this), msg.sender);
        Router = _router;
        address pair = IUniswapV2Factory(_router.factory()).createPair(
            address(this),
            Router.WETH()
        );
        _pairs[pair] = true;
        MAIN_PAIR = pair;

        _excludeFee[address(this)] = true;
        _excludeFee[_initialReceiver] = true;
        _excludeFee[address(_SwapHelper)] = true;
        _excludeFee[_DIVIDEND_POOL] = true;

        _distirbuteExclude[address(_SwapHelper)] = true;
        _distirbuteExclude[_DIVIDEND_POOL] = true;
        _distirbuteExclude[MAIN_PAIR] = true;
        _distirbuteExclude[DEAD] = true;

        LAST_BURN_TIME = block.timestamp;

        _mint(_initialReceiver, TOTAL_SUPPLY);
    }

    function setPair(address pair, bool state) external onlyOwner {
        require(pair != address(0), "X-RWA: zero address");
        _pairs[pair] = state;
    }

    function setExcludeFee(address account, bool state) external onlyOwner {
        require(account != address(0), "X-RWA: zero address");
        _excludeFee[account] = state;
    }

    function batchSetExcludeFee(
        address[] calldata accounts,
        bool state
    ) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _excludeFee[accounts[i]] = state;
        }
    }

    function setDividendFee(uint _dividendFee) external onlyOwner {
        DIVIDEND_FEE = _dividendFee;
    }

    function setBuyBackFee(uint _buyBackFee) external onlyOwner {
        BUY_BACK_FEE = _buyBackFee;
    }

    function setDividendPool(address _dividendPool) external onlyOwner {
        require(_dividendPool != address(0), "X-RWA: zero address");
        DIVIDEND_POOL = _dividendPool;
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        SWAP_TOKENS_AT_AMOUNT = amount;
    }

    function setMaxSwapAmount(uint256 amount) external onlyOwner {
        MAX_SWAP_AMOUNT = amount;
    }

    function setOperator(address _operator, bool _state) external onlyOwner {
        require(_operator != address(0), "operator is zero");
        _isOperator[_operator] = _state;
    }

    function setMainPair(address _mainPair) external onlyOwner {
        require(_mainPair != address(0), "_mainPair is zero");
        MAIN_PAIR = _mainPair;
    }

    function setSSwitch(bool _sSwitch) external onlyOwner {
        S_Switch = _sSwitch;
    }

    function setBurnInterval(uint _burnInterval) external onlyOwner {
        BURN_INTERVAL = _burnInterval;
    }

    function setBurnRate(uint _burnRate) external onlyOwner {
        BURN_RATE = _burnRate;
    }

    function executeLPBurn() external {
        require(_isOperator[msg.sender], "caller error");
        require(block.timestamp >= LAST_BURN_TIME + BURN_INTERVAL, "too early");
        LAST_BURN_TIME = block.timestamp;

        uint256 lpTokenBalance = balanceOf(MAIN_PAIR);
        if (lpTokenBalance > 0) {
            uint256 burnAmount = (lpTokenBalance * BURN_RATE) / 10000;
            uint256 realBurnAmount = _getBurnAmount(burnAmount);
            require(realBurnAmount > 0, "unable to burn");

            _balances[MAIN_PAIR] = _balances[MAIN_PAIR] - realBurnAmount;
            _balances[DEAD] = _balances[DEAD] + realBurnAmount;
            emit Transfer(MAIN_PAIR, DEAD, realBurnAmount);
            _totalSupply = _totalSupply - realBurnAmount;

            IUniswapV2Pair(MAIN_PAIR).sync();
        }
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), to, amount);
        _syncEligibility(_msgSender());
        _syncEligibility(to);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, to, amount);
        _syncEligibility(from);
        _syncEligibility(to);
        return true;
    }

    function _syncEligibility(address account) internal {
        bool eligible = isEligible(account) && balanceOf(account) >= THRESHOLD;

        if (eligible) {
            eligibleHolders.add(account);
        } else {
            eligibleHolders.remove(account);
        }
    }

    function isEligible(address account) public view returns (bool) {
        return
            account != address(0) &&
            account != address(this) &&
            !_distirbuteExclude[account];
    }

    function setTHRESHOLD(uint _THRESHOLD) external onlyOwner {
        THRESHOLD = _THRESHOLD;
    }

    function eligibleHolderCount() external view returns (uint256) {
        return eligibleHolders.length();
    }

    function eligibleHolderValues() external view returns (address[] memory) {
        return eligibleHolders.values();
    }

    function setDistributeExclude(
        address[] calldata accounts,
        bool state
    ) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _distirbuteExclude[accounts[i]] = state;
            _syncEligibility(accounts[i]);
        }
    }

    function syncEligibilityBatch(
        address[] calldata accounts
    ) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _syncEligibility(accounts[i]);
        }
    }

    function burn(uint amount) public virtual returns (bool) {
        return _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint amount) public virtual returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        return _burn(from, amount);
    }

    function _burn(address from, uint amount) internal virtual returns (bool) {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: burn amount exceeds balance");
        uint256 realBurnAmount = _getBurnAmount(amount);
        require(realBurnAmount > 0, "unable to burn");
        _balances[from] = _balances[from] - realBurnAmount;
        _balances[DEAD] = _balances[DEAD] + realBurnAmount;
        emit Transfer(from, DEAD, realBurnAmount);
        _totalSupply = _totalSupply - realBurnAmount;
        _syncEligibility(from);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            allowance(_msgSender(), spender) + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = allowance(_msgSender(), spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        bool isSwap = _pairs[from] || _pairs[to];
        if (!isSwap || _excludeFee[from] || _excludeFee[to]) {
            _standardTransfer(from, to, amount);
            return;
        }
        require(S_Switch, "ERC20: not support this operation");

        uint256 helperBalance = balanceOf(address(_SwapHelper));
        if (
            !TO_ADD_LIQUIDITY &&
            _pairs[to] &&
            helperBalance >= SWAP_TOKENS_AT_AMOUNT
        ) {
            TO_ADD_LIQUIDITY = true;
            uint256 swapAmount = helperBalance > MAX_SWAP_AMOUNT
                ? MAX_SWAP_AMOUNT
                : helperBalance;
            _SwapHelper.triggerSwap(swapAmount);
            TO_ADD_LIQUIDITY = false;
        }

        _transferWithFee(from, to, amount);
    }

    function _standardTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function _transferWithFee(
        address from,
        address to,
        uint256 amount
    ) internal {
        _balances[from] = _balances[from] - amount;
        uint256 dividendFeeAmount = (amount * DIVIDEND_FEE) / 100;
        _balances[DIVIDEND_POOL] += dividendFeeAmount;
        emit Transfer(from, DIVIDEND_POOL, dividendFeeAmount);
        uint256 buyBackFeeAmount = (amount * BUY_BACK_FEE) / 100;
        _balances[address(_SwapHelper)] += buyBackFeeAmount;
        emit Transfer(from, address(_SwapHelper), buyBackFeeAmount);
        uint256 receiveAmount = amount - dividendFeeAmount - buyBackFeeAmount;
        _balances[to] = _balances[to] + receiveAmount;
        emit Transfer(from, to, receiveAmount);
    }

    function _getBurnAmount(
        uint256 requestedBurn
    ) internal view returns (uint256) {
        if (requestedBurn == 0 || _totalSupply <= MIN_SUPPLY_AFTER_BURN) {
            return 0;
        }

        uint256 burnableAmount = _totalSupply - MIN_SUPPLY_AFTER_BURN;
        return requestedBurn > burnableAmount ? burnableAmount : requestedBurn;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}
