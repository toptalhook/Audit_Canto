# Canto audit details
- Total Prize Pool: $24,500 USDC 
  - HM awards: $16,500 USDC 
  - Analysis awards: $1,000 USDC 
  - QA awards: $500 USDC 
  - Bot Race awards: $1,500 USDC 
  - Gas awards: $500 USDC 
  - Judge awards: $2,400 USDC 
  - Lookout awards: $1,600 USDC 
  - Scout awards: $500 USDC 
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2023-11-canto/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts November 13, 2023 20:00 UTC
- Ends November 16, 2023  20:00 UTC 

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2023-11-canto/blob/main/4naly3er-report.md).

Automated findings output for the audit can be found [here](https://github.com/code-423n4/2023-11-canto/blob/main/bot-report.md) within 24 hours of audit opening.

_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

Explicit design decisions:
- A creator cannot buy tokens for shares that they created. Of course, this check can be circumvented easily (buying from a different address or buying an ERC1155 token on the secondary market and unwrapping it). The main motivation behind this check is to make clear that the intention of the system is not that creators buy a lot of their own tokens (which is the case for other SocialFi protocols), it is not a strict security check.
- NFT minting / burning fees are based on the current supply. This leads to the situation that buying 100 tokens and then minting 100 NFTs is more expensive than buying 1, minting 1, buying 1, minting 1, etc... (100 times). We do not consider this a problem because a user typically has no incentives to mint more than one NFT.


# Overview

Application Specific Dollar (asD) is a protocol that allows anyone to create stablecoins (pegged to 1 NOTE), with all yield going to the creator.

1155tech is a SocialFi protocol that will use asD as its currency. In contrast to existing SocialFi protocols, users can pay a fee to mint ERC1155 tokens based on their shares. While they do not earn any trading fees for those ERC1155 tokens, they can be traded on the secondary market and used wherever ERC1155 tokens are supported (for instance as a profile picture).

# Application Specific Dollar
asD is always backed 1:1 to NOTE. The NOTE is added to the Canto Lending Market and the creator of a coin can withdraw the carry (i.e., the accrued interest) at any time.

## `asDFactory`
The `asDFactory` is used to create a new asD tokens. It only exposes a functoin `create` that accepts the name and symbol of the token to create. These do not have to be unique.
We also keep track of the created tokens in the mapping `isAsD`. This mapping allows integrating contracts to query if a given address is a legit asD, for instance if they want to support all asD's instead of only one.

## `asD`

### Minting
The `mint` function is used to mint a given amount of asD. The user has to provide the same amount of NOTE to do so. This NOTE is deposited into the Canto Lending Market (CLM), i.e. it is converted to cNOTE.

### Burning
When a user calls `burn` to burn amount x of an asD token, they get x NOTE back. This NOTE is withdrawn from the CLM first.

### Withdrawing accrued interest
The owner of the asD contract (i.e. the creator) calls `withdrawCarry` to withdraw the accrued interest. `withdrawCarry` needs to ensure that it is not possible for the owner to withdraw too many tokens, i.e. it needs to still be possible to redeem all asD tokens at a 1:1 exchange rate after withdrawing.

## Useful background information
- NOTE: https://docs.canto.io/overview/canto-unit-of-account-usdnote
- Canto Lending Market: https://docs.canto.io/overview/canto-lending-market-clm
- Compound cTOKEN Documentation: https://docs.compound.finance/v2/ctokens 

# 1155tech
1155tech allows to create arbitrary SocialFi shares with an arbitrary bonding curve. At the moment, only a linear bonding curve (i.e. a linear price increase based on the total supply of a share) is supported, but additional ones may be added in the future. Every sale incurs a fee, which is split between the creator of the share, the platform, and the current holders of the shares. Holders of a share can mint an ERC1155 token for a fee that is a percentage of the current price. They can also burn this token later on, which also incurs a fee.

## Creating Shares
`Market.createNewShare` is used to create a new share. Share creation can be completely permissionless or it can be restricted to whitelisted addresses only. No fee is charged for the creation of new shares.

## Buying Tokens
The `buy` function is used to buy tokens for a given share ID. Because this action changes the amount of tokens a user owns, all accrued token holder rewards are automatically claimed when a user buys (or sells).

## Selling Tokens
`sell` is used to sell tokens. Fees are deducted from the price. Note that it would be possible in principle that the fees are higher than the price, which would lead to unsellable shares (this is not possible for the linear bonding curve). However, such a bonding curve would be very weird and reverting in such a scenario is not a problem because the user would not have an incentive to sell.

## Claiming
The functions `claimPlatformFee`, `claimHolderFee`, and `claimCreatorFee` are used by the platform team, holders, and creators to claim the accrued fees.

## Links

- **Previous audits:** None
- **Documentation:** See above, [Canto Docs](https://docs.canto.io/) may also be helpful
- **Website:** None
- **Twitter:** None
- **Discord:** None


# Scope

*List all files in scope in the table below (along with hyperlinks) -- and feel free to add notes here to emphasize areas of focus.*

| Contract | SLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| [1155tech-contracts/src/Market.sol](https://github.com/code-423n4/2023-11-canto/blob/1155tech-contracts/src/Market.sol) | 191 | Main 1155tech contract that is used to buy / sell / create shares | [`@openzeppelin/*`](https://openzeppelin.com/contracts/) |
| [1155tech-contracts/src/bonding_curve/LinearBondingCurve.sol](https://github.com/code-423n4/2023-11-canto/blob/1155tech-contracts/src/bonding_curve/LinearBondingCurve.sol) | 45 | Linear bonding curve | None |
| [asD/src/asDFactory.sol](https://github.com/code-423n4/2023-11-canto/blob/asD/src/asDFactory.sol) | 22 | Factory for creating application-specific dollars | [`@openzeppelin/*`](https://openzeppelin.com/contracts/) |
| [asD/src/asD.sol](https://github.com/code-423n4/2023-11-canto/blob/asD/src/asD.sol) | 58 | Application-specific dollar contract | [`@openzeppelin/*`](https://openzeppelin.com/contracts/) |

# Additional Context

- 1155tech will be used with asD as the underlying token (or potentially some other "normal" ERC20 tokens), NOT with fee-on-transfer, ERC777, or other weird tokens.
- The code will be deployed to Canto
- Trusted roles: The creator of an asD token is the only address that is allowed to claim the interest, but they should not be able to claim more than the accrued interest. The owner of the 1155tech `Market` contract can whitelist / blacklist bonding curves (note that this only affects the creation of new shares by design), claim the platform fee, and change access control for the share creation (open for all or only for some whitelisted addresses). The creator of a share can claim the creator fee. 
- ERCs: 
  - `asD`: Should comply with `ERC20`
  - `Market`: Should comply with `ERC1155`

## Main invariants
- asD: It should always be possible to redeem 1 asD for 1 NOTE.
- 1155tech: It should always be possible to sell all outstanding tokens for the tokens that are in the contract.

## Scoping Details 

```
- If you have a public code repo, please share it here:  
- How many contracts are in scope?:   4
- Total SLoC for these contracts?:  316
- How many external imports are there?: 3  
- How many separate interfaces and struct definitions are there for the contracts within scope?:  1
- Does most of your code generally use composition or inheritance?:   Inheritance
- How many external calls?:   2
- What is the overall line coverage percentage provided by your tests?: 80
- Is this an upgrade of an existing system?: False
- Check all that apply (e.g. timelock, NFT, AMM, ERC20, rollups, etc.): ERC-20 Token, Non ERC-20 Token  
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?:  False 
- Please describe required context:   N/A
- Does it use an oracle?:  No
- Describe any novel or unique curve logic or mathematical models your code uses: Yes, there is a simple bonding curve
- Is this either a fork of or an alternate implementation of another project?:   False
- Does it use a side-chain?: 
- Describe any specific areas you would like addressed:
```

# Tests

```
foundryup && cd asD && forge test && cd ../1155tech-contracts && forge test
```
