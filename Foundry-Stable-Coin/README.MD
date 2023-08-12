# Decentralised Stable Coin
1. Relative Stability: Anchored/Pegged -> $1
    1. chainlink pricefeed
    2. set function to exhange eth and btc --> $1
2. Stability Mechanism (Minting): Alogirithmic (Decentralised)
    1.People only can mint and burn token with enough collateral(coded)
3. Collateral (Exogenous)
    1.wETH
    2.wBTC

# Function mentioned in DSC engine contract

1. function depositCollateralAndMintDsc() ==> deposit your collateral and mint th stable coin
<br>

2.  functiotn redeemCollateralForDSC() ==> get back yout deposited collateral by giving back DSC coin to contract
<br>

3. function burnDsc() ==> burn the dsc coin when you have dsc coin value more than the collateral itself
<br>

4. function liquidate() ==> lets understand this with example. lets say i deposit $100 eth and get stable coin $50. there is threshold of collateral %150 ($75) value of stable coin i have. if collateral value below the $75 then the collateral i have will be bought by someone by paying $50 so this is the liquidation. so we need to maintain the collateral value more than the threshold.
<br>
<br>

5 function _checkHealthFactor() ==> this function first calculates the some portion of collateral in usd portion or percentage is set by the liquidation threshhold and then we calculate the health factor




