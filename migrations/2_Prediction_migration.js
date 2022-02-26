const Prediction = artifacts.require("Prediction");


module.exports = function (deployer) {

  var oracle = "0x43a994aF0Cc6c485fCE82fd682179f831eE3962a"// 이선우 pc의 hdwallet
  var commission= 1;
  deployer.deploy(Prediction,oracle,commission);
  
  
}
