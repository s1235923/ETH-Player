///////////////////////////////////////////////////////////////////////////////////
////                           EPK record contract                              ///
///////////////////////////////////////////////////////////////////////////////////
///                                                                             ///
/// Used to pay EPK to unlock accounts, record payment results, and provide a   ///
/// query method for querying whether one account has been unlocked.            ///
///                                                                             ///
///////////////////////////////////////////////////////////////////////////////////
///                                                          Mr.K by 2019/08/01 ///
///////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.5.0 <0.6.0;

interface TicketInterface {

    //One address needs to have enough EPK to unlock accounts. If one account has been unlocked before, the method will not take effect.
    function PaymentTicket() external;

    //Check if the one address has paid EPK to unlock the account.
    function HasTicket( address ownerAddr ) external view returns (bool);
}
