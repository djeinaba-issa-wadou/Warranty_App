// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WarrantyRegistry {

    struct Warranty {
        string productId;
        string productName;
        string customerName;
        uint purchaseDate;
        uint warrantyPeriod;
        bool exists;
    }

    mapping(string => Warranty) public warranties;

    function registerWarranty(
        string memory _productId,
        string memory _productName,
        string memory _customerName,
        uint _purchaseDate,
        uint _warrantyPeriod
    ) public {

        require(!warranties[_productId].exists, "Product already registered");

        warranties[_productId] = Warranty(
            _productId,
            _productName,
            _customerName,
            _purchaseDate,
            _warrantyPeriod,
            true
        );
    }

    function checkWarranty(string memory _productId)
        public
        view
        returns (
            string memory productName,
            string memory customerName,
            uint purchaseDate,
            uint warrantyPeriod,
            bool valid
        )
    {
        require(warranties[_productId].exists, "Warranty not found");

        Warranty memory w = warranties[_productId];

        return (
            w.productName,
            w.customerName,
            w.purchaseDate,
            w.warrantyPeriod,
            true
        );
    }
}