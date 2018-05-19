pragma solidity ^0.4.17;

import "./EthernalArtifacts.sol";
import "./ERC721Template.sol";

/// @title Contract providing artifact ownership based on ERC721
contract ArtifactOwnership is EthernalArtifacts, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public name = "EthernalArtifact";
    string public symbol = "EA";

    function implementsERC721() public pure returns (bool)
    {
        return true;
    }

    /// @dev Functions, required by ERC721

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return artifactIndexToOwner[_tokenId] == _claimant;
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return artifactIndexToApproved[_tokenId] == _claimant;
    }

    function _approve(uint256 _tokenId, address _approved) internal {
        artifactIndexToApproved[_tokenId] = _approved;
    }

    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    function transfer(address _to, uint256 _tokenId) public whenNotPaused {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Theese 2 methods are implemented mostly
    /// for ERC721 compatibility, but they're
    /// not to be often used as we do not transfer
    /// to another contract in most of the cases.

    function approve(address _to, uint256 _tokenId) public whenNotPaused{
        require(_owns(msg.sender, _tokenId));
        _approve(_tokenId, _to);
        emit Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(address _from, address _to, uint256 _tokenId) public whenNotPaused{
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        _transfer(_from, _to, _tokenId);
    }

    function totalSupply() public view returns (uint) {
        return artifacts.length - 1;
    }

    function ownerOf(uint256 _tokenId) public view returns (address owner){
        owner = artifactIndexToOwner[_tokenId];
        require(owner != address(0));
    }
}