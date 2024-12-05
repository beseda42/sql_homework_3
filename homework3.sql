-- С помощью оконных функций вывести для каждого товара его id, название,
-- а также название магазина, в котором данный товар представлен в наибольшем количестве.

SELECT Sort.id, Sort.good_name, Sort.shop_name FROM 
(SELECT Good.id, Good.name AS good_name, Shop.name AS shop_name, Good_shop.count, RANK() OVER 
(PARTITION BY Good.id ORDER BY Good_shop.count DESC) AS max
FROM Good JOIN Good_shop ON (Good.id = Good_shop.id_good) JOIN Shop ON (Good_shop.id_shop = Shop.id)) AS Sort
WHERE Sort.max = 1

-- Вывести для каждого магазина его id, название и название категории товаров, представленной в данном магазине в наименьшем количестве.

WITH CountCategory AS (
    SELECT Shop.id, Shop.name AS shop_name, GoodCategory.name AS category_name, SUM(Good_shop.count) AS total, MIN(SUM(Good_shop.count)) OVER (PARTITION BY Shop.id) AS min
    FROM Shop 
    JOIN Good_shop ON (Shop.id = Good_shop.id_shop)
    JOIN Good ON Good_shop.id_good = Good.id
    JOIN GoodCategory ON (Good.id_goodcategory = GoodCategory.id)
    GROUP BY Shop.id, Shop.name, GoodCategory.name)

SELECT CountCategory.id, CountCategory.shop_name, CountCategory.category_name FROM CountCategory WHERE total = min

-- Вывести id и адреса тех складов, объем запасов на которых составляет менее половины от всех запасов товаров на складах.

WITH Total_All AS (SELECT SUM(count) AS count FROM Good_Warehouse),
Total_Warehouse AS (SELECT Warehouse.id,Warehouse.address, SUM(Good_Warehouse.count) AS count FROM 
    Warehouse JOIN Good_Warehouse ON (Warehouse.id = Good_Warehouse.id_warehouse)
    GROUP BY Warehouse.id, Warehouse.address)
SELECT id, address FROM Total_Warehouse WHERE count < (SELECT count FROM Total_All) / 2