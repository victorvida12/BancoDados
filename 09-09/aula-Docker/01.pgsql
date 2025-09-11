CREATE TABLE participante (
id SERIAL PRIMARY KEY,
nome TEXT NOT NULL,
email TEXT NOT NULL UNIQUE,
telefone TEXT
);

CREATE TABLE evento (
id SERIAL PRIMARY KEY,
nome TEXT NOT NULL,
descricao TEXT,
local TEXT NOT NULL,
data DATE NOT NULL
);

CREATE TABLE inscricao (
id SERIAL PRIMARY KEY,
id_evento INTEGER NOT NULL REFERENCES evento(id) ON DELETE CASCADE,
id_participante INTEGER NOT NULL REFERENCES participante(id) ON DELETE CASCADE,
data_inscricao DATE,
status TEXT -- ex.: 'confirmada', 'cancelada'
);

CREATE TABLE pagamento (
id SERIAL PRIMARY KEY,
id_inscricao INTEGER UNIQUE REFERENCES inscricao(id) ON DELETE CASCADE,
valor NUMERIC(10,2),
data_pagamento DATE,
status TEXT -- ex.: 'pago', 'pendente'
);

INSERT INTO participante(nome, email, telefone) VALUES
('Victor','victor@email','123123123'),
('Silva','silva@email','321321321'),
('Vida','vida@email','132132132');

INSERT INTO evento(nome, descricao, local, data) VALUES
('Fenapraça','Pré aniversário de Patos de Minas','Praça do Coreto', '2025-09-10'),
('Macauba','Carnaval quebradeira','Parque de Exposições', '2025-02-15'),
('Infoweek','Semana do conhecimento','Auditório Bloco N', '2025-08-16');

INSERT INTO inscricao(id_evento, id_participante, data_inscricao, status) VALUES
(1, 1, '2025-04-08', 'Confirmada');

INSERT INTO pagamento(id_inscricao, valor, data_pagamento, status) VALUES
(1, 150.00, '2025-08-14', 'Pago');
