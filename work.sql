DROP VIEW IF EXISTS dv01_sale;
CREATE VIEW dv01_sale AS
SELECT vente.id,
       vente.date,
       vente.numVente AS orderNumber,
       IF(consommation.denomination = 'Sur place', 'Y', 'N') AS onSite
FROM vente
INNER JOIN consommation ON vente.id_Consommation = consommation.id;

DROP VIEW IF EXISTS dv01_saleline;
CREATE VIEW dv01_saleline AS
SELECT lignedevente.id,
       produit.denomination AS product,
       typedetaille.denomination AS size,
       lignedevente.quantite AS quantity,
       lignedevente.prix AS unitPrice,
       GROUP_CONCAT(supplement.denomination SEPARATOR ',') AS options,
       lignedevente.id_Vente AS id_dv01_sale
FROM lignedevente
INNER JOIN produit ON lignedevente.id_Produit = produit.id
LEFT JOIN typedetaille ON lignedevente.id_TypeDeTaille = typedetaille.id
LEFT JOIN lignedoption ON lignedevente.id = lignedoption.id_LigneDeVente
LEFT JOIN supplement ON lignedoption.id_Supplement = supplement.id
GROUP BY lignedevente.id;

DROP PROCEDURE IF EXISTS getAllSales;

DELIMITER //
CREATE PROCEDURE getAllSales()
BEGIN
    SELECT * FROM dv01_sale;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS getSaleById;

DELIMITER //
CREATE PROCEDURE getSaleById(
    IN _id INT
)
BEGIN
    SELECT * FROM dv01_sale WHERE id = _id;
END //


DROP PROCEDURE IF EXISTS getAllSaleLines;

DELIMITER //
CREATE PROCEDURE getAllSaleLines()
BEGIN
    SELECT * FROM dv01_saleline;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS getSaleLineById;

DELIMITER //
CREATE PROCEDURE getSaleLineById(
    IN _id INT
)
BEGIN
   SELECT * FROM dv01_saleline WHERE id = _id;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS createSale;

DELIMITER //
CREATE PROCEDURE createSale(
    IN _orderNumber VARCHAR(10),
    IN _onSite VARCHAR(1)
)
BEGIN
    DECLARE exist INT;
    DECLARE errorMessage VARCHAR(255);

    SET exist = (SELECT COUNT(*) FROM dv01_sale WHERE orderNumber = _orderNumber);

    IF exist = 1 THEN
        SET errorMessage = CONCAT('sale with id = "', _orderNumber, '" already exists');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    IF _onSite != 'Y' AND _onSite != 'N' THEN
        SET errorMessage = CONCAT('onSite cannot be "', _onSite, '" only "Y" or "N"');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    INSERT INTO vente(date,
                      numVente,
                      id_Consommation
    ) VALUES (CURDATE(),
              _orderNumber,
              (
                SELECT id
                FROM consommation
                WHERE denomination = IF(_onSite = 'Y', 'Sur Place', 'A emporter')
              )
    );
END //
DELIMITER ;