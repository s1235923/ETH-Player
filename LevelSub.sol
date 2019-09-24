pragma solidity >=0.5.0 <0.6.0;

import "./interface/levelsub/LevelSubInterface.sol";
import "./interface/recommend/RecommendInterface.sol";
import "./InternalModule.sol";

contract LevelSub is LevelSubInterface, InternalModule {

    RecommendInterface  private _recommendInf;

    //Hierarchical mechanism maximum traversal depth limit
    uint256             public _searchReommendDepth = 15;
    //Differential search maximum depth
    uint256             public _searchLvLayerDepth = 1024;
    //Step parameter, percentage
    uint256[]           public _subProfits = [0, 5, 5, 5, 5];
    //Flat award percentage
    uint256             public _equalLvProp = 10;
    //Level award
    uint256             public _equalLvMaxLimit = 3;
    //Level reward search depth
    uint256             public _equalLvSearchDepth = 10;

    mapping ( address => uint256 ) _ownerLevelsMapping;

    constructor( RecommendInterface recomm ) public {
        _recommendInf = recomm;
    }

    function GetLevelSubValues() external view returns (uint256[] memory _values) {
        return _subProfits;
    }

    function LevelOf( address _owner ) public view returns (uint256 lv) {
        return _ownerLevelsMapping[_owner];
    }

    //Whether the conditions for updating the user's level are met
    function CanUpgradeLv( address _rootAddr ) public view returns (int) {

        //If it is already the highest level set, it is not allowed to continue the upgrade.
        require( _ownerLevelsMapping[_rootAddr] < _subProfits.length - 1, "Level Is Max" );

        uint256 effCount = 0;
        address[] memory referees;

        if ( _ownerLevelsMapping[_rootAddr] == 0 ) {

            referees = _recommendInf.RecommendList(_rootAddr, 0);

            for (uint i = 0; i < referees.length; i++) {

                if ( _recommendInf.IsValidMember( referees[i] ) ) {

                    if ( ++effCount >= 10 ) {
                        break;
                    }
                }
            }

            if ( effCount < 10 ) {
                //Indicates that the first condition is not met
                return -1;
            }

            if ( _recommendInf.InvestTotalEtherOf(msg.sender) < 10 ether ) {
                return -2;
            }

            //There are 100 active addresses in the team (within 15 floors)
            if ( _recommendInf.ValidMembersCountOf(msg.sender) < 100 ) {
                return -3;
            }

            return 1;
        }
        // Lv.n(n != 0) -> Lv.(n + 1)
        else {

            uint256 targetLv = _ownerLevelsMapping[_rootAddr] + 1;

            referees = _recommendInf.RecommendList(_rootAddr, 0);

            for (uint i = 0; i < referees.length; i++) {

                if ( LevelOf( referees[i] ) >= targetLv - 1 ) {

                    effCount ++;

                    if ( effCount >= 3 ) {
                        break;
                    }

                    continue;

                } else {

                    // If the direct push is not satisfied, search for 9 layers to see if there is a user who meets the condition.
                    // Since a layer of direct push has been searched, this is 14 layers, so _searchReommendDepth - 1
                    for ( uint d = 0; d < _searchReommendDepth - 1; d++ ) {

                        address[] memory grandchildren = _recommendInf.RecommendList( referees[i], d );

                        for ( uint256 z = 0; z < grandchildren.length; z ++ ) {

                            if ( LevelOf( grandchildren[z] ) >= targetLv - 1 ) {

                                effCount ++;

                                break;
                            }

                        }

                        if ( effCount >= 3 ) {
                            break;
                        }

                    }

                    if ( effCount >= 3 ) {
                        break;
                    }

                }

            }

            if ( effCount >= 3 ) {

                return int(targetLv);

            } else {

                return -1;
            }

        }
    }

    //升级
    function DoUpgradeLv( ) external returns (uint256) {

        int canMakeToTargetLv = CanUpgradeLv(msg.sender);

        if ( canMakeToTargetLv > 0 ) {
            _ownerLevelsMapping[msg.sender] = uint256(canMakeToTargetLv);
        }

        return _ownerLevelsMapping[msg.sender];
    }

    // Calculate the return, not for sending only to provide income calculation,
    // and for whether to send the proceeds, the above contract decides
    // The difference income calculation, the rule is defined as:
    // Search the total _searchLvLayerDepth layer from the Root address, and send
    // the level difference if you find a user with a higher level than yourself.
    // v2: Add a level bonus, the rule is: the settlement user is the nearest manager
    //     N level L, and then the manager is the starting node.
    // Search up to 10 layers and get 0-3 levels <= L users send 10% of N earnings
    function ProfitHandle( address _owner, uint256 _amount ) external view
    returns ( uint256 len, address[] memory addrs, uint256[] memory profits ) {

        uint256[] memory tempProfits = _subProfits;

        address parent = _recommendInf.GetIntroducer(_owner);

        if ( parent == address(0x0) ) {
            return (0, new address[](0), new uint256[](0));
        }

        /// V1
        // len = _subProfits.length;
        // addrs = new address[](len);
        // profits = new uint256[](len);
        len = _subProfits.length + _equalLvMaxLimit;
        addrs = new address[](len);
        profits = new uint256[](len);

        uint256 currlv = 0;
        uint256 plv = _ownerLevelsMapping[parent];

        address nearestAddr;
        uint256 nearestProfit;

        // End of the loop condition is:
        // When looking up, find the first user with level 4, you should stop the loop immediately
        for ( uint i = 0; i < _searchLvLayerDepth; i++ ) {

            // level difference income judgment
            // Find the first user with a higher level than yourself
            // and the level difference of the corresponding level has not yet been received
            if ( plv > currlv && tempProfits[plv] > 0 ) {

                uint256 psum = 0;

                for ( uint x = plv; x > 0; x-- ) {

                    psum += tempProfits[x];

                    tempProfits[x] = 0;
                }

                if ( psum > 0 ) {

                    if ( nearestAddr == address(0x0) && plv > 1 ) {
                        nearestAddr = parent;
                        nearestProfit = (_amount * psum) / 100;
                    }

                    addrs[plv] = parent;
                    profits[plv] = (_amount * psum) / 100;
                }
            }

            parent = _recommendInf.GetIntroducer(parent);

            //The highest level has been found, and the differential gains have been correctly processed, stopping the loop directly
            if ( plv >= _subProfits.length - 1 || parent == address(0x0) ) {
                break;
            }

            plv = _ownerLevelsMapping[parent];
        }

        // Flat reward judgment
        // v2: Add a level bonus, the rule is: the settlement user is the nearest manager N level L,
        //     and then the manager is the starting node.
        //     Search up to 10 layers and get 0-3 levels <= L users send 10% of N earnings P
        uint256 L = _ownerLevelsMapping[nearestAddr];

        if ( nearestAddr != address(0x0) && L > 1 && nearestProfit > 0 ) {

            parent = nearestAddr;

            uint256 indexOffset = _subProfits.length - 1;

            for (uint j = 0; j < _equalLvSearchDepth; j++) {

                parent = _recommendInf.GetIntroducer(parent);
                plv = _ownerLevelsMapping[parent];

                if ( plv <= L && plv > 1 ) {

                    // reached
                    addrs[indexOffset] = parent;
                    profits[indexOffset] = (nearestProfit * _equalLvProp) / 100;

                    if ( indexOffset + 1 >= len ) {
                        break;
                    }

                    indexOffset++;
                }
            }

        }

        return (len, addrs, profits);
    }
}
