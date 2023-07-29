-include .env
.PHONY: all test deploy
help:
	@echo "Usage:"
	@echo "make deploy [ARGS=...]"

build:; forge build

install:; forge install Cyfrin/foundry-devops --no-commit && forge install transmissions11/solmate --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit --no-git

test:; forge test
anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(ANVIL_PRIVATE_KEY) --broadcast

# if( --network sepolia is used , then use sepolia otherwise use other
ifeq ($(findstring --network sepolia, $(ARGS)), --network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHER_SCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployNft.s.sol:DeployNftScript $(NETWORK_ARGS)
mint:
	@forge script script/Interactions.s.sol:MintBasicNft $(NETWORK_ARGS)