DROP VIEW IF EXISTS dv01_Sale;

CREATE VIEW dv01_Sale AS
SELECT vente.id,
       vente.date,
       vente.numVente AS orderNumber,
       IF(consommation.denomination = 'Sur place', 'Y', 'N') AS onSite
FROM vente
INNER JOIN consommation ON vente.id_Consommation = consommation.id;

DROP VIEW IF EXISTS dv01_SaleLine;
CREATE VIEW dv01_SaleLine AS
SELECT lignedevente.id,
       produit.denomination AS product,
       typedetaille.denomination AS size,
       lignedevente.quantite AS quantity,
       lignedevente.prix AS unitPrice,
       GROUP_CONCAT(supplement.denomination SEPARATOR ', ') AS options
FROM lignedevente
INNER JOIN produit ON lignedevente.id_Produit = produit.id
INNER JOIN typedetaille ON lignedevente.id_TypeDeTaille = typedetaille.id
LEFT JOIN lignedoption ON lignedevente.id = lignedoption.id_LigneDeVente
LEFT JOIN supplement ON lignedoption.id_Supplement = supplement.id
GROUP BY lignedevente.id;