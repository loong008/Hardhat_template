// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Staking is AccessControlEnumerable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    bool public funcSwitch;

    address[] public feeReceivers;

    mapping(address => uint) public userStakingAmounts;

    address public receiver;

    address public signer;

    bytes32 public DOMAIN_SEPARATOR;

    /* 
        staking:
        businessAdds: 0-user; 1-lpToken;
        businessInts: 0-nonce;1-deadline;2-stakingAmount;3-action【1 = stake, 2 = redeem】

        redeem:
        businessAdds: 0-user; 1-lpToken;
        businessInts: 0-nonce;1-deadline;2-redeemAmount;3-action【1 = stake, 2 = redeem】
     */

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Permit(address[] businessAdds,uint256[] businessInts)"
            )
        );

    event FuncSwitchUpdated(bool enabled);
    event SignerUpdated(address signer);
    event Staked(address[] businessAdds, uint256[] businessInts);
    event Redeemed(address[] businessAdds, uint256[] businessInts);

    constructor(address receiver_, address signer_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGE_ROLE, msg.sender);

        receiver = receiver_;
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
                keccak256(bytes("Staking")),
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

    function setFuncSwitch(bool _funcSwitch) external onlyRole(MANAGE_ROLE) {
        funcSwitch = _funcSwitch;
        emit FuncSwitchUpdated(_funcSwitch);
    }

    function setSigner(address signer_) external onlyRole(MANAGE_ROLE) {
        _setSigner(signer_);
    }

    function setReceiver(address receiver_) external onlyRole(MANAGE_ROLE) {
        require(receiver_ != address(0), "Staking: zero address");
        receiver = receiver_;
    }

    function balance(address token) external view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20(token).balanceOf(address(this));
    }

    function stake(bytes calldata data) external payable nonReentrant {
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }
        require(!funcSwitch, "staking disabled");
        (
            address[] memory businessAdds,
            uint256[] memory businessInts
        ) = _parseData(data);
        require(businessInts[3] == 1, "Staking: action error");
        uint userStakingAmount = userStakingAmounts[businessAdds[0]];
        require(userStakingAmount == 0, "Staking: already stake");
        IERC20(businessAdds[1]).safeTransferFrom(
            businessAdds[0],
            receiver,
            businessInts[2]
        );
        userStakingAmounts[businessAdds[0]] += businessInts[2];
        emit Staked(businessAdds, businessInts);
    }

    function redeem(bytes calldata data) external payable nonReentrant {
        if (msg.value > 0) {
            payable(_getRandomReceiver()).transfer(msg.value);
        }
        require(!funcSwitch, "staking disabled");
        (
            address[] memory businessAdds,
            uint256[] memory businessInts
        ) = _parseData(data);
        require(businessInts[3] == 2, "Staking: action error");
        uint userStakingAmount = userStakingAmounts[businessAdds[0]];
        require(userStakingAmount == businessInts[2], "Staking: already stake");
        IERC20(businessAdds[1]).safeTransfer(businessAdds[0], businessInts[2]);
        userStakingAmounts[businessAdds[0]] -= businessInts[2];
        emit Redeemed(businessAdds, businessInts);
    }

    function _setSigner(address signer_) internal {
        require(signer_ != address(0), "signer is zero");
        signer = signer_;
        emit SignerUpdated(signer_);
    }

    function _parseData(
        bytes calldata data
    ) internal view returns (address[] memory, uint256[] memory) {
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
