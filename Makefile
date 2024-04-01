-include .env
.PHONY

build:; @forge build

deploy-sepolia:; forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

deploy:; @forge script script/DeployFundMe.s.sol:DeployFundMe

deploy-sepoliaa:; @forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) && echo "Etherscan API Key used: $(ETHERSCAN_API_KEY)"
