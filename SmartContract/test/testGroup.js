

function testSize(start,end) {
  let arraySize = end - start;
  console.log("Array Size ",arraySize );
  for(let i = start; i < end; i++){
    console.log(i);
  }
}

let groups = [1,2,3,4]

function testNSize(sIndex,nog) {
    let end = sIndex + nog;
    console.log(end);
    let rS = [];
    for(let g=sIndex;g<end;g++){
      rS.push(groups[g]);
    }
    console.log(rS);
}

//testSize(1,3)
//testNSize(2,2)

//aLength = 43;
//nog = 10;
//start = 30;



var Contract = require('web3-eth-contract');
const fs = require('fs');
// set provider for all later instances to use
Contract.setProvider('https://alfajores-forno.celo-testnet.org');
const contractJson = fs.readFileSync('/Users/mitch/Documents/SmartContracts/CryptaDAO/build/contracts/Dao.json');

const abi = JSON.parse(contractJson);

var contract = new Contract(abi.abi, "0xCD400D36944911F26d9eb24e4BaFcd06Ce9Be490");

contract.methods.removeVote(0,0).call({from: "0x48C279b6afbB1074afbA17eB8E461D5232D67aA0"}, function(err,data){
  console.log(data);
  console.log(err);
});
