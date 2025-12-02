# Roteiro de aula prática - Sistemas de Banco de Dados

**Disciplina**: Sistemas de Banco de Dados

**Tema**: SQL, modelagem ER, consultas complexas, views, álgebra relacional, dependências funcionais e normalização

**Minimundo utilizado**: posto_combustivel

**Objetivos da aula**

- Revisar conceitos básicos de SQL e tipos de dados
- Praticar criação de esquemas, restrições e manipulação de dados
- Entender modelagem conceitual usando modelo Entidade Relacionamento ER
- Desenvolver consultas de recuperação simples e complexas, incluindo joins e views
- Relacionar operações de álgebra relacional com consultas SQL
- Introduzir dependências funcionais e as formas normais 1FN, 2FN e 3FN aplicadas ao minimundo

---

# Estrutura da aula prática

## Abertura e contexto

- Apresentação do minimundo posto_combustivel e as quatro tabelas principais
- Objetivo prático: criar o esquema, inserir os dados de exemplo e executar consultas

### Código base para criar as tabelas

```sql
CREATE TABLE combustivel (
  combustivel_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  estoque_l NUMERIC(12,3) NOT NULL DEFAULT 0,
  CONSTRAINT combustivel_nome_uniq UNIQUE (nome)
)

CREATE TABLE funcionario (
  funcionario_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  ativo BOOLEAN NOT NULL DEFAULT true
)

CREATE TABLE venda (
  venda_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  data_hora TIMESTAMPTZ NOT NULL DEFAULT now(),
  funcionario_id INT REFERENCES funcionario(funcionario_id) ON DELETE SET NULL,
  total NUMERIC(12,2) NOT NULL CHECK (total >= 0)
)

CREATE TABLE venda_item (
  venda_item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  venda_id INT NOT NULL REFERENCES venda(venda_id) ON DELETE CASCADE,
  combustivel_id INT NOT NULL REFERENCES combustivel(combustivel_id),
  quantidade_l NUMERIC(12,3) NOT NULL CHECK (quantidade_l >= 0),
  preco_unitario NUMERIC(12,4) NOT NULL CHECK (preco_unitario >= 0)
)

CREATE INDEX idx_venda_data_hora ON venda (data_hora)
CREATE INDEX idx_venda_item_combustivel ON venda_item (combustivel_id)
```

> Observação: os comandos acima criam o esquema do banco usado nas atividades

## Tópico 1 - SQL básica

### 1.1 Definições e tipos de dados em SQL

> Responda as seguintes questões:

- Explique os tipos numéricos NUMERIC e suas precisões, VARCHAR para texto, BOOLEAN, TIMESTAMPTZ para data e hora com fuso
- Explique os conceitos das constraints NOT NULL, DEFAULT e UNIQUE

Atividade prática 1

- Criar as tabelas usando o código fornecido
- Verifique a estrutura das tabelas com \d nome_da_tabela no psql ou com as extensões apresentadas durante as aulas

### 1.2 Especificação de restrições em SQL

> Responda as seguintes questões:
- Explique os conceitos sobre PK, FK, CHECK, UNIQUE e ON DELETE SET NULL ou CASCADE

Atividade prática 2

- Tentar inserir um combustivel com nome duplicado e observar a violação de UNIQUE
- Testar inserir venda com total negativo e observar o CHECK

### 1.3 Consulta de recuperação básica em SQL

- SELECT simples, cláusula WHERE, ORDER BY, LIMIT
- Demonstrar listagem de combustíveis por estoque decrescente

```sql
SELECT
  c.combustivel_id,
  c.nome,
  c.estoque_l
FROM
  combustivel AS c
ORDER BY c.estoque_l DESC
```

Atividade prática 3
> Responda as seguintes questões:
- Execute a query acima e interprete o resultado
- Modifique a query para mostrar apenas combustíveis com estoque maior que 1000 litros

### 1.4 Instruções Insert, Delete e Update em SQL

- Mostrar inserts de exemplo para popular as tabelas

```sql
INSERT INTO combustivel (nome, estoque_l) VALUES
  ('Gasolina', 1200.5),
  ('Etanol',  800.25),
  ('Diesel S10', 1500.0)

INSERT INTO funcionario (nome, ativo) VALUES
  ('Ana Silva', true),
  ('José Maria', true)

INSERT INTO venda (data_hora, funcionario_id, total) VALUES
  ('2025-11-01 09:15:00-03', 1, 210.04),
  ('2025-11-01 10:05:00-03', 2, 150.12),
  ('2025-11-01 11:00:00-03', 1,  50.15),
  ('2025-11-01 11:30:00-03', 1,  80.28),
  ('2025-11-01 11:32:00-03', 2, 110.16),
  ('2025-11-01 12:32:00-03', 2, 217.50)

INSERT INTO venda_item (venda_id, combustivel_id, quantidade_l, preco_unitario) VALUES
  (1, 1, 35.6, 5.9),
  (2, 2, 41.7, 3.6),
  (3, 1,  8.5, 5.9),
  (4, 2, 22.3, 3.6),
  (5, 2, 30.6, 3.6),
  (6, 3, 37.5, 5.8)
```

