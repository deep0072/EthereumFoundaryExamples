-include .env

build:; forge build

deploy-sepolia:
	forge script script/Fundme.s.sol:FundMeScript --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHER_SCAN_API_KEY) -vvv
	