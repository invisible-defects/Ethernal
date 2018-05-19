var ArtifactOwnership = artifacts.require('ArtifactOwnership');

contract('ArtifactOwnership', function(accounts) {

    var contract;
    var owner = accounts[0];

    beforeEach(function() {
        return ArtifactOwnership.new({from: owner})
        .then(function(instance) {
            contract = instance;
        });
    });

    // Dummy artifact attributes
    var typeId = 0;
    var maxAmount = 10000;
    var isSellable = true;

    it('should not allow non-gameserver to create items', function(){
        return contract.createArtifact(
            typeId, maxAmount, isSellable, accounts[2], {from: accounts[1]}
        ).catch(function(error){
            assert.equal(error.toString(), 'Error: VM Exception while processing transaction: revert');
        });
    });

    it('should be able to create and store items', function(){
        return contract.setGameserver(accounts[1], {from: accounts[0]}).then(function(){
            return contract.createArtifact(typeId, maxAmount, isSellable, accounts[2], {from: accounts[1]}).then(function(){
                return contract.getArtifactsAmount.call().then(function(amount){
                        assert.equal(amount, 1, 'Artifact was not created');
                });
            });
        });
    });

    it('should be able to transfer items', function(){
        return contract.setGameserver(accounts[1], {from: accounts[0]}).then(function(){
            return contract.createArtifact(typeId, maxAmount, isSellable, accounts[2], {from: accounts[1]}).then(async(newId) => {
                let owner = await contract.ownerOf.call(0, newId);
                assert.equal(owner, accounts[2], 'Artifact was not transfered correctly');
            });
        });
    });
});
