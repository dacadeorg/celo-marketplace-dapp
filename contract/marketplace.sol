// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Marketplace {
    address internal contractOwner;
    uint internal productsLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct Product {
        address payable owner;
        string name;
        string image;
        string description;
        string location;
        uint price;
        uint sold;
    }

    mapping (uint => Product) internal products;

     	//CONSTRUCTOR
	constructor () payable  {
		contractOwner = msg.sender;
	}

    function writeProduct(
        string memory _name,
        string memory _image,
        string memory _description, 
        string memory _location, 
        uint _price
    ) public {
        uint _sold = 0;
        products[productsLength] = Product(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold
        );
        productsLength++;
    }

    function readProduct(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint, 
        uint
    ) {
        return (
            products[_index].owner,
            products[_index].name, 
            products[_index].image, 
            products[_index].description, 
            products[_index].location, 
            products[_index].price,
            products[_index].sold
        );
    }
    
    function buyProduct(uint _index) public payable  {
        //Adjusting price for commission
         uint adjustedPrice = (products[_index].price * 90)/100;
         uint commissionPrice =(products[_index].price * 10)/100;

        //Restricting product owner(seller) from buying his/her product
        require(msg.sender != products[_index].owner,"You cannot buy your own product");

        //Sending 10% of the product price to the contract owner
        require(IERC20Token(cUsdTokenAddress).transferFrom(
             msg.sender,
             contractOwner,
             commissionPrice
        ), "Transfer to contract owner failed");

        //Sending the remaining 90% to the product owner(seller)
        require(IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            products[_index].owner,
            adjustedPrice
          ),
          "Transfer to artwork owner failed."
        );
        products[_index].sold++;
    }
    
    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }
}