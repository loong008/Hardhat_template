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

contract NodeReward is
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    bool public funcSwitch;

    bytes32 public DOMAIN_SEPARATOR;

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Permit(address user,address token,uint256 order,uint256 amount,uint256 nonce,uint256 deadline)"
            )
        );

    address public signer;

    mapping(address => uint) public nonces;

    address[] public feeReceivers;

    event WithdrawReward(
        address indexed caller,
        address indexed token,
        uint256 amount,
        uint256 timestamp,
        uint256 order
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

        signer = _signer;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("NodeReward")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    receive() external payable {}

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

    function setSigner(address _signer) public onlyRole(MANAGE_ROLE) {
        signer = _signer;
    }

    function setFuncSwitch(bool _funcSwitch) public onlyRole(MANAGE_ROLE) {
        funcSwitch = _funcSwitch;
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

    function withdrawReward(bytes memory data) public payable nonReentrant {
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }
        require(!funcSwitch, "Reward: Unsupported operation");
        (
            address user,
            address token,
            uint256 order,
            uint256 amount,
            uint256 nonce,
            uint256 deadline,
            bytes memory signature
        ) = abi.decode(
                data,
                (address, address, uint256, uint256, uint256, uint256, bytes)
            );
        require(user == msg.sender, "Reward:INVALID_USER");
        require(nonce == nonces[msg.sender], "Reward:INVALID_NONCE");
        require(block.timestamp <= deadline, "Reward: TIME OUT");
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        bytes32 signHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        user,
                        token,
                        order,
                        amount,
                        nonce,
                        deadline
                    )
                )
            )
        );
        require(
            signer == ecrecover(signHash, v, r, s),
            "Reward:INVALID_REQUEST"
        );
        nonces[msg.sender]++;
        //send token
        if (token != address(0)) {
            IERC20Upgradeable(token).safeTransfer(user, amount);
        } else {
            payable(user).transfer(amount);
        }
        emit WithdrawReward(msg.sender, token, amount, block.timestamp, order);
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
