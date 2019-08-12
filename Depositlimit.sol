pragma solidity >=0.5.0 <0.6.0;

import "./interface/depositlimit/DepositLimitInterface.sol";
import "./InternalModule.sol";

contract DepositLimit is DepositLimitInterface,InternalModule {

    mapping (address => uint256) _limitMapping;

    uint256 private _defaultLimit = 10 ether;

    constructor(uint256 defaultlimit) public {
        _defaultLimit = defaultlimit;
    }

    function API_AddDepositLimit( address ownerAddr, uint256 value, uint256 maxlimit ) external APIMethod {

        if ( _limitMapping[ownerAddr] == 0 ) {

            _limitMapping[ownerAddr] = _defaultLimit;

        }

        if ( _limitMapping[ownerAddr] + value > maxlimit ) {

            _limitMapping[ownerAddr] = maxlimit;

        } else {

            _limitMapping[ownerAddr] += value;

        }
    }

    function DepositLimitOf( address ownerAddr ) external view returns (uint256) {

        if ( _limitMapping[ownerAddr] == 0 ) {
            return _defaultLimit;
        }

        return _limitMapping[ownerAddr];
    }

}
