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

    modifier deploymentExists(address user, bool exists) {
        require(
            exists == (_applications[user] != address(0)),
            "AppRegistry: Deployment not found"
        );
        _;
    }

    modifier isContract(address _address) {
        require(
            _address.code.length > 0,
            "AppRegistry: Address is not a contract"
        );
        _;
    }

    modifier isOperatorOrOwner(address user) {
        require(
            hasRole(OPERATOR_ROLE, msg.sender) || msg.sender == user,
            "AppRegistry: Not authorized"
        );
        _;
    }

    function getUserDeployment(address user)
        public
        view
        deploymentExists(user, true)
        returns (address)
    {
        return _applications[user];
    }

    function add(address user, address deployment)
        public
        deploymentExists(user, false)
        isContract(deployment)
        isOperatorOrOwner(user)
    {
        _applications[user] = deployment;

        emit ApplicationRegistered(user, deployment);
    }

    function remove(address user)
        public
        deploymentExists(user, true)
        isOperatorOrOwner(user)
    {
        address app = _applications[user];

        delete _applications[user];

        emit ApplicationRemoved(user, app);
    }
}
