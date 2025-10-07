SELECT * FROM vendas_itens2;

SELECT
    venda_id,
    SUM(quantidade * valor_unitario) AS total_venda,
    data_venda
FROM
    vendas_itens2
GROUP BY
    venda_id,
    data_venda
ORDER BY
    total_venda
LIMIT 1;

--

SELECT *
FROM vendas_itens2
WHERE unidade LIKE 'U%'
ORDER BY valor_unitario ASC
LIMIT 20;

--

ALTER TABLE vendas_itens2
ADD COLUMN custo_total NUMERIC(12,2);

--

UPDATE vendas_itens2
SET custo_total = ROUND(quantidade * valor_unitario, 2);

--

SELECT
    venda_id,
    SUM(custo_total) AS total_venda,
    data_venda
FROM
    vendas_itens2
GROUP BY
    venda_id,
    data_venda
ORDER BY
    total_venda;

--

SELECT produto_id, SUM(quantidade) AS total_unidade_vendidas, COUNT(DISTINCT venda_id) AS vezes_apareceu
FROM vendas_itens2
GROUP BY produto_id;

-- 

SELECT venda_id, SUM(custo_total) AS total_venda, data_venda
FROM vendas_itens2
GROUP BY venda_id, data_venda
HAVING SUM(custo_total) < 400
ORDER BY total_venda ASC;


