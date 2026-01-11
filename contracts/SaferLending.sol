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
/*//////////////////////////////////////////////////////////////
                        HEALTH FACTOR
//////////////////////////////////////////////////////////////*/

function getHealthFactor(address user) public view returns (uint256) {
    Position memory p = positions[user];

    // No debt → infinitely healthy
    if (p.debt == 0) {
        return type(uint256).max;
    }

    (uint256 price, uint256 updatedAt) = priceOracle.getPrice();

    require(
        block.timestamp - updatedAt <= ORACLE_STALE_TIME,
        "ORACLE_STALE"
    );
    require(price > 0, "INVALID_PRICE");

    uint256 collateralValue = (p.collateral * price) / 1e18;

    uint256 adjustedCollateral =
        (collateralValue * LIQUIDATION_THRESHOLD) / 100;

    return (adjustedCollateral * 1e18) / p.debt;
}

/*//////////////////////////////////////////////////////////////
                            BORROW
//////////////////////////////////////////////////////////////*/

function borrow(uint256 amount) external {
    require(amount > 0, "amount = 0");

    Position storage p = positions[msg.sender];
    require(p.collateral > 0, "no collateral");

    // Simulate new debt
    uint256 newDebt = p.debt + amount;

    // Fetch oracle price
    (uint256 price, uint256 updatedAt) = priceOracle.getPrice();
    require(
        block.timestamp - updatedAt <= ORACLE_STALE_TIME,
        "ORACLE_STALE"
    );
    require(price > 0, "INVALID_PRICE");

    // Compute collateral value
    uint256 collateralValue = (p.collateral * price) / 1e18;

    // Apply liquidation threshold
    uint256 adjustedCollateral =
        (collateralValue * LIQUIDATION_THRESHOLD) / 100;

    // Health factor after borrow
    uint256 healthFactorAfter =
        (adjustedCollateral * 1e18) / newDebt;

    require(healthFactorAfter >= 1e18, "INSUFFICIENT_COLLATERAL");

    // Update state
    p.debt = newDebt;

    // Transfer borrowed tokens
    bool success = debtToken.transfer(msg.sender, amount);
    require(success, "borrow transfer failed");
}


}
