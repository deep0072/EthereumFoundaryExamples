# Decentralized Stablecoin Engine

This is a Solidity contract for a decentralized stablecoin engine, adhering to the ERC20 standard. The contract is designed to maintain a 1 token = $1 peg. The stablecoin has properties such as exogenous collateral, dollar pegging, and algorithmic stability. 

## Exogenous Collateral

Exogenous collateral refers to collateral that has primary use cases outside the stablecoin project. This type of collateral has an inherent value outside of the stablecoin system, making it potentially more stable and less susceptible to rapid devaluation. However, the supply of exogenous collateral cannot be controlled by the system, which can limit the speed at which the system can scale.

## Overcollateralization

The contract uses an overcollateralization mechanism to ensure the stability of the system. This means that the value of the collateral deposited by users must be greater than the value of the stablecoins they borrow. This mechanism is designed to protect the system against market volatility and the risk of undercollateralization.

## Health Factor

The health factor is a measure of the safety of a user's position. It's a ratio of the total value of the user's collateral to the total value of their borrowed assets. If the health factor falls below a certain threshold, it indicates that the user's position is under-collateralized, and the contract allows for liquidation of the user's position.

To illustrate this with a simple example, imagine you have a candy shop where customers can borrow candies by leaving some of their toys as collateral. The health factor in this case would be the ratio of the value of the toys to the value of the candies. If a customer borrows too many candies without leaving enough toys as collateral, their health factor would drop, indicating a risk to your candy shop. To protect your shop, you could then take some of the customer's toys to cover the value of the candies.

## Testing

The contract is thoroughly tested using Foundry framework. Invariant testing and fuzz testing are both employed to ensure the robustness of the contract.

### Invariant Testing

Invariant testing involves verifying the conditions that must always hold true in the system. This type of testing is powerful in exposing incorrect logic in protocols. Foundry allows for a set of invariant expressions to be tested against randomized sequences of pre-defined function calls from pre-defined contracts. After each function call is performed, all defined invariants are asserted.

### Fuzz Testing

Fuzz testing, also known as fuzzing, involves providing random data as inputs during testing. It is a form of property-based testing that checks the general behaviors of the contract as opposed to isolated scenarios. Foundry runs any test that takes at least one parameter as a property-based test.

In summary, this contract uses algorithmic stability mechanisms, exogenous collateral, and overcollateralization to maintain a stable value of 1 token = $1. It is thoroughly tested using invariant and fuzz testing methods but still not secure do not try to deploy on mainnet. And thanks to Patrick Colling the og og blockchain tutor. just click on youtube link if you wanted to know the process from the og Himself. ```https://youtu.be/8dRAd-Bzc_E```




