contract SaferLending {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant LTV = 60;
    uint256 public constant LIQUIDATION_THRESHOLD = 70;
    uint256 public constant LIQUIDATION_DELAY = 10 minutes;
    uint256 public constant ORACLE_STALE_TIME = 5 minutes;

    /*//////////////////////////////////////////////////////////////
                                STATE
    //////////////////////////////////////////////////////////////*/

    MockERC20 public collateralToken;
    MockERC20 public debtToken;
    PriceOracle public priceOracle;

    struct Position {
        uint256 collateral;
        uint256 debt;
        uint256 lastUnhealthyTime;
    }

    mapping(address => Position) public positions;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _collateralToken,
        address _debtToken,
        address _priceOracle
    ) {
        collateralToken = MockERC20(_collateralToken);
        debtToken = MockERC20(_debtToken);
        priceOracle = PriceOracle(_priceOracle);
    }
    /*//////////////////////////////////////////////////////////////
                                DEPOSIT
    //////////////////////////////////////////////////////////////*/
    function deposit(uint256 amount) external {
        require(amount > 0, "amount = 0");

        // Pull collateral into protocol custody
        bool success = collateralToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        require(success, "transfer failed");

        // Update position
        positions[msg.sender].collateral += amount;
    }



}
