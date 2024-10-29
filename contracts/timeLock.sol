// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

contract TimeLock{

    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);

    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);
    
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);

    event NewAdmin(address indexed newAdmin);

    address public admin;
    uint public constant GRACE_PERIOD = 7 days;
    uint public delay;
    mapping(bytes32 => bool) public queuedTransactions;

    modifier onlyOwner() {
        require(msg.sender == admin, "caller not admin");
        _;
    }

    modifier onlyTimeLock() {
        require(msg.sender == address(this), "caller not timeLock");
        _;
    }

    constructor(uint delay_) {
        delay = delay_;
        admin = msg.sender;
    } 

    function changeAdmin(address newAdmin) public onlyTimeLock{
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }

    function queueTransaction(address target, uint256 value , string memory signature, bytes memory data, uint256 executeTime) public onlyOwner returns (bytes32) {
        require(executeTime >= getBlockTimestamp() + delay, "time not satisfy");
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        queuedTransactions[txHash] = true;
        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
        return txHash;
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        require(queuedTransactions[txHash], "not queued the transaction");
        queuedTransactions[txHash] = false;
        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
    }

    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public payable onlyOwner returns (bytes memory) {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        require(queuedTransactions[txHash], "not queue the transaction");
        require(getBlockTimestamp() >= executeTime, "time not ok");
        require(getBlockTimestamp() <= executeTime + GRACE_PERIOD, "out of date");
        queuedTransactions[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "execute failed");
        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);
        return returnData;
    } 

    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    function getTxHash(address target, uint value, string memory signature, bytes memory data, uint executeTime) public pure returns(bytes32) {
        return keccak256(abi.encode(target,value, signature, data, executeTime));
    }
}