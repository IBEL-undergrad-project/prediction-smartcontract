const Prediction = artifacts.require("Prediction");


module.exports = function (deployer) {

  var oracle = "0x43a994aF0Cc6c485fCE82fd682179f831eE3962a"// 이선우 pc의 hdwallet
  var commission= 1;
  var endDate=1646821800;//Date and time (your time zone): 2022년 3월 9일 수요일 오후 7:30:00 GMT+09:00
  deployer.deploy(Prediction,oracle,commission,endDate);
  
  
}
