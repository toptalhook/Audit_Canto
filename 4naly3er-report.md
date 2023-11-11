# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Using bools for storage incurs overhead | 4 |
| [GAS-2](#GAS-2) | Use calldata instead of memory for function arguments that do not get mutated | 4 |
| [GAS-3](#GAS-3) | For Operations that will not overflow, you could use unchecked | 142 |
| [GAS-4](#GAS-4) | Use Custom Errors | 11 |
| [GAS-5](#GAS-5) | Functions guaranteed to revert when called by normal users can be marked `payable` | 5 |
| [GAS-6](#GAS-6) | `++i` costs less gas than `i++`, especially when it's used in `for`-loops (`--i`/`i--` too) | 1 |
| [GAS-7](#GAS-7) | Using `private` rather than `public` for constants, saves gas | 3 |
| [GAS-8](#GAS-8) | Use != 0 instead of > 0 for unsigned integer comparison | 6 |
### <a name="GAS-1"></a>[GAS-1] Using bools for storage incurs overhead
Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (4)*:
```solidity
File: 1155tech-contracts/src/Market.sol

49:     mapping(address => bool) public whitelistedBondingCurves;

61:     bool public shareCreationRestricted = true;

64:     mapping(address => bool) public whitelistedShareCreators;

```

```solidity
File: src/asDFactory.sol

15:     mapping(address => bool) public isAsD;

```

### <a name="GAS-2"></a>[GAS-2] Use calldata instead of memory for function arguments that do not get mutated
Mark data types as `calldata` instead of `memory` where possible. This makes it so that the data is not automatically loaded into memory. If the data passed into the function does not need to be changed (like updating values in an array), it can be passed in as `calldata`. The one exception to this is if the argument must later be passed into another function that takes an argument that specifies `memory` storage.

*Instances (4)*:
```solidity
File: src/asD.sol

29:         string memory _name,

30:         string memory _symbol,

```

```solidity
File: src/asDFactory.sol

33:     function create(string memory _name, string memory _symbol) external returns (address) {

33:     function create(string memory _name, string memory _symbol) external returns (address) {

```

### <a name="GAS-3"></a>[GAS-3] For Operations that will not overflow, you could use unchecked

*Instances (142)*:
```solidity
File: 1155tech-contracts/src/Market.sol

4: import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

4: import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

4: import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

4: import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

5: import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

5: import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

5: import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

5: import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

5: import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

6: import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

6: import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

6: import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

7: import {IBondingCurve} from "../interface/IBondingCurve.sol";

7: import {IBondingCurve} from "../interface/IBondingCurve.sol";

8: import {Turnstile} from "../interface/Turnstile.sol";

8: import {Turnstile} from "../interface/Turnstile.sol";

14:     uint256 public constant NFT_FEE_BPS = 1_000; // 10%

14:     uint256 public constant NFT_FEE_BPS = 1_000; // 10%

15:     uint256 public constant HOLDER_CUT_BPS = 3_300; // 33%

15:     uint256 public constant HOLDER_CUT_BPS = 3_300; // 33%

16:     uint256 public constant CREATOR_CUT_BPS = 3_300; // 33%

16:     uint256 public constant CREATOR_CUT_BPS = 3_300; // 33%

33:         uint256 tokenCount; // Number of outstanding tokens

33:         uint256 tokenCount; // Number of outstanding tokens

34:         uint256 tokensInCirculation; // Number of outstanding tokens - tokens that are minted as NFT, i.e. the number of tokens that receive fees

34:         uint256 tokensInCirculation; // Number of outstanding tokens - tokens that are minted as NFT, i.e. the number of tokens that receive fees

34:         uint256 tokensInCirculation; // Number of outstanding tokens - tokens that are minted as NFT, i.e. the number of tokens that receive fees

35:         uint256 shareHolderRewardsPerTokenScaled; // Accrued funds for the share holder per token, multiplied by 1e18 to avoid precision loss

35:         uint256 shareHolderRewardsPerTokenScaled; // Accrued funds for the share holder per token, multiplied by 1e18 to avoid precision loss

36:         uint256 shareCreatorPool; // Unclaimed funds for the share creators

36:         uint256 shareCreatorPool; // Unclaimed funds for the share creators

37:         address bondingCurve; // Bonding curve used for this share

37:         address bondingCurve; // Bonding curve used for this share

38:         address creator; // Creator of the share

38:         address creator; // Creator of the share

39:         string metadataURI; // URI of the metadata

39:         string metadataURI; // URI of the metadata

121:         id = ++shareCount;

121:         id = ++shareCount;

135:         (price, fee) = IBondingCurve(bondingCurve).getPriceAndFee(shareData[_id].tokenCount + 1, _amount);

144:         (price, fee) = IBondingCurve(bondingCurve).getPriceAndFee(shareData[_id].tokenCount - _amount + 1, _amount);

144:         (price, fee) = IBondingCurve(bondingCurve).getPriceAndFee(shareData[_id].tokenCount - _amount + 1, _amount);

152:         (uint256 price, uint256 fee) = getBuyPrice(_id, _amount); // Reverts for non-existing ID

152:         (uint256 price, uint256 fee) = getBuyPrice(_id, _amount); // Reverts for non-existing ID

152:         (uint256 price, uint256 fee) = getBuyPrice(_id, _amount); // Reverts for non-existing ID

153:         SafeERC20.safeTransferFrom(token, msg.sender, address(this), price + fee);

161:         shareData[_id].tokenCount += _amount;

162:         shareData[_id].tokensInCirculation += _amount;

163:         tokensByAddress[_id][msg.sender] += _amount;

182:         shareData[_id].tokenCount -= _amount;

183:         shareData[_id].tokensInCirculation -= _amount;

184:         tokensByAddress[_id][msg.sender] -= _amount; // Would underflow if user did not have enough tokens

184:         tokensByAddress[_id][msg.sender] -= _amount; // Would underflow if user did not have enough tokens

184:         tokensByAddress[_id][msg.sender] -= _amount; // Would underflow if user did not have enough tokens

187:         SafeERC20.safeTransfer(token, msg.sender, rewardsSinceLastClaim + price - fee);

187:         SafeERC20.safeTransfer(token, msg.sender, rewardsSinceLastClaim + price - fee);

197:         fee = (priceForOne * _amount * NFT_FEE_BPS) / 10_000;

197:         fee = (priceForOne * _amount * NFT_FEE_BPS) / 10_000;

197:         fee = (priceForOne * _amount * NFT_FEE_BPS) / 10_000;

211:         tokensByAddress[_id][msg.sender] -= _amount;

212:         shareData[_id].tokensInCirculation -= _amount;

234:         tokensByAddress[_id][msg.sender] += _amount;

235:         shareData[_id].tokensInCirculation += _amount;

275:             ((shareData[_id].shareHolderRewardsPerTokenScaled - lastClaimedValue) * tokensByAddress[_id][msg.sender]) /

275:             ((shareData[_id].shareHolderRewardsPerTokenScaled - lastClaimedValue) * tokensByAddress[_id][msg.sender]) /

275:             ((shareData[_id].shareHolderRewardsPerTokenScaled - lastClaimedValue) * tokensByAddress[_id][msg.sender]) /

285:         uint256 shareHolderFee = (_fee * HOLDER_CUT_BPS) / 10_000;

285:         uint256 shareHolderFee = (_fee * HOLDER_CUT_BPS) / 10_000;

286:         uint256 shareCreatorFee = (_fee * CREATOR_CUT_BPS) / 10_000;

286:         uint256 shareCreatorFee = (_fee * CREATOR_CUT_BPS) / 10_000;

287:         uint256 platformFee = _fee - shareHolderFee - shareCreatorFee;

287:         uint256 platformFee = _fee - shareHolderFee - shareCreatorFee;

288:         shareData[_id].shareCreatorPool += shareCreatorFee;

290:             shareData[_id].shareHolderRewardsPerTokenScaled += (shareHolderFee * 1e18) / _tokenCount;

290:             shareData[_id].shareHolderRewardsPerTokenScaled += (shareHolderFee * 1e18) / _tokenCount;

290:             shareData[_id].shareHolderRewardsPerTokenScaled += (shareHolderFee * 1e18) / _tokenCount;

293:             platformFee += shareHolderFee;

295:         platformPool += platformFee;

```

```solidity
File: 1155tech-contracts/src/bonding_curve/LinearBondingCurve.sol

4: import {IBondingCurve} from "../../interface/IBondingCurve.sol";

4: import {IBondingCurve} from "../../interface/IBondingCurve.sol";

4: import {IBondingCurve} from "../../interface/IBondingCurve.sol";

20:         for (uint256 i = shareCount; i < shareCount + amount; i++) {

20:         for (uint256 i = shareCount; i < shareCount + amount; i++) {

20:         for (uint256 i = shareCount; i < shareCount + amount; i++) {

21:             uint256 tokenPrice = priceIncrease * i;

22:             price += tokenPrice;

23:             fee += (getFee(i) * tokenPrice) / 1e18;

23:             fee += (getFee(i) * tokenPrice) / 1e18;

23:             fee += (getFee(i) * tokenPrice) / 1e18;

35:         return 1e17 / divisor;

```

```solidity
File: src/asD.sol

4: import {Turnstile} from "../interface/Turnstile.sol";

4: import {Turnstile} from "../interface/Turnstile.sol";

5: import {IasDFactory} from "../interface/IasDFactory.sol";

5: import {IasDFactory} from "../interface/IasDFactory.sol";

6: import {CTokenInterface, CErc20Interface} from "../interface/clm/CTokenInterfaces.sol";

6: import {CTokenInterface, CErc20Interface} from "../interface/clm/CTokenInterfaces.sol";

6: import {CTokenInterface, CErc20Interface} from "../interface/clm/CTokenInterfaces.sol";

7: import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

7: import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

7: import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

8: import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

8: import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

8: import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

8: import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

9: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

9: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

9: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

9: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

9: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

15:     address public immutable cNote; // Reference to the cNOTE token

15:     address public immutable cNote; // Reference to the cNOTE token

63:         uint256 returnCode = cNoteToken.redeemUnderlying(_amount); // Request _amount of NOTE (the underlying of cNOTE)

63:         uint256 returnCode = cNoteToken.redeemUnderlying(_amount); // Request _amount of NOTE (the underlying of cNOTE)

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

73:         uint256 exchangeRate = CTokenInterface(cNote).exchangeRateCurrent(); // Scaled by 1 * 10^(18 - 8 + Underlying Token Decimals), i.e. 10^(28) in our case

73:         uint256 exchangeRate = CTokenInterface(cNote).exchangeRateCurrent(); // Scaled by 1 * 10^(18 - 8 + Underlying Token Decimals), i.e. 10^(28) in our case

73:         uint256 exchangeRate = CTokenInterface(cNote).exchangeRateCurrent(); // Scaled by 1 * 10^(18 - 8 + Underlying Token Decimals), i.e. 10^(28) in our case

73:         uint256 exchangeRate = CTokenInterface(cNote).exchangeRateCurrent(); // Scaled by 1 * 10^(18 - 8 + Underlying Token Decimals), i.e. 10^(28) in our case

73:         uint256 exchangeRate = CTokenInterface(cNote).exchangeRateCurrent(); // Scaled by 1 * 10^(18 - 8 + Underlying Token Decimals), i.e. 10^(28) in our case

75:         uint256 maximumWithdrawable = (CTokenInterface(cNote).balanceOf(address(this)) * exchangeRate) /

75:         uint256 maximumWithdrawable = (CTokenInterface(cNote).balanceOf(address(this)) * exchangeRate) /

76:             1e28 -

86:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem

86:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem

86:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem

86:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem

86:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem

86:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem

86:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem

```

```solidity
File: src/asDFactory.sol

4: import {Turnstile} from "../interface/Turnstile.sol";

4: import {Turnstile} from "../interface/Turnstile.sol";

5: import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

5: import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

5: import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

6: import {asD} from "./asD.sol";

```

### <a name="GAS-4"></a>[GAS-4] Use Custom Errors
[Source](https://blog.soliditylang.org/2021/04/21/custom-errors/)
Instead of using error strings, to reduce deployment and runtime cost, you should use Custom Errors. This would save both deployment and runtime cost.

*Instances (11)*:
```solidity
File: 1155tech-contracts/src/Market.sol

105:         require(whitelistedBondingCurves[_bondingCurve] != _newState, "State already set");

119:         require(whitelistedBondingCurves[_bondingCurve], "Bonding curve not whitelisted");

120:         require(shareIDs[_shareName] == 0, "Share already exists");

151:         require(shareData[_id].creator != msg.sender, "Creator cannot buy");

254:         require(shareData[_id].creator == msg.sender, "Not creator");

301:         require(shareCreationRestricted != _isRestricted, "State already set");

310:         require(whitelistedShareCreators[_address] != _isWhitelisted, "State already set");

```

```solidity
File: src/asD.sol

54:         require(returnCode == 0, "Error when minting");

64:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying

81:             require(_amount <= maximumWithdrawable, "Too many tokens requested");

86:         require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem

```

### <a name="GAS-5"></a>[GAS-5] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (5)*:
```solidity
File: 1155tech-contracts/src/Market.sol

104:     function changeBondingCurveAllowed(address _bondingCurve, bool _newState) external onlyOwner {

244:     function claimPlatformFee() external onlyOwner {

300:     function restrictShareCreation(bool _isRestricted) external onlyOwner {

309:     function changeShareCreatorWhitelist(address _address, bool _isWhitelisted) external onlyOwner {

```

```solidity
File: src/asD.sol

72:     function withdrawCarry(uint256 _amount) external onlyOwner {

```

### <a name="GAS-6"></a>[GAS-6] `++i` costs less gas than `i++`, especially when it's used in `for`-loops (`--i`/`i--` too)
*Saves 5 gas per loop*

*Instances (1)*:
```solidity
File: 1155tech-contracts/src/bonding_curve/LinearBondingCurve.sol

20:         for (uint256 i = shareCount; i < shareCount + amount; i++) {

```

### <a name="GAS-7"></a>[GAS-7] Using `private` rather than `public` for constants, saves gas
If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (3)*:
```solidity
File: 1155tech-contracts/src/Market.sol

14:     uint256 public constant NFT_FEE_BPS = 1_000; // 10%

15:     uint256 public constant HOLDER_CUT_BPS = 3_300; // 33%

16:     uint256 public constant CREATOR_CUT_BPS = 3_300; // 33%

```

### <a name="GAS-8"></a>[GAS-8] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (6)*:
```solidity
File: 1155tech-contracts/src/Market.sol

165:         if (rewardsSinceLastClaim > 0) {

216:         if (rewardsSinceLastClaim > 0) {

266:         if (amount > 0) {

289:         if (_tokenCount > 0) {

```

```solidity
File: src/asD.sol

2: pragma solidity >=0.8.0;

```

```solidity
File: src/asDFactory.sol

2: pragma solidity >=0.8.0;

```


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Event is missing `indexed` fields | 2 |
| [NC-2](#NC-2) | Constants should be defined rather than using magic numbers | 1 |
### <a name="NC-1"></a>[NC-1] Event is missing `indexed` fields
Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

*Instances (2)*:
```solidity
File: src/asD.sol

20:     event CarryWithdrawal(uint256 amount);

```

```solidity
File: src/asDFactory.sol

20:     event CreatedToken(address token, string symbol, string name, address creator);

```

### <a name="NC-2"></a>[NC-2] Constants should be defined rather than using magic numbers

*Instances (1)*:
```solidity
File: src/asD.sol

73:         uint256 exchangeRate = CTokenInterface(cNote).exchangeRateCurrent(); // Scaled by 1 * 10^(18 - 8 + Underlying Token Decimals), i.e. 10^(28) in our case

```


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | Use of `tx.origin` is unsafe in almost every context | 2 |
| [L-2](#L-2) | Do not use deprecated library functions | 1 |
| [L-3](#L-3) | Unspecific compiler version pragma | 2 |
### <a name="L-1"></a>[L-1] Use of `tx.origin` is unsafe in almost every context
According to [Vitalik Buterin](https://ethereum.stackexchange.com/questions/196/how-do-i-make-my-dapp-serenity-proof), contracts should _not_ `assume that tx.origin will continue to be usable or meaningful`. An example of this is [EIP-3074](https://eips.ethereum.org/EIPS/eip-3074#allowing-txorigin-as-signer-1) which explicitly mentions the intention to change its semantics when it's used with new op codes. There have also been calls to [remove](https://github.com/ethereum/solidity/issues/683) `tx.origin`, and there are [security issues](solidity.readthedocs.io/en/v0.4.24/security-considerations.html#tx-origin) associated with using it for authorization. For these reasons, it's best to completely avoid the feature.

*Instances (2)*:
```solidity
File: 1155tech-contracts/src/Market.sol

96:             turnstile.register(tx.origin);

```

```solidity
File: src/asDFactory.sol

29:             turnstile.register(tx.origin);

```

### <a name="L-2"></a>[L-2] Do not use deprecated library functions

*Instances (1)*:
```solidity
File: src/asD.sol

51:         SafeERC20.safeApprove(note, cNote, _amount);

```

### <a name="L-3"></a>[L-3] Unspecific compiler version pragma

*Instances (2)*:
```solidity
File: src/asD.sol

2: pragma solidity >=0.8.0;

```

```solidity
File: src/asDFactory.sol

2: pragma solidity >=0.8.0;

```


## Medium Issues


| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Centralization Risk for trusted owners | 10 |
### <a name="M-1"></a>[M-1] Centralization Risk for trusted owners

#### Impact:
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (10)*:
```solidity
File: 1155tech-contracts/src/Market.sol

6: import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

10: contract Market is ERC1155, Ownable2Step {

91:     constructor(string memory _uri, address _paymentToken) ERC1155(_uri) Ownable() {

104:     function changeBondingCurveAllowed(address _bondingCurve, bool _newState) external onlyOwner {

244:     function claimPlatformFee() external onlyOwner {

300:     function restrictShareCreation(bool _isRestricted) external onlyOwner {

309:     function changeShareCreatorWhitelist(address _address, bool _isWhitelisted) external onlyOwner {

```

```solidity
File: src/asD.sol

11: contract asD is ERC20, Ownable2Step {

72:     function withdrawCarry(uint256 _amount) external onlyOwner {

```

```solidity
File: src/asDFactory.sol

8: contract asDFactory is Ownable2Step {

```

