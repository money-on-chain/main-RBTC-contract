pragma solidity 0.5.8;

interface BtcPriceFeed {
    function poke(uint128 val_, uint32 zzz_) external;
    function post(uint128 val_, uint32 zzz_, address med_) external;
}