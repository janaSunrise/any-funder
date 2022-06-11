// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract AppRegistry is AccessControlEnumerable {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    // Mapping to hold user address => any funder contract address.
    mapping(address => address) private _applications;

    // Events for the contract
    event ApplicationRegistered(address user, address deployment);
    event ApplicationRemoved(address user, address deployment);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OPERATOR_ROLE, msg.sender);
    }

    modifier isValidParams(address user, address deployment) {
        require(user != address(0), "User cant be zero address");
        require(deployment != address(0), "Deployment cant be zero address");
        _;
    }

    modifier existingDeployment(address user, bool exists) {
        require(
            exists == (_applications[user] != address(0)),
            "Deployment not found"
        );
        _;
    }

    modifier isContract(address _address) {
        require(_address.code.length > 0, "Address is not a contract");
        _;
    }

    function getUserDeployment(address user)
        public
        view
        existingDeployment(user, true)
        returns (address)
    {
        return _applications[user];
    }

    function add(address user, address deployment)
        public
        isValidParams(user, deployment)
        existingDeployment(user, false)
        isContract(deployment)
    {
        require(
            hasRole(OPERATOR_ROLE, msg.sender) || msg.sender == user,
            "Not authorized"
        );

        _applications[user] = deployment;

        emit ApplicationRegistered(user, deployment);
    }

    function remove(address user) public existingDeployment(user, true) {
        require(
            hasRole(OPERATOR_ROLE, msg.sender) || msg.sender == user,
            "Not authorized"
        );

        delete _applications[user];

        emit ApplicationRemoved(user, _applications[user]);
    }
}
