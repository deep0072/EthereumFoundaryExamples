**README - BasicNFT Contract**

TokenUri ==> it tells us about the metadata of uploaded nft onchain, like its attributes, path of nft file.

ImageUri ==> it tells us about the exact location of the nft file iteself.

The `BasicNft` contract is a simple implementation of an ERC-721 compliant non-fungible token (NFT) on the Ethereum blockchain. It allows users to mint new NFTs with unique token URIs and retrieve the metadata associated with each NFT.

**Prerequisites**

Before you can use the `BasicNft` contract, ensure you have the following:

1. An Ethereum wallet - You'll need an Ethereum wallet to interact with the contract and mint NFTs.

2. Ether (ETH) - You'll need some ETH to cover the gas fees required for contract interactions.

3. An understanding of ERC-721 - Familiarity with the ERC-721 standard will help you understand the basic functionality of the contract.

**Contract Details**

1. **Contract Name:** BasicNft

2. **Inheritance:** The contract inherits from the ERC721 contract, which is provided by the OpenZeppelin library.

3. **Token Name and Symbol:** The contract is deployed with the name "mark52" and the symbol "mrk."

4. **Token ID and URI Storage:**

   - The contract maintains a private counter (`s_tokenCounter`) to keep track of the token IDs.
   - The contract uses a mapping (`s_tokenIdtoUri`) to store the unique token URI associated with each token ID.

5. **Constructor:**

   - The constructor is called upon contract deployment and initializes the `s_tokenCounter` to 0.

6. **Minting Function:**

   - `function mintNft(string memory _tokenUri) public`: This function allows users to mint new NFTs.
   - The function takes a parameter `_tokenUri`, which represents the URI (metadata) of the NFT to be minted.
   - The `_safeMint` function is used to create the new NFT with the given `_tokenUri` and assigns it to the caller's address.
   - The `s_tokenCounter` is then incremented to ensure each NFT has a unique token ID.

7. **Token URI Function:**

   - `function tokenURI(uint _tokenId) public view override returns (string memory)`: This function is used to retrieve the metadata URI associated with a specific token ID.
   - Users can call this function with the desired `_tokenId`, and it will return the corresponding token URI stored in the `s_tokenIdtoUri` mapping.
8. **Token URI Function:**

   - `function tokenURI(uint _tokenId) public view override returns (string memory)`: This function is used to retrieve the metadata URI associated with a specific token ID.
   - Users can call this function with the desired `_tokenId`, and it will return the corresponding token URI stored in the `s_tokenIdtoUri` mapping.

**Usage**

1. Deploy the Contract: Deploy the `BasicNft` contract to the Ethereum blockchain.

2. Mint NFTs: After deploying the contract, users can call the `mintNft` function to mint new NFTs. Pass the desired token URI as the parameter to this function.

3. View Token URI: To view the metadata (token URI) associated with an NFT, call the `tokenURI` function with the desired token ID as the parameter.

**Important Notes**

- Ensure you have the required ERC-721-compatible wallet to interact with the contract.
- Pay attention to gas fees while interacting with the contract on the Ethereum network.

**Disclaimer**

The `BasicNft` contract is a simple implementation for educational purposes only. It may not have been audited for security, and it is not recommended to use this code for production environments without thorough testing and security review.

**License**

This code is provided without any warranty or liability under the MIT License. Feel free to use and modify it for your purposes.

Happy SVG:
data:image/svg+xml;base64,PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KIA0KPC9oZWFkPg0KPGJvZHk+DQogICAg
PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRw
Oi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB3aWR0aD0iNTAwIiBoZWlnaHQ9IjUwMCI+DQogICAg
PGNpcmNsZSBjeD0iMjUwIiBjeT0iMjUwIiByPSIyMDAiIGZpbGw9InllbGxvdyIgLz4NCiAgICA8
Y2lyY2xlIGN4PSIxODAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSJibGFjayIgLz4NCiAgICA8Y2ly
Y2xlIGN4PSIzMjAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSJibGFjayIgLz4NCiAgICA8cGF0aCBk
PSJNMjAwIDM1MCBRMjUwIDQwMCAzMDAgMzUwIiBzdHJva2U9ImJsYWNrIiBmaWxsPSJSIiAvPg0K
DQogICAgPC9zdmc+DQo8L2JvZHk+DQo8L2h0bWw+DQo=

Sad Svg:
data:image/svg+xml;base64,PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KIA0KPC9oZWFkPg0KPGJvZHk+DQo8c3Zn
IHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjUwMCIgaGVpZ2h0PSI1
MDAiPg0KICA8Y2lyY2xlIGN4PSIyNTAiIGN5PSIyNTAiIHI9IjIwMCIgZmlsbD0ieWVsbG93IiAv
Pg0KICA8Y2lyY2xlIGN4PSIxODAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSIjMDBmY2ZjIiAvPg0K
ICA8Y2lyY2xlIGN4PSIzMjAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSIjMGUwZTBlIiAvPg0KICA8
cGF0aCBkPSJNMjAwIDM1MCBRMjUwIDMwMCAzMDAgMzUwIiBzdHJva2U9IiMwMDAwMDAiIGZpbGw9
Im5vbmUiIC8+DQogIDxjaXJjbGUgY3g9IjE4MCIgY3k9IjI0MCIgcj0iMTAiIGZpbGw9ImJsdWUi
IC8+DQogIDxjaXJjbGUgY3g9IjMyMCIgY3k9IjI0MCIgcj0iMTAiIGZpbGw9ImJsdWUiIC8+DQoN
Cjwvc3ZnPg0KDQo8L2JvZHk+DQo8L2h0bWw+