// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;

library LibAccessControl {
    struct RoleData {
        mapping(address => bool) hasRole;
        bytes32 adminRole;
    }

    struct AccessControlStorage {
        // mapping of RoleData from role hash
        mapping(bytes32 => RoleData) roles;
    }

    // keccak256(abi.encode(uint256(keccak256("accesscontrol.diamond.storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ACCESSCONTROL_STORAGE_LOCATION =
        0xe471e713c9a965e7cfdb171823937800543dd0e61d862db2e99ecd80ebee8400;

    function _getAccessControlStorage() internal pure returns (AccessControlStorage storage $) {
        assembly {
            $.slot := ACCESSCONTROL_STORAGE_LOCATION
        }
    }

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        AccessControlStorage storage ds = _getAccessControlStorage();

        return ds.roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view {
        _checkRole(role, msg.sender);
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert IAccessControl.AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        AccessControlStorage storage ds = _getAccessControlStorage();

        return ds.roles[role].adminRole;
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _getAccessControlStorage().roles[role].adminRole = adminRole;
        emit IAccessControl.RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal returns (bool) {
        if (!hasRole(role, account)) {
            _getAccessControlStorage().roles[role].hasRole[account] = true;
            emit IAccessControl.RoleGranted(role, account, msg.sender);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal returns (bool) {
        AccessControlStorage storage ds = _getAccessControlStorage();

        if (hasRole(role, account)) {
            ds.roles[role].hasRole[account] = false;
            emit IAccessControl.RoleRevoked(role, account, msg.sender);
            return true;
        } else {
            return false;
        }
    }
}
