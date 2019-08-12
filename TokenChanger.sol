pragma solidity >=0.5.0 <0.6.0;

import "./interface/token/ERC20Interface.sol";
import "./interface/change/ChangeInterface.sol";

contract TokenChanger is TokenChangerInterface {


    struct ChangeRound {
        uint8   roundID;
        uint256 totalToken;
        uint256 propETH;
        uint256 changed;
    }

    ChangeRound[] _rounds;
    uint8 public CurrIdX = 0;
    ERC20Interface _ERC20Inc;


    uint256 _changeMinLimit = 10000000000000000;


    event Event_ChangedToken(address indexed owner, uint8 indexed round, uint256 indexed value);

    address payable private _ownerAddress;

    constructor(ERC20Interface erc20inc) public {

        _ownerAddress = msg.sender;
        _ERC20Inc = erc20inc;

        ChangeRound memory r1 = ChangeRound(1, 1000000000000000000000000,  6000000000000000000000, 0);
        ChangeRound memory r2 = ChangeRound(2, 2000000000000000000000000,  5000000000000000000000, 0);
        ChangeRound memory r3 = ChangeRound(3, 3000000000000000000000000,  4000000000000000000000, 0);
        ChangeRound memory r4 = ChangeRound(4, 4000000000000000000000000,  3000000000000000000000, 0);
        ChangeRound memory r5 = ChangeRound(5, 50000000000000000000000000, 2000000000000000000000, 0);
        ChangeRound memory r6 = ChangeRound(6, 60000000000000000000000000, 1000000000000000000000, 0);

        _rounds.push(r1);
        _rounds.push(r2);
        _rounds.push(r3);
        _rounds.push(r4);
        _rounds.push(r5);
        _rounds.push(r6);
    }

    function ChangeRoundAt(uint8 rid) external view returns (uint8 roundID, uint256 total, uint256 prop, uint256 changed) {

        require( rid < _rounds.length, "TC_ERR_004" );

        return (
        _rounds[rid].roundID,
        _rounds[rid].totalToken,
        _rounds[rid].propETH,
        _rounds[rid].changed);
    }

    function CurrentRound() external view returns (uint8 roundID, uint256 total, uint256 prop, uint256 changed) {

        if ( CurrIdX >= _rounds.length ) {
            //轮次已经全部结束
            return (0, 0, 0, 0);
        }

        return (
        _rounds[CurrIdX].roundID,
        _rounds[CurrIdX].totalToken,
        _rounds[CurrIdX].propETH,
        _rounds[CurrIdX].changed);

    }

    function DoChangeToken() external payable {

        // /2019-08-08 12:00
        require( now >= 1565236800 );

        require( msg.value >= _changeMinLimit, "TC_ERR_001" );
        require( msg.value % _changeMinLimit == 0, "TC_ERR_002" );
        require( CurrIdX < _rounds.length, "TC_ERR_006");
        // require( _roundContractAddress != address(0x0), "TC_ERR_005" );
        ChangeRound storage currRound = _rounds[CurrIdX];


        uint256 minLimitProp = currRound.propETH / ( 1 ether / _changeMinLimit );
        uint256 ctoken = (msg.value / _changeMinLimit) * minLimitProp;


        require ( currRound.changed + ctoken <= currRound.totalToken, "TC_ERR_003" );

        _ERC20Inc.transfer( msg.sender, ctoken );
        _ownerAddress.transfer( address(this).balance );

        emit Event_ChangedToken( msg.sender, CurrIdX, msg.value );


        if ( (currRound.changed + ctoken + minLimitProp) >= currRound.totalToken ) {

            CurrIdX++;
        }

        currRound.changed += ctoken;
    }
}
