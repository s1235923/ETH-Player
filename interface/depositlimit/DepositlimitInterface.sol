///////////////////////////////////////////////////////////////////////////////////
////                        Withdraw fee calculation contract                   ///
///////////////////////////////////////////////////////////////////////////////////
///                                                                             ///
/// This contract is used to store the maximum amount of EPK an address can     ///
/// exchange. As the maximum amount of ETH a user can invest is independent of  ///
/// the game rounds, a separate contract is used to record the maximum amount   ///
/// of ETH a user can invest and the corresponding update method                ///
///                                                                             ///
///////////////////////////////////////////////////////////////////////////////////
///                                                          Mr.K by 2019/08/01 ///
///////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.5.0 <0.6.0;

interface DepositLimitInterface {

    //Add deposit limit to specified user, and only the current round contract has the right to operate
    function API_AddDepositLimit( address ownerAddr, uint256 value, uint256 maxlimit ) external;

    //Gets the maximum deposit limit for the specified address
    function DepositLimitOf( address ownerAddr ) external view returns (uint256);

}
