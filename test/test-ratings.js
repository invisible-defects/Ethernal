var EthernalRating = artifacts.require('EthernalRating');

contract('EthernalRating', function(accounts) {

    var contract;
    var owner = accounts[0];

    beforeEach(function() {
        return EthernalRating.new({from: owner})
        .then(function(instance) {
           contract = instance;
        });
    });

    it('should be able to record a game', function(){
        return contract.setGameserver(accounts[1], {from: accounts[0]}).then(function() {
            return contract.updateRating(accounts[2], accounts[3], 2, {from: accounts[1]}).then(async() =>{
                let ratingA = await contract.getCurrentSeasonScore(accounts[2]);
                let ratingB = await contract.getCurrentSeasonScore(accounts[3]);
                assert(ratingA > ratingB, 'ELO was not calculated correctly');
            });
        });
    });

});