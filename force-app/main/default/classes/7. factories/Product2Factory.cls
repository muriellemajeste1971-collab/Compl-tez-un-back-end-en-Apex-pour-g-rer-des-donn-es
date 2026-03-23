public with sharing class Product2Factory {
    public static List<Product2> assemble(Integer numberOfProducts) {

        List<Product2> products = new List<Product2>();

            for (Integer i = 0; i < numberOfProducts; i++) {
            Product2 p2 = new Product2(
                Name = 'Product ' + (i+1),
                ProductCode = 'P' + (i+1),
                IsActive = true
            );
            products.add(p2);
            }

            return products;

    }
}