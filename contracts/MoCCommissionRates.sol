pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;

contract MoCCommissionRates {
    struct CommissionRates {
        uint8 txType;
        uint256 fee;
    }

    uint8 public constant MINT_BPRO_FEES_RBTC = 1;
    uint8 public constant REDEEM_BPRO_FEES_RBTC = 2;
    uint8 public constant MINT_DOC_FEES_RBTC = 3;
    uint8 public constant REDEEM_DOC_FEES_RBTC = 4;
    uint8 public constant MINT_BTCX_FEES_RBTC = 5;
    uint8 public constant REDEEM_BTCX_FEES_RBTC = 6;
    uint8 public constant MINT_BPRO_FEES_MOC = 7;
    uint8 public constant REDEEM_BPRO_FEES_MOC = 8;
    uint8 public constant MINT_DOC_FEES_MOC = 9;
    uint8 public constant REDEEM_DOC_FEES_MOC = 10;
    uint8 public constant MINT_BTCX_FEES_MOC = 11;
    uint8 public constant REDEEM_BTCX_FEES_MOC = 12;
}

contract MoCCommissionRatesByTxType is MoCCommissionRates {

    mapping(uint8 => uint256) public commissionRatesByTxType;

    constructor(
        CommissionRates[] memory _commissionRates
    ) public {
        //initializeValues(commissionRates);
        initializeCommissionRates(_commissionRates);
    }

    function setCommissionRateByTxType(uint8 txType, uint256 value) public {
        commissionRatesByTxType[txType] = value;
    }

    function getCommissionRateByTxType(uint8 txType) public view returns (uint256) {
        return commissionRatesByTxType[txType];
    }

    // function initialize(CommissionRates[] _commissionRates) public initializer {
    //     initializeValues();
    //     initializeCommissionRates();
    // }

    // function initializeValues(CommissionRates[] memory _commissionRates) internal {
    //     commissionRates = _commissionRates;
    // }

    function initializeCommissionRates(CommissionRates[] memory _commissionRates) internal {
        require(_commissionRates.length > 0);

        for (uint8 i = 0; i < _commissionRates.length; i++) {
            setCommissionRateByTxType(_commissionRates[i].txType, _commissionRates[i].fee);
        }
    }
}