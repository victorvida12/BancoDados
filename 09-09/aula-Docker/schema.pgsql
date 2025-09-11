-- limpar caso existam (útil durante desenvolvimento)
DROP TABLE IF EXISTS pagamento;
DROP TABLE IF EXISTS inscricao;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS participante;

-- Tabela participante
CREATE TABLE participante (
id SERIAL PRIMARY KEY,
nome TEXT NOT NULL,
email TEXT NOT NULL UNIQUE,
telefone TEXT
);

-- Tabela evento
CREATE TABLE evento (
id SERIAL PRIMARY KEY,
nome TEXT NOT NULL,
descricao TEXT,
local TEXT NOT NULL,
data DATE NOT NULL
);

-- Tabela inscricao (associa Evento <-> Participante) - resolve N:M
CREATE TABLE inscricao (
id SERIAL PRIMARY KEY,
id_evento INTEGER NOT NULL REFERENCES evento(id) ON DELETE CASCADE,
id_participante INTEGER NOT NULL REFERENCES participante(id) ON DELETE CASCADE,
data_inscricao DATE,
status TEXT -- ex.: 'confirmada', 'cancelada'
);

-- Tabela pagamento (1:1 com inscricao)
CREATE TABLE pagamento (
id SERIAL PRIMARY KEY,
id_inscricao INTEGER UNIQUE REFERENCES inscricao(id) ON DELETE CASCADE,
valor NUMERIC(10,2),
data_pagamento DATE,
status TEXT -- ex.: 'pago', 'pendente'
);

