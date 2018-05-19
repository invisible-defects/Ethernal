pragma solidity ^0.4.17;

import "./EthernalAccessControl.sol";

/// @title Package managing artifact actions
contract EthernalArtifacts is EthernalAccessControl{
    /// @dev The main artifact struct
    struct Artifact{
        // Maximum amount of this item in the gameworld
        uint32 maxAmount;
        // Current amount of this item in the gameworld
        uint32 currentAmount;
        // Artifact type ID to use with gameserver's db
        uint16 typeId;
        // Checks if artifact is sellable
        bool isSellable;
    }

    
    // Storages

    /// @dev All ingame artifacts. Artifact's ID is
    /// this array's artifact index
    Artifact[] artifacts;

    /// @dev A mapping from artifact ID to owners' addresses
    mapping (uint256 => address) public artifactIndexToOwner;

    /// @dev A mapping from owner adress to number of tokens it owns
    mapping (address => uint256) public ownershipTokenCount;

    /// @dev A mapping from artifact ID to an approved adress for transer
    /// Zero means there's no approval  
    mapping (uint256 => address) public artifactIndexToApproved;


    // Functions
    
    /// @dev Transers artifact ownership between accounts
    function _transfer(address _from, address _to, uint256 _tokenId) internal whenNotPaused{
        ownershipTokenCount[_to]++;
        // Transfer ownership
        artifactIndexToOwner[_tokenId] = _to;
        // When gameserver creates new artifact instance,
        // but we can't account the address
        if(_from != gameserverAddress){
            ownershipTokenCount[_from]--;
            // Clear any previous approved ownership exchange
            delete artifactIndexToApproved[_tokenId];
        }
        // Emit transfer event
        emit Transfer(_from, _to, _tokenId);
    }

    /// @dev A gameserver-only method that creates a new artifact,
    /// stores it and gives to declared player.
    /// @param _typeId Created artifact typeId
    /// @param _maxAmount Created artifact maxAmount
    /// @param _isSellable Created artifact ability to be sold
    /// @param _owner Artifact owner
    function createArtifact (
        uint16 _typeId, uint32 _maxAmount, bool _isSellable, address _owner
    ) 
        public onlyGameserver returns (uint)
    {
        // Creating new artifact object
        Artifact memory _artifact = Artifact({
            maxAmount: uint32(_maxAmount),
            currentAmount: 0,
            typeId: uint16(_typeId),
            isSellable: _isSellable
        });

        // Pushing it to the storage
        uint256 _newArtifactId = artifacts.push(_artifact) - 1;
        // Checkig overflow (just in case we go viral c;)
        require(_newArtifactId <= 4294967295);

        // Transfering to the owner
        _transfer(gameserverAddress, _owner, _newArtifactId);

        return _newArtifactId;
    }

    /// @dev Returns amount of generated ingame items.
    /// Used for testing & statistics purposes
    function getArtifactsAmount() public view returns (uint){
        return artifacts.length;
    }


    // Events

    /// @dev Transfer event as defined in current ERC721 template
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}