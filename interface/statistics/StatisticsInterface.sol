///////////////////////////////////////////////////////////////////////////////////
////                          Data statistics contract                          ///
///////////////////////////////////////////////////////////////////////////////////
///                                                                             ///
/// Record the statistics and operating data for the complete set of contracts  ///
/// within ETH Player                                                           ///
///                                                                             ///
///////////////////////////////////////////////////////////////////////////////////
///                                                          Mr.K by 2019/08/01 ///
///////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.5.0 <0.6.0;

interface StatisticsInterface {

    //Get referral profits record
    function GetDyHistory(uint256 offset, uint256 size) external view
    returns (
        uint256 len,
        address[] memory froms,
        uint256[] memory values,
        bool[] memory mtypes,
        uint256[] memory times);

    //Get join history
    function GetJoinedHistory() external view
    returns (
        uint256 len,
        uint256[] memory stime,
        uint256[] memory etime,
        uint256[] memory values);

    //Get static profits record
    function GetStaticProfitTotalAmount() external view returns (uint256);

    //Get the cumulative amount of referral profits
    function GetDynamicProfitTotalAmount() external view returns (uint256);

    //The following are the methods that can be called by the round contract, most of which are only for data statistics and have nothing to do with funds.
    function API_NewPlayer( address player ) external;

    //When the new address is invested, increase the statistics, who is the right amount to invest
    function API_NewJoin( address who, uint256 when, uint256 value ) external;

    //Whenever the address is settled, the record records which address is settled.
    function API_NewSettlement( address who, uint256 when ) external;

    //Add static cumulative data
    function API_AddStaticTotalAmount( address player, uint256 value ) external;

    //Add dynamic cumulative data
    function API_AddDynamicTotalAmount( address player, uint256 value ) external;

    //Used to record the dynamic revenue of a given address
    function API_PushNewDyProfit( address who, address where, uint256 value, bool mtype ) external;

    //Add new statistics when the new address is activated
    function API_AddActivate() external;
}
