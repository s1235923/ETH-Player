pragma solidity >=0.5.0 <0.6.0;

import "./interface/statistics/StatisticsInterface.sol";
import "./InternalModule.sol";

contract Statistics is StatisticsInterface, InternalModule {

    mapping(address => uint256) _staticProfixTotalMapping;

    mapping(address => uint256) _dynamicProfixTotalMapping;

    mapping(address => bool) _playerAddresses;

    uint256 public JoinedPlayerTotalCount = 0;

    uint256 public JoinedGameTotalCount = 0;

    uint256 public AllWithdrawEtherTotalCount = 0;

    uint256 public ActivateUserCount = 0;

    struct Deposited {

        uint256 startTime;

        uint256 endTime;

        uint256 joinEther;

        bool redressable;
    }

    struct DyProfit {
        address formAddress;
        uint256 value;
        bool managerType;
        uint256 time;
    }

    mapping( address => DyProfit[] ) _dyHistory;

    mapping( address => Deposited[] ) _joinedHistory;

    constructor() public {

    }

    function GetDyHistory(uint256 offset, uint256 size) external view
    returns (
        uint256 len,
        address[] memory froms,
        uint256[] memory values,
        bool[] memory mtypes,
        uint256[] memory times
    ) {

        DyProfit[] memory lists = _dyHistory[msg.sender];
        len = lists.length;

        uint256 rsize = size;

        if ( offset + size > len ) {
            rsize = len - offset;
        }

        froms = new address[]( rsize );
        values = new uint256[]( rsize );
        mtypes = new bool[]( rsize );
        times = new uint256[]( rsize );

        for ( uint256 i = offset; (i < offset + rsize && i < len); i++ ) {
            froms[i] = lists[i].formAddress;
            values[i] = lists[i].value;
            mtypes[i] = lists[i].managerType;
            times[i] = lists[i].time;
        }

    }

    function GetJoinedHistory() external view
    returns (
        uint256 len,
        uint256[] memory stime,
        uint256[] memory etime,
        uint256[] memory values) {

        Deposited[] memory lists = _joinedHistory[msg.sender];
        len = lists.length;

        stime = new uint256[](len);
        etime = new uint256[](len);
        values = new uint256[](len);

        for (uint i = 0; i < len; i++) {
            stime[i] = lists[i].startTime;
            etime[i] = lists[i].endTime;
            values[i] = lists[i].joinEther;
        }

    }

    function GetStaticProfitTotalAmount() external view returns (uint256) {
        return _staticProfixTotalMapping[msg.sender];
    }

    function GetDynamicProfitTotalAmount() external view returns (uint256) {
        return _dynamicProfixTotalMapping[msg.sender];
    }

    function API_NewPlayer( address player ) external APIMethod {

        if (_playerAddresses[player] == false){
            _playerAddresses[player] = true;
            JoinedPlayerTotalCount ++;
        }
    }

    function API_NewJoin( address who, uint256 when, uint256 value ) external APIMethod {

        Deposited[] storage depositList = _joinedHistory[who];

        depositList.push( Deposited( when, 0, value, false ) );

        JoinedGameTotalCount ++;
    }

    function API_NewSettlement( address who, uint256 when ) external APIMethod {

        Deposited[] storage depositList = _joinedHistory[who];

        depositList[depositList.length - 1].endTime = when;
    }

    function API_AddStaticTotalAmount( address player, uint256 value ) external APIMethod {
        _staticProfixTotalMapping[player] += value;
        AllWithdrawEtherTotalCount += value;
    }

    function API_AddDynamicTotalAmount( address player, uint256 value ) external APIMethod {
        _dynamicProfixTotalMapping[player] += value;
        AllWithdrawEtherTotalCount += value;
    }

    function API_PushNewDyProfit( address who, address where, uint256 value, bool mtype ) external APIMethod {
        _dyHistory[who].push( DyProfit(where, value, mtype, now) );
    }

    function API_AddActivate() external APIMethod {
        ActivateUserCount ++;
    }

}
