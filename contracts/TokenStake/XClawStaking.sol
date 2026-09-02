// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

struct StakeOrder {
    address user;
    uint256 shares;
    uint256 amount;
    uint256 startTime;
    bool redeemed;
}

contract XClawStaking is
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    /*
        redeem
        businessAdds: 0-user
        businessInts: 0-nonce; 1-deadline; 2-operateType(1); 3-orderId; 4-amount; 5-fee
    */
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Permit(address[] businessAdds,uint256[] businessInts)"
            )
        );

    address[] public feeReceivers;
    bool public funcSwitch;
    address public signer;
    address public feeReceiver;
    address public stakeToken;
    bytes32 public DOMAIN_SEPARATOR;

    uint256 public unitAmount;
    uint256 public cycleDuration;
    uint256 public nextOrderId;
    uint256 public totalStaked;

    mapping(address => uint256) public nonces;
    mapping(uint256 => StakeOrder) public stakeOrders;

    event Stake(
        address user,
        uint256 orderId,
        uint256 shares,
        uint256 amount,
        uint256 startTime,
        uint256 endTime
    );

    event Redeem(address[] businessAdds, uint256[] businessInts);

    event SetSigner(address signer);
    event SetFuncSwitch(bool state);
    event SetFeeReceiver(address feeReceiver);
    event SetStakeToken(address stakeToken);
    event SetUnitAmount(uint256 unitAmount);
    event SetCycleDuration(uint256 cycleDuration);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(MANAGE_ROLE) {}

    function initialize(
        address _stakeToken,
        address _signer,
        address _feeReceiver
    ) public initializer {
        require(_stakeToken != address(0), "Staking: token is zero");
        require(_signer != address(0), "Staking: signer is zero");
        require(_feeReceiver != address(0), "Staking: fee receiver is zero");

        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);

        stakeToken = _stakeToken;
        signer = _signer;
        feeReceiver = _feeReceiver;
        unitAmount = 10000 * 1e18;
        cycleDuration = 30 days;
        nextOrderId = 1;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("XClawStaking")),
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

    function stake(uint256 shares) external payable nonReentrant {
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }
        require(funcSwitch, "Staking: function closed");
        require(shares > 0, "Staking: shares error");

        uint256 amount = shares * unitAmount;
        uint256 orderId = nextOrderId++;

        stakeOrders[orderId] = StakeOrder({
            user: msg.sender,
            shares: shares,
            amount: amount,
            startTime: block.timestamp,
            redeemed: false
        });

        totalStaked += amount;
        IERC20Upgradeable(stakeToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        emit Stake(
            msg.sender,
            orderId,
            shares,
            amount,
            block.timestamp,
            block.timestamp + cycleDuration
        );
    }

    function redeem(bytes calldata data) external payable nonReentrant {
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }
        require(funcSwitch, "Staking: function closed");

        (
            address[] memory businessAdds,
            uint256[] memory businessInts
        ) = _parseData(data);

        require(businessInts[2] == 1, "Staking: operate type error");

        uint256 orderId = businessInts[3];
        uint256 amount = businessInts[4];
        uint256 fee = businessInts[5];

        StakeOrder storage stakeOrder = stakeOrders[orderId];
        require(stakeOrder.user != address(0), "Staking: order error");
        require(stakeOrder.user == businessAdds[0], "Staking: user error");
        require(!stakeOrder.redeemed, "Staking: order redeemed");
        require(amount + fee <= stakeOrder.amount, "Staking: amount error");

        stakeOrder.redeemed = true;
        totalStaked -= stakeOrder.amount;

        if (fee > 0) {
            IERC20Upgradeable(stakeToken).safeTransfer(feeReceiver, fee);
        }
        IERC20Upgradeable(stakeToken).safeTransfer(businessAdds[0], amount);

        emit Redeem(businessAdds, businessInts);
    }

    function setSigner(address _signer) external onlyRole(MANAGE_ROLE) {
        require(_signer != address(0), "Staking: signer is zero");
        signer = _signer;
        emit SetSigner(_signer);
    }

    function setFuncSwitch(bool state) external onlyRole(MANAGE_ROLE) {
        funcSwitch = state;
        emit SetFuncSwitch(state);
    }

    function setFeeReceiver(
        address _feeReceiver
    ) external onlyRole(MANAGE_ROLE) {
        require(_feeReceiver != address(0), "Staking: fee receiver is zero");
        feeReceiver = _feeReceiver;
        emit SetFeeReceiver(_feeReceiver);
    }

    function setStakeToken(address _stakeToken) external onlyRole(MANAGE_ROLE) {
        require(_stakeToken != address(0), "Staking: token is zero");
        stakeToken = _stakeToken;
        emit SetStakeToken(_stakeToken);
    }

    function setUnitAmount(uint256 _unitAmount) external onlyRole(MANAGE_ROLE) {
        require(_unitAmount > 0, "Staking: unit amount error");
        unitAmount = _unitAmount;
        emit SetUnitAmount(_unitAmount);
    }

    function setCycleDuration(
        uint256 _cycleDuration
    ) external onlyRole(MANAGE_ROLE) {
        require(_cycleDuration > 0, "Staking: cycle error");
        cycleDuration = _cycleDuration;
        emit SetCycleDuration(_cycleDuration);
    }

    function getSignHash(
        address[] calldata businessAdds,
        uint256[] calldata businessInts
    ) external view returns (bytes32) {
        return _recoverSignHash(businessAdds, businessInts);
    }

    function orderEndTime(uint256 orderId) external view returns (uint256) {
        StakeOrder memory stakeOrder = stakeOrders[orderId];
        require(stakeOrder.user != address(0), "Staking: order error");
        return stakeOrder.startTime + cycleDuration;
    }

    function _parseData(
        bytes calldata data
    ) internal returns (address[] memory, uint256[] memory) {
        (
            address[] memory businessAdds,
            uint256[] memory businessInts,
            bytes memory signature
        ) = abi.decode(data, (address[], uint256[], bytes));

        require(businessAdds.length > 0, "Staking: address length error");
        require(businessInts.length >= 2, "Staking: int length error");
        require(businessAdds[0] == msg.sender, "Staking: INVALID_USER");
        require(
            businessInts[0] == nonces[msg.sender],
            "Staking: INVALID_NONCE"
        );
        require(block.timestamp <= businessInts[1], "Staking: TIME OUT");

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
            "Staking: INVALID_REQUEST"
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
