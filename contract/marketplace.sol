// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;
/**
 * @title This interface describes the ERC20 functions shared by all Celo Tokens.
 */
interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  // solhint-disable-next-line no-simple-event-func-name
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MarketPlace {

    uint itemsLength = 0;
    address cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct item {
        string productName;
        string imgUrl;
        string productDescription;
        string location;
        address payable creatorAddress;
        uint price;
        uint productsSold;
    }

    mapping (uint => item) items;

    function submitItem(
        string memory _productName, 
        string memory _imgUrl,
        string memory _productDescription, 
        string memory _location,
        uint _price
    ) public {
        uint _productsSold = 0;
        items[itemsLength] = item(
            _productName, 
            _imgUrl, 
            _productDescription,
            _location,
            msg.sender,
            _price,
            _productsSold
        );
        itemsLength++;
    }

    function buyItem(uint _index) payable public {
        item storage m = items[_index];
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            m.creatorAddress,
            m.price
          ),
          "Transfer of contribution failed"
        );
        m.productsSold++;
    }

    function getItem(uint _index) view public returns (
        string memory, 
        string memory,
        string memory,
        string memory,
        address payable,
        uint,
        uint
    ) {
        return (
            items[_index].productName, 
            items[_index].imgUrl, 
            items[_index].productDescription,
            items[_index].location, 
            items[_index].creatorAddress,
            items[_index].price, 
            items[_index].productsSold
        );
    }

    function getItemsLength () view public returns (uint) {
        return (itemsLength);
    }
}