// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IReward {
    function addUserReward(
        address account,
        address rewardToken,
        uint businessId,
        uint rewardAmount
    ) external;
}

contract PreSale is
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");
    uint256 public constant REWARD_POOL_RATE = 15;
    uint256 public constant RATE_DENOMINATOR = 100;

    uint256 public constant SALE_CAP = 1_000_000_000 ether;
    uint256 public constant MIN_FIRST_SUBSCRIPTION = 0.2 ether;
    uint256 public constant MIN_ADDITIONAL_SUBSCRIPTION = 0.1 ether;
    uint256 public constant MAX_SUBSCRIPTION_PER_ADDRESS = 5 ether;

    bool public funcSwitch;

    address public receiver;
    address public nodeRewardPool;
    address public referrerRewardPool;

    uint256 public tokenAmountPerBnb;
    uint256 public totalSubscribedBnb;
    uint256 public totalReservedTokens;

    mapping(address => uint256) public subscribedBnb;
    mapping(address => uint256) public reservedTokens;

    address public signer;
    mapping(address => uint256) public nonces;
    bytes32 public DOMAIN_SEPARATOR;

    /* 
        businessAdds: 0-user;1-referrer;
        businessInts: 0-nonce;1-deadline;2-businessId
     */
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Permit(address[] businessAdds,uint256[] businessInts)"
            )
        );

    event ReceiverUpdated(address receiver);
    event FuncSwitchUpdated(bool enabled);
    event PriceUpdated(uint256 tokenAmountPerBnb);
    event RewardPoolUpdated(address rewardPool);
    event Purchased(
        address buyer,
        uint256 bnbAmount,
        uint256 reservedTokenAmount,
        address referrer,
        uint256 referrerRewardAmount
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(MANAGE_ROLE) {}

    function initialize(
        uint256 tokenAmountPerBnb_,
        address nodeRewardPool_,
        address referrerRewardPool_,
        address receiver_,
        address signer_
    ) public initializer {
        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);

        funcSwitch = false;

        _setPrice(tokenAmountPerBnb_);
        _setReceiver(receiver_);
        _setRewardPool(nodeRewardPool_);
        _setReferrerRewardPool(referrerRewardPool_);
        _setSigner(signer_);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("PreSale")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function batchSetReservedTokens(
        address[] calldata _accounts,
        uint[] calldata _amounts
    ) external onlyRole(MANAGE_ROLE) {
        require(
            _accounts.length == _amounts.length && _accounts.length > 0,
            "StaticsReward: array length error"
        );
        for (uint i = 0; i < _accounts.length; i++) {
            reservedTokens[_accounts[i]] += _amounts[i];
        }
    }

    function subscribe(bytes calldata data) external payable nonReentrant {
        require(!funcSwitch, "presale closed");
        require(tokenAmountPerBnb > 0, "price unset");
        require(receiver != address(0), "receiver unset");
        (
            address[] memory businessAdds,
            uint256[] memory businessInts
        ) = _parseData(data);

        uint256 previousSubscribed = subscribedBnb[msg.sender];
        uint256 currentAmount = msg.value;

        if (previousSubscribed == 0) {
            require(
                currentAmount >= MIN_FIRST_SUBSCRIPTION,
                "first subscription < 0.2 BNB"
            );
        } else {
            require(
                currentAmount >= MIN_ADDITIONAL_SUBSCRIPTION,
                "additional subscription < 0.1 BNB"
            );
        }
        uint256 newSubscribedAmount = previousSubscribed + currentAmount;
        require(
            newSubscribedAmount <= MAX_SUBSCRIPTION_PER_ADDRESS,
            "subscription > 5 BNB"
        );
        uint256 tokenAmount = (currentAmount * tokenAmountPerBnb) / 1 ether;
        require(tokenAmount > 0, "token amount zero");
        require(
            totalReservedTokens + tokenAmount <= SALE_CAP,
            "sale cap reached"
        );
        uint256 rewardPoolAmount = (currentAmount * 20) / RATE_DENOMINATOR;
        uint256 feeReceiverAmount = currentAmount - rewardPoolAmount;

        subscribedBnb[msg.sender] = newSubscribedAmount;
        reservedTokens[msg.sender] += tokenAmount;
        totalSubscribedBnb += currentAmount;
        totalReservedTokens += tokenAmount;

        (bool sent, ) = nodeRewardPool.call{
            value: (rewardPoolAmount * 13) / 20
        }("");
        require(sent, "Failed to send bnb");
        (bool sent1, ) = referrerRewardPool.call{
            value: (rewardPoolAmount * 7) / 20
        }("");
        require(sent1, "Failed to send bnb1");
        IReward(referrerRewardPool).addUserReward(
            businessAdds[1],
            address(0),
            businessInts[2],
            (rewardPoolAmount * 7) / 20
        );
        // payable(receiver).transfer(feeReceiverAmount);
        (bool sent2, ) = receiver.call{value: feeReceiverAmount}("");
        require(sent2, "Failed to send bnb2");
        emit Purchased(
            msg.sender,
            currentAmount,
            tokenAmount,
            businessAdds[1],
            (rewardPoolAmount * 7) / 20
        );
    }

    function setTokenAmountPerBnb(
        uint256 tokenAmountPerBnb_
    ) external onlyRole(MANAGE_ROLE) {
        _setPrice(tokenAmountPerBnb_);
    }

    function setRewardPool(address rewardPool_) external onlyRole(MANAGE_ROLE) {
        _setRewardPool(rewardPool_);
    }

    function _setPrice(uint256 tokenAmountPerBnb_) internal {
        require(tokenAmountPerBnb_ > 0, "price is zero");
        tokenAmountPerBnb = tokenAmountPerBnb_;
        emit PriceUpdated(tokenAmountPerBnb_);
    }

    function _setRewardPool(address rewardPool_) internal {
        require(rewardPool_ != address(0), "reward pool is zero");
        nodeRewardPool = rewardPool_;
        emit RewardPoolUpdated(rewardPool_);
    }

    function _setReceiver(address _receiver) internal {
        require(_receiver != address(0), "receiver is zero");
        receiver = _receiver;
        emit ReceiverUpdated(_receiver);
    }

    function balance(address token) public view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        revert("token balance disabled");
    }

    function setFuncSwitch(bool _funcSwitch) external onlyRole(MANAGE_ROLE) {
        funcSwitch = _funcSwitch;
        emit FuncSwitchUpdated(_funcSwitch);
    }

    function setSigner(address _signer) external onlyRole(MANAGE_ROLE) {
        _setSigner(_signer);
    }

    function setReferrerRewardPool(
        address _ReferrerRewardPool
    ) external onlyRole(MANAGE_ROLE) {
        _setReferrerRewardPool(_ReferrerRewardPool);
    }

    function _setSigner(address _signer) internal {
        signer = _signer;
    }

    function _setReferrerRewardPool(address _ReferrerRewardPool) internal {
        referrerRewardPool = _ReferrerRewardPool;
    }

    // function setREWARDPOOLRATE(
    //     uint _REWARD_POOL_RATE
    // ) external onlyRole(MANAGE_ROLE) {
    //     REWARD_POOL_RATE = _REWARD_POOL_RATE;
    // }

    function _parseData(
        bytes calldata data
    ) internal returns (address[] memory, uint256[] memory) {
        (
            address[] memory businessAdds,
            uint256[] memory businessInts,
            bytes memory signature
        ) = abi.decode(data, (address[], uint256[], bytes));
        require(businessAdds[0] == msg.sender, "Node: INVALID_USER");
        // require(businessInts[0] == nonces[msg.sender], "Node: INVALID_NONCE");
        require(block.timestamp <= businessInts[1], "Node: TIME OUT");
        _verify(businessAdds, businessInts, signature);
        // nonces[msg.sender]++;
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
            "Node: INVALID_REQUEST"
        );
    }

    function _recoverSignHash(
        address[] memory businessAdds,
        uint256[] memory businessInts
    ) internal view returns (bytes32) {
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(PERMIT_TYPEHASH, businessAdds, businessInts)
                )
            )
        );
        return signHash;
    }

    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65, "Not Invalid Signature Data");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}
