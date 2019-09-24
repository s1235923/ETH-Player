pragma solidity >=0.5.0 <0.6.0;

interface LuckAssetsPoolInterface {

    /// get my reward prices
    function RewardsAmount() external view returns (uint256);

    /// withdraw my all rewards
    function WithdrawRewards() external returns (uint256);

    function InPoolProp() external view returns (uint256);

    /// append user to latest.
    function API_AddLatestAddress( address owner, uint256 amount ) external;

    /// Winning the prize !!!!
    function API_WinningThePrize() external;
}
