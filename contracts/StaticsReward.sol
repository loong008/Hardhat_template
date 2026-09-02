// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IPreSale {
    function reservedTokens(address account) external view returns (uint);
}

contract StaticsReward is
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    bytes32 public constant OPERATE_ROLE = keccak256("OPERATE_ROLE");

    bool public funcSwitch;

    address[] public feeReceivers;

    //user => token => businessId => amount
    mapping(address => mapping(address => mapping(uint => uint)))
        public userRewards;

    address public signer;
    mapping(address => uint256) public nonces;
    bytes32 public DOMAIN_SEPARATOR;

    /* 
        businessAdds: 0-user;1-rewardToken;
        businessInts: 0-nonce;1-deadline;2-businessId;3-rewardAmont
     */
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Permit(address[] businessAdds,uint256[] businessInts)"
            )
        );

    IPreSale public preSale;
    address public XClaw;

    //user => token => businessId => amount;
    mapping(address => mapping(address => mapping(uint => uint)))
        public withdrawAmounts;

    event AddUserReward(
        address account,
        address rewardToken,
        uint businessId,
        uint addRewardAmount
    );

    event BatchAddUserReward(
        address[] accounts,
        address rewardToken,
        uint businessId,
        uint[] addRewardAmounts
    );

    event Withdraw(
        address account,
        address withdrawToken,
        uint businessId,
        uint withdrawRewardAmount,
        uint id
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(MANAGE_ROLE) {}

    function initialize(address _signer) public initializer {
        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);

        _setSigner(_signer);
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("StaticsReward")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    receive() external payable {}

    function setParams(
        IPreSale _preSale,
        address _XClaw
    ) external onlyRole(MANAGE_ROLE) {
        preSale = _preSale;
        XClaw = _XClaw;
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

    function balance(address token) public view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20Upgradeable(token).balanceOf(address(this));
    }

    // function withdrawErc20(
    //     address token,
    //     address to,
    //     uint256 amount
    // ) public onlyRole(MANAGE_ROLE) {
    //     uint256 tokenBalance = IERC20Upgradeable(token).balanceOf(
    //         address(this)
    //     );
    //     require(tokenBalance >= amount, "ERROR:INSUFFICIENT");
    //     IERC20Upgradeable(token).safeTransfer(to, amount);
    // }

    function withdrawBNB(
        address to,
        uint256 amount
    ) public onlyRole(MANAGE_ROLE) {
        uint256 bnbBalance = payable(address(this)).balance;
        require(bnbBalance >= amount, "ERROR:INSUFFICIENT");
        payable(to).transfer(amount);
    }

    function setFuncSwitch(bool _funcSwitch) public onlyRole(MANAGE_ROLE) {
        funcSwitch = _funcSwitch;
    }

    function setSigner(address _signer) external onlyRole(MANAGE_ROLE) {
        _setSigner(_signer);
    }

    function _setSigner(address _signer) internal {
        signer = _signer;
    }

    function batchtSetNonces(
        address[] calldata _accounts,
        uint[] calldata _nonces
    ) external onlyRole(MANAGE_ROLE) {
        require(
            _accounts.length == _nonces.length && _accounts.length > 0,
            "StaticsReward: array length error"
        );
        for (uint i = 0; i < _accounts.length; i++) {
            nonces[_accounts[i]] = _nonces[i];
        }
    }

    function addUserReward(
        address account,
        address rewardToken,
        uint businessId,
        uint rewardAmount
    ) external onlyRole(OPERATE_ROLE) {
        userRewards[account][rewardToken][businessId] += rewardAmount;
        emit AddUserReward(account, rewardToken, businessId, rewardAmount);
    }

    function batchAddUserReward(
        address[] calldata accounts,
        address rewardToken,
        uint businessId,
        uint[] calldata rewardAmounts
    ) external onlyRole(OPERATE_ROLE) {
        require(
            accounts.length == rewardAmounts.length && accounts.length > 0,
            "array length error"
        );
        for (uint i = 0; i < accounts.length; i++) {
            userRewards[accounts[i]][rewardToken][businessId] += rewardAmounts[
                i
            ];
        }
        emit BatchAddUserReward(
            accounts,
            rewardToken,
            businessId,
            rewardAmounts
        );
    }

    function batchAddUserReward1(
        address[] calldata accounts,
        address rewardToken,
        uint businessId,
        uint[] calldata rewardAmounts
    ) external onlyRole(MANAGE_ROLE) {
        require(
            accounts.length == rewardAmounts.length && accounts.length > 0,
            "array length error"
        );
        for (uint i = 0; i < accounts.length; i++) {
            userRewards[accounts[i]][rewardToken][businessId] += rewardAmounts[
                i
            ];
        }
        emit BatchAddUserReward(
            accounts,
            rewardToken,
            businessId,
            rewardAmounts
        );
    }

    // function withdraw(
    //     uint withdrawAmount,
    //     address withdrawToken
    // ) external payable nonReentrant {
    //     if (msg.value > 0) {
    //         payable(_getRandomReceiver()).transfer(msg.value);
    //     }
    //     require(!funcSwitch, "Reward: Unsupported operation");
    //     require(
    //         withdrawAmount > 0 &&
    //             userRewards[msg.sender][withdrawToken] >= withdrawAmount,
    //         "Reward: Exceed Reward Amount"
    //     );
    //     userRewards[msg.sender][withdrawToken] -= withdrawAmount;
    //     IERC20Upgradeable(withdrawToken).safeTransfer(
    //         msg.sender,
    //         withdrawAmount
    //     );
    //     emit Withdraw(
    //         msg.sender,
    //         withdrawToken,
    //         withdrawAmount,
    //         userRewards[msg.sender][withdrawToken]
    //     );
    // }

    function withdraw(bytes calldata data) external payable nonReentrant {
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }
        require(!funcSwitch, "StaticsReward: Unsupported operation");
        (
            address[] memory businessAdds,
            uint256[] memory businessInts
        ) = _parseData(data);
        require(
            businessInts[3] > 0 &&
                businessInts[3] <=
                userRewards[businessAdds[0]][businessAdds[1]][businessInts[2]],
            "StaticsReward: reward amount error"
        );
        // withdrawAmounts[businessAdds[0]][businessAdds[1]][
        //     businessInts[2]
        // ] += businessInts[3];
        // if (XClaw != address(0) && address(preSale) != address(0)) {
        //     uint allPreSaleAmount = preSale.reservedTokens(businessAdds[0]);
        //     require(
        //         withdrawAmounts[businessAdds[0]][businessAdds[1]][
        //             businessInts[2]
        //         ] <= allPreSaleAmount,
        //         "StaticsReward: exceed presale amount"
        //     );
        // }
        userRewards[businessAdds[0]][businessAdds[1]][
            businessInts[2]
        ] -= businessInts[3];
        if (businessAdds[1] != address(0)) {
            IERC20Upgradeable(businessAdds[1]).transfer(
                businessAdds[0],
                businessInts[3]
            );
        } else {
            payable(businessAdds[0]).transfer(businessInts[3]);
        }
        emit Withdraw(
            businessAdds[0],
            businessAdds[1],
            businessInts[2],
            businessInts[3],
            businessInts[4]
        );
    }

    function _parseData(
        bytes calldata data
    ) internal returns (address[] memory, uint256[] memory) {
        (
            address[] memory businessAdds,
            uint256[] memory businessInts,
            bytes memory signature
        ) = abi.decode(data, (address[], uint256[], bytes));
        require(businessAdds[0] == msg.sender, "Node: INVALID_USER");
        require(businessInts[0] == nonces[msg.sender], "Node: INVALID_NONCE");
        require(block.timestamp <= businessInts[1], "Node: TIME OUT");
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
