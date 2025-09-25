CREATE TABLE IF NOT EXISTS vendas_itens (
  id SERIAL PRIMARY KEY,
  venda_id INTEGER NOT NULL,
  produto_id INTEGER NOT NULL,
  valor_unitario NUMERIC(10,2) NOT NULL,
  data_venda DATE NOT NULL
);

INSERT INTO vendas_itens (venda_id, produto_id, valor_unitario, data_venda) VALUES
-- 5 vendas com 5 produtos (venda_id 2001..2005)
(2001, 1, 150.55, '2025-09-01'),
(2001, 3, 45.00, '2025-09-01'),
(2001, 5, 12.75, '2025-09-01'),
(2001, 9, 88.78, '2025-09-01'),
(2001, 10, 10.00, '2025-09-01'),

(2002, 2, 99.90, '2025-09-02'),
(2002, 4, 220.00, '2025-09-02'),
(2002, 6, 60.00, '2025-09-02'),
(2002, 8, 34.50, '2025-09-02'),
(2002, 1, 150.55, '2025-09-02'),

(2003, 7, 199.99, '2025-09-03'),
(2003, 9, 88.78, '2025-09-03'),
(2003, 3, 45.00, '2025-09-03'),
(2003, 2, 99.90, '2025-09-03'),
(2003, 5, 12.75, '2025-09-03'),

(2004, 4, 220.00, '2025-09-04'),
(2004, 6, 60.00, '2025-09-04'),
(2004, 1, 150.55, '2025-09-04'),
(2004, 7, 199.99, '2025-09-04'),
(2004, 10, 10.00, '2025-09-04'),

(2005, 8, 34.50, '2025-09-05'),
(2005, 9, 88.78, '2025-09-05'),
(2005, 2, 99.90, '2025-09-05'),
(2005, 3, 45.00, '2025-09-05'),
(2005, 4, 220.00, '2025-09-05'),

-- 4 vendas com 4 produtos (venda_id 2006..2009)
(2006, 1, 150.55, '2025-09-06'),
(2006, 5, 12.75, '2025-09-06'),
(2006, 9, 88.78, '2025-09-06'),
(2006, 10, 10.00, '2025-09-06'),

(2007, 7, 199.99, '2025-09-07'),
(2007, 6, 60.00, '2025-09-07'),
(2007, 8, 34.50, '2025-09-07'),
(2007, 2, 99.90, '2025-09-07'),

(2008, 3, 45.00, '2025-09-08'),
(2008, 4, 220.00, '2025-09-08'),
(2008, 1, 150.55, '2025-09-08'),
(2008, 9, 88.78, '2025-09-08'),

(2009, 5, 12.75, '2025-09-09'),
(2009, 10, 10.00, '2025-09-09'),
(2009, 6, 60.00, '2025-09-09'),
(2009, 7, 199.99, '2025-09-09'),

-- 2 vendas com 2 produtos (venda_id 2010..2011)
(2010, 2, 99.90, '2025-09-10'),
(2010, 3, 45.00, '2025-09-10'),

(2011, 8, 34.50, '2025-09-11'),
(2011, 9, 88.78, '2025-09-11'),

-- 1 venda com 1 produto (venda_id 2012)
(2012, 4, 220.00, '2025-09-12'),

-- 4 vendas adicionais com 1 produto cada para completar 50 registros (venda_id 2013..2016)
(2013, 1, 150.55, '2025-09-13'),
(2014, 10, 10.00, '2025-09-14'),
(2015, 5, 12.75, '2025-09-15'),
(2016, 7, 199.99, '2025-09-16');

SELECT * FROM vendas_itens;


SELECT 
    venda_id, 
    produto_id, 
    valor_unitario,
    data_venda
FROM 
    vendas_itens
WHERE 
    produto_id = 1;

--

SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens
WHERE
    venda_id = 2001;

--

SELECT
    venda_id,
    produto_id,
    valor_unitario,
    valor_unitario * 1.10 AS taxa_venda
FROM
    vendas_itens
WHERE
    venda_id = 2001;

--

SELECT * FROM vendas_itens
WHERE
    valor_unitario >= 50
    AND valor_unitario <= 100
ORDER BY
    valor_unitario ASC;

--

SELECT * FROM vendas_itens
WHERE
    valor_unitario >= 20
    OR valor_unitario < 200
ORDER BY
    valor_unitario ASC;

--

SELECT * FROM vendas_itens
WHERE produto_id IN (1, 2, 3);

--

SELECT 
    venda_id,
    SUM(valor_unitario) AS total_venda
FROM 
    vendas_itens
GROUP BY 
    venda_id
ORDER BY 
    venda_id ASC;