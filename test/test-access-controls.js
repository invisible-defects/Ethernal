var EthernalAccessControl = artifacts.require('EthernalAccessControl');

contract('EthernalAccessControl', function(accounts) {

    var contract;
    var owner = accounts[0];

    beforeEach(function() {
        return EthernalAccessControl.new({from: owner})
        .then(function(instance) {
           contract = instance;
        });
      });

    it('should set the contract owner to CEO', function(){
        return contract.ceoAddress.call().then(function(address){
            assert.equal(address, accounts[0], 'CEO initially set wrong')
        });
    });

    it('CEO should be able to re-set CEO', function() {
        var ceoAddr;
        return contract.setCEO(accounts[1], {from: accounts[0]}).then(function() {
            return contract.ceoAddress.call().then(function(address){
                assert.equal(address, accounts[1], 'CEO was not re-set correctly')
            });
        });
    });

    it('CEO should be able to re-set Gameserver', function() {
        var ceoAddr;
        return contract.setGameserver(accounts[1], {from: accounts[0]}).then(function() {
            return contract.gameserverAddress.call().then(function(address){
                assert.equal(address, accounts[1], 'Gameserver was not re-set correctly')
            });
        });
    });

    it('CEO should be able to add admins', function() {
        return contract.assignAdmin(accounts[1], {from: accounts[0]}).then(function() {
            return contract.adminAddresses.call(accounts[1]).then(function(status){
                assert.equal(status, true, 'CEO did not set admin correctly')
            });
        });
    });

    it('Non-CEO should not be able to use CEO-only functions', function(){
        return contract.setCEO(accounts[3], {from: accounts[3]}).catch(function(error){
           assert.equal(error.toString(), 'Error: VM Exception while processing transaction: revert');
        });
    });

});