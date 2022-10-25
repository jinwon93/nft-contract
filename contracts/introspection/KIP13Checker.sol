pragma solidity ^0.5.0;


library KIP13Checker {
    
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    
    bytes4 private constant _INTERFACE_ID_KIP13 = 0x01ffc9a7;

    
    function _supportsKIP13(address account) internal view returns (bool) {
        
        return _supportsKIP13Interface(account, _INTERFACE_ID_KIP13) &&
            !_supportsKIP13Interface(account, _INTERFACE_ID_INVALID);
    }

    
    function _supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        
        return _supportsKIP13(account) &&
            _supportsKIP13Interface(account, interfaceId);
    }

    
    function _supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        
        if (!_supportsKIP13(account)) {
            return false;
        }

        
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsKIP13Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        
        return true;
    }

    
    function _supportsKIP13Interface(address account, bytes4 interfaceId) private view returns (bool) {
        
        (bool success, bool result) = _callKIP13SupportsInterface(account, interfaceId);

        return (success && result);
    }

    
    function _callKIP13SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool success, bool result)
    {
        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_KIP13, interfaceId);

        // solhint-disable-next-line no-inline-assembly
        assembly {
            let encodedParams_data := add(0x20, encodedParams)
            let encodedParams_size := mload(encodedParams)

            let output := mload(0x40)    
            mstore(output, 0x0)

            success := staticcall(
                30000,                   // 30k gas
                account,                 // To addr
                encodedParams_data,
                encodedParams_size,
                output,
                0x20                     // Outputs are 32 bytes long
            )

            result := mload(output)      // Load the result
        }
    }
}