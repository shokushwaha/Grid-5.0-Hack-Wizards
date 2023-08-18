// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FungibleToken is ERC20 {
    address public owner;

    struct TokenDetails {
        uint256 tokenId;
        string tokenName;
        string tokenSymbol;
        uint256 amount;
        bool expired;
        bool redeemed;
    }

    mapping(address => TokenDetails[]) public userTokenDetails;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        owner = msg.sender;
    }

    function mint(
        address recipient,
        uint256 amount,
        uint256 tokenId,
        string memory tokenName,
        string memory tokenSymbol
    ) external {
        _mint(recipient, amount);
        userTokenDetails[recipient].push(
            TokenDetails(tokenId, tokenName, tokenSymbol, amount, false, false)
        );
    }

    function expireToken(address user, uint256 index) external {
        require(
            index < userTokenDetails[user].length,
            "Token index out of bounds"
        );
        userTokenDetails[user][index].expired = true;
    }

    function redeemToken(address user, uint256 index) external {
        require(
            index < userTokenDetails[user].length,
            "Token index out of bounds"
        );
        userTokenDetails[user][index].redeemed = true;
    }

    function getUserTokenCount(address user) external view returns (uint256) {
        return userTokenDetails[user].length;
    }

    function getUserTokenDetails(
        address user,
        uint256 index
    )
        external
        view
        returns (uint256, string memory, string memory, uint256, bool, bool)
    {
        require(
            index < userTokenDetails[user].length,
            "Token index out of bounds"
        );
        TokenDetails memory token = userTokenDetails[user][index];
        return (
            token.tokenId,
            token.tokenName,
            token.tokenSymbol,
            token.amount,
            token.expired,
            token.redeemed
        );
    }

    function getActiveTokens(
        address user
    ) external view returns (TokenDetails[] memory) {
        TokenDetails[] memory activeTokens;
        for (uint256 i = 0; i < userTokenDetails[user].length; i++) {
            if (
                !userTokenDetails[user][i].expired &&
                !userTokenDetails[user][i].redeemed
            ) {
                activeTokens[activeTokens.length] = userTokenDetails[user][i];
            }
        }
        return activeTokens;
    }

    function getExpiredTokens(
        address user
    ) external view returns (TokenDetails[] memory) {
        TokenDetails[] memory expiredTokens;
        for (uint256 i = 0; i < userTokenDetails[user].length; i++) {
            if (
                userTokenDetails[user][i].expired &&
                !userTokenDetails[user][i].redeemed
            ) {
                expiredTokens[expiredTokens.length] = userTokenDetails[user][i];
            }
        }
        return expiredTokens;
    }

    function getRedeemedTokens(
        address user
    ) external view returns (TokenDetails[] memory) {
        TokenDetails[] memory redeemedTokens;
        for (uint256 i = 0; i < userTokenDetails[user].length; i++) {
            if (userTokenDetails[user][i].redeemed) {
                redeemedTokens[redeemedTokens.length] = userTokenDetails[user][
                    i
                ];
            }
        }
        return redeemedTokens;
    }
}