---

## Tópico 2 - Modelagem de dados usando ER

### 2.1 Modelos de dados conceituais de alto nível
> Responda as seguintes questões:
- Apresente o diagrama ER do minimundo, mostrando entidades combustivel, funcionario, venda e venda_item
- Explique os relacionamentos 1 para muitos entre venda e venda_item e entre funcionario e venda

### 2.2 Tipos de Entidades, conjuntos de entidades, atributos e chaves
> Usando como referência as tabelas criadas, apresente a seguir:
- Entidade forte, atributos simples e compostos, chave primária, chave estrangeira

---

## Tópico 3 - Consultas complexas, views e modificação de esquema

### 3.1 Consultas de recuperação SQL

- Revisar SELECT com agregações, GROUP BY, HAVING, ORDER BY
- Exemplo no minimundo: total vendido por funcionário

```sql
SELECT
  f.nome,
  SUM(v.total) as total_funcionario
FROM
  funcionario f
JOIN
  venda v
  ON v.funcionario_id = f.funcionario_id
GROUP BY
  f.nome
```

- Exemplo total vendido por combustível usando venda_item

```sql
SELECT
  c.combustivel_id,
  c.nome,
  SUM(vi.quantidade_l * vi.preco_unitario) AS total_vendido
FROM combustivel c
JOIN venda_item vi
  ON vi.combustivel_id = c.combustivel_id
GROUP BY
  c.combustivel_id, c.nome
```

Atividade prática 4

- Modifique as queries para incluir filtros por data e para ordenar por total vendido
- Adicione coluna com quantidade total vendida por combustível usando SUM(vi.quantidade_l)

### 3.2 Visões views - tabelas virtuais em SQL
> Responda as seguintes questões:
- Explicar o que é uma view, vantagens e limitações, e quando usar
- Crie view que mostra resumo de venda por combustível

```sql
CREATE VIEW resumo_venda_combustivel AS
SELECT
  c.combustivel_id,
  c.nome,
  SUM(vi.quantidade_l) AS litros_vendidos,
  SUM(vi.quantidade_l * vi.preco_unitario) AS valor_vendido
FROM combustivel c
JOIN venda_item vi ON vi.combustivel_id = c.combustivel_id
GROUP BY c.combustivel_id, c.nome
```

Atividade prática 5

- Consultar a view com SELECT * FROM resumo_venda_combustivel
- Alterar a view para incluir preço medio por litro calculado como valor_vendido / litros_vendidos usando CREATE OR REPLACE VIEW

### 3.3 Inner Join, Left Join, Right Join

- Demonstrar diferenças com exemplos

```sql
-- registros de vendas com dados do funcionário, somente quando houver correspondência
SELECT v.venda_id, v.data_hora, f.nome FROM venda v INNER JOIN funcionario f ON v.funcionario_id = f.funcionario_id

-- todos os funcionários e as vendas quando existirem
SELECT f.nome, v.venda_id FROM funcionario f LEFT JOIN venda v ON v.funcionario_id = f.funcionario_id
```

Atividade prática 6

- Executar LEFT JOIN para listar funcionários que não têm vendas
- Executar RIGHT JOIN se o SGBD suportar, ou inverter a query com LEFT JOIN para obter mesmo resultado


---

## Tópico 4 - Dependências funcionais e normalização (20 minutos)

### 4.1 Dependências funcionais

- Definição: para atributos A e B, A determina B se para cada valor de A existe um único valor de B
- Exemplos no minimundo: combustivel_id determina nome e estoque_l
- Em venda, venda_id determina data_hora, funcionario_id e total

Atividade prática 7

- Identificar dependências funcionais implicitas no esquema

### 4.2 Formas normais baseadas em chaves primárias

- Revisar 1FN, 2FN e 3FN de forma prática

### 4.3 Segunda e Terceira formas normais

- 1FN exige que cada atributo contenha valores atômicos e que exista uma chave primária
- 2FN exige 1FN e que não haja dependências parciais de atributos não chave em relação a parte de uma chave composta
- 3FN exige 2FN e que não existam dependências transitivas de atributos não chave

Aplicação ao minimundo

- O modelo apresentado já está em 3FN

Justificativa

- combustivel tem chave combustivel_id que determina todos os atributos de combustivel
- funcionario tem chave funcionario_id que determina seus atributos
- venda tem chave venda_id que determina data_hora, funcionario_id e total
- venda_item é entidade associativa com chave venda_item_id e referências para venda e combustivel
- Não há atributo multivalorado nem repetição de grupos, portanto 1FN satisfeita
- Não existem chaves compostas com atributos dependentes parcialmente, logo 2FN satisfeita
- Não existem dependências transitivas entre atributos não chave, portanto 3FN satisfeita

---
