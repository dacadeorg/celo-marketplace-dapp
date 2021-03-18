import { newKitFromWeb3 } from '@celo/contractkit'
import jsonInterface from './sale.abi.json'
import Web3 from 'web3'

const saleAddr = "0x8935ad6d507fd1a21C05C3a453F6d07719c0bad7"

let contract
let accounts
let balance = 0
let products = []

const onAccountsChanged = function() {}

const connectMetaMask = async function () {
  const web3 = new Web3(window.celo)
  window.celo.enable()
  const kit = newKitFromWeb3(web3)
  accounts = await kit.web3.eth.getAccounts()
  kit.defaultAccount = accounts[0]

  //debug
  window.web3 = web3;
  window.kit = kit

	const c = await kit
		.getTotalBalance(
			accounts[0]
		)
	console.log(c)
	balance = (c.cUSD.toNumber()/1000000000000000000).toFixed(2)
  $('#balance').html(balance)

	contract = new kit.web3.eth.Contract(jsonInterface, saleAddr)
	window.contract = contract
  await getProducts()
  renderProducts()
}
const getProducts = async function() {
	const l = await contract.methods.getItemsLength().call()
  console.log(l)
  const ps = []
	for(let i=0;i < l;i++){
    let p = new Promise(async (resolve, reject) => {
      let l = await contract.methods.getItem(i).call()
      resolve({
        index: i,
        productName: l[0],
        imgUrl: l[1],
        productDescription: l[2],
        location: l[3],
        creatorAddress: l[4],
        price: l[5],
        productsSold: l[6],
      })
    })
    ps.push(p)
	}
  products = await Promise.all(ps)
  console.log(products)
}

var template = $('#template').html();
Mustache.parse(template);

function renderProducts() {
  const rendered = products.map(p => productTemplate(
    p.index,
    p.productName,
    p.imgUrl,
    p.productDescription,
    p.location,
    p.creatorAddress,
    p.price,
    p.productsSold
  ))
  $('#productBody').html(rendered);
}
function productTemplate(index, productName, imgUrl, productDescription,location,creatorAddress,price,productsSold) {
  return `
  <div class="card mb-4">
    <h5 class="card-header text-center">${productName}</h5>
    <img src="${imgUrl}" class="card-img-top" alt="...">
    <div class="card-body text-left">
      <p class="card-text">
        <strong>Description:</strong>
        ${productDescription}
      </p>
      <p class="card-text">
        <strong>Location:</strong>
        <span>${location}</span>
      </p>
      <p class="card-text">
        <strong>Creator Address:</strong>
        <span>${creatorAddress}</span>
      </p>
      <div class="d-grid gap-2">
        <a class="btn btn-success buyBtn" id=${index}>Buy for ${price} cUSD$</a>
      </div>
    </div>
    <div class="card-footer text-muted text-center">
        ${productsSold} sold
    </div>
  </div>
  `
}

window.addEventListener('load', async () => {
  $("#loader").show();
  connectMetaMask();
  $("#loader").hide();
});


$('#newProductBtn').click(async function(){
  const newProductName = ($('#newProductName').val()),
  newImgUrl = ($('#newImgUrl').val()),
  newProductDescription = ($('#newProductDescription').val()),
  newLocation = ($('#newLocation').val()),
  newPrice = ($('#newPrice').val());

  const params = [
    newProductName,
    newImgUrl,
    newProductDescription,
    newLocation,
    newPrice
  ]
	const result = await contract.methods.submitItem(...params).send({ from: accounts[0] })
  getProducts
  renderProducts();
})
