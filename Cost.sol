pragma solidity >=0.5.0 <0.6.0;

import "./interface/cost/CostInterface.sol";
import "./InternalModule.sol";

contract Cost is CostInterface, InternalModule {

    // Current handling fee percentage
    uint256 public _costProp = 3;

    // Current exchange rate
    uint256 public _prop = 4000 ether;

    constructor( uint256 defaultProp, uint256 costprop ) public {

        _prop = defaultProp;

        _costProp = costprop;
    }

    function CurrentCostProp() external view returns (uint256) {
        return _prop;
    }

    function WithdrawCost(uint256 value) external view returns (uint256) {
        return ((value * 3 / 100) * _prop) / 1 ether;
    }
}
