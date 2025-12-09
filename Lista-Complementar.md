# Atividade Complementar

O objetivo desta atividade é praticar os conceitos utilizados em sistemas de banco de dados e será considerada como atividade complementar.

Para os alunos que compareceram à aula e participaram da explicação, a atividade será avaliada com **3 pontos complementares**. Para os alunos que não compareceram à aula, mas se propuseram a estudar os conceitos e realizar a atividade, serão contabilizados **1,5 pontos complementares**.

A atividade deverá ser entregue até o dia **09/12**, às **23h59**, pelo **portal UNIPAM**, em **formato PDF**.

Utilize o modelo `.docx` para inserir as capturas de tela (prints) da atividade.

# COMMIT

O comando **COMMIT** confirma todas as alterações feitas na transação corrente e torna essas alterações permanentes e visíveis para outros usuários. Em bancos de dados que seguem as propriedades ACID, o COMMIT garante a durabilidade, ou seja, uma vez confirmado, o efeito das operações não se perde mesmo que ocorra uma falha no sistema. Normalmente o fluxo é iniciar uma transação, executar uma ou mais instruções DML como `INSERT`, `UPDATE` e `DELETE`, e então executar `COMMIT` se todas as operações tiverem sido bem sucedidas. Se algo deu errado antes do COMMIT, usa-se `ROLLBACK` para desfazer as alterações.

Alguns pontos importantes:

* Em muitos sistemas existe autocommit por padrão. Nesse modo cada instrução DML é automaticamente confirmada se não ocorrer erro.
* Em outros casos é necessário abrir explicitamente a transação com `BEGIN TRANSACTION` ou `BEGIN` e só confirmar com `COMMIT` no fim.
* Algumas operações DDL em certos SGBD provocam COMMIT implícito, por isso tenha cuidado ao executar alterações de esquema dentro de transações longas.

Exemplo simples de uso em uma transferência entre contas:

```sql
BEGIN TRANSACTION;
UPDATE conta SET saldo = saldo - 100 WHERE id = 1;
UPDATE conta SET saldo = saldo + 100 WHERE id = 2;
COMMIT;
````

# ROLLBACK

O comando **ROLLBACK** desfaz todas as alterações realizadas na transação corrente desde o último `BEGIN TRANSACTION` ou desde o último `SAVEPOINT`. É a ferramenta para manter a consistência quando uma sequência de operações não pode ser concluída corretamente.

Características e usos:

  * ROLLBACK anula todas as mudanças não confirmadas, retornando os dados ao estado que tinham antes do início da transação.
  * É comumente usado em tratamento de erros, por exemplo quando uma violação de integridade ou outra exceção é detectada durante uma sequência de operações.
  * Savepoints permitem desfazer apenas parte de uma transação. Com `SAVEPOINT` você cria um ponto intermediário e pode depois usar `ROLLBACK TO SAVEPOINT` para voltar apenas até ali, sem abortar toda a transação.

Exemplo com savepoint:

```sql
BEGIN TRANSACTION;
UPDATE estoque SET quantidade = quantidade - 10 WHERE produto_id = 5;
SAVEPOINT antes_bonus;
UPDATE cliente SET bonus = bonus + 20 WHERE id = 42;
-- se der erro na atualização do cliente
ROLLBACK TO antes_bonus;
-- ainda dentro da mesma transação posso corrigir e depois confirmar
COMMIT;
```

# Trigger

**Trigger** é um objeto do banco de dados que contém código executável automaticamente em resposta a um evento sobre uma tabela ou view. Triggers permitem reagir a operações DML sem que a aplicação precise emitir explicitamente esse comportamento.

Principais conceitos:

  * **Evento acionador:** Os eventos mais comuns são `INSERT`, `UPDATE` e `DELETE`. Em alguns SGBD também há eventos para DDL ou logon.
  * **Momento de execução:** Triggers podem ser definidas para rodar `BEFORE`, `AFTER` ou `INSTEAD OF` do evento. `BEFORE` altera ou valida dados antes da operação principal. `AFTER` executa ações após a operação. `INSTEAD OF` substitui a operação, sendo comum em views.
  * **Escopo:** Triggers podem ser de nível por linha (*FOR EACH ROW*) para executar uma ação para cada linha afetada ou de nível por instrução (*FOR EACH STATEMENT*) para executar uma única vez por instrução, independentemente do número de linhas alteradas.
  * **Ambiente transacional:** A execução da trigger faz parte da transação que disparou o evento. Se a transação for `ROLLBACK`, os efeitos da trigger também são revertidos. Em muitos SGBD não é permitido executar `COMMIT` ou `ROLLBACK` dentro de triggers.

Usos típicos:

  * Auditoria, registrando quem, quando e quais alterações foram feitas.
  * Cálculo automático de campos derivados, como atualizar soma acumulada ou timestamps.
  * Validação complexa de regras de negócio que não são fáceis de expressar com constraints declarativas.
  * Propagar mudanças para outras tabelas, por exemplo atualizar estoque após venda.

Exemplo conceitual de trigger de auditoria:

```sql
CREATE TRIGGER auditoria_ins
AFTER INSERT ON vendas
FOR EACH ROW
EXECUTE FUNCTION gravar_auditoria();
```

Nesse exemplo a função `gravar_auditoria` receberia informações da linha nova e registraria um log em tabela de auditoria. A trigger será executada automaticamente sempre que ocorrer um `INSERT` em `vendas` e fará parte da mesma transação do `INSERT`.

Cuidados e boas práticas:

  * Prefira restrições declarativas quando possível. `UNIQUE`, `CHECK` e `FOREIGN KEY` são mais eficientes e mais fáceis de entender do que lógica equivalente implementada apenas em triggers.
  * Mantenha triggers simples e rápidas. Código pesado dentro de triggers pode degradar muito a performance, porque roda no caminho crítico da operação DML.
  * Documente triggers. Elas causam lógica oculta que pode confundir desenvolvedores que não as conhecem.
  * Evite efeitos colaterais inesperados e chamadas recursivas. Dependendo do SGBD triggers podem disparar outros triggers e causar recursão ou efeitos difíceis de depurar.
  * Teste transações com triggers. Como triggers participam da transação, erros na trigger devem ser tratados para não provocar `ROLLBACK` indesejado.

# Resumo final

COMMIT confirma e torna permanentes as alterações de uma transação, garantindo durabilidade. ROLLBACK desfaz alterações não confirmadas, permitindo recuperar um estado consistente. Trigger é um mecanismo que executa código automaticamente em resposta a eventos no banco, sendo útil para auditoria, validação e manutenção de regras de negócio, mas exige cuidado com performance e previsibilidade. Em conjunto, esses conceitos são centrais para controlar integridade, consistência e comportamento automático dentro de sistemas de gerenciamento de banco de dados.

-----

# Aula prática: COMMIT, ROLLBACK e TRIGGER no PostgreSQL

Segue o roteiro passo a passo para executar e demonstrar os conceitos de COMMIT e ROLLBACK no Codespace do GitHub usando o arquivo `docker-compose.yml`, que inicia um container PostgreSQL. O arquivo também inclui os scripts SQL prontos para serem executados na sua extensão de conexão ao banco.

## Pré-requisitos

1.  Codespace com Docker disponível
2.  Arquivo `docker-compose.yml` com o serviço PostgreSQL conforme abaixo:

<!-- end list -->

```yaml
version: '3.8'

services:
  postgres-db:
    image: postgres:13
    container_name: postgres_container
    restart: unless-stopped
    environment:
      POSTGRES_USER: root
      POSTGRES_PASSWORD: root
      POSTGRES_DB: bd_aula02
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

3.  Sua extensão cliente configurada para conectar em host `127.0.0.1` porta `5432` usuário `root` senha `root` database `bd_aula02`.

## 1\. Subir o container PostgreSQL

No terminal do Codespace execute:

```bash
# subir o serviço em background
docker compose up -d

# verificar se o container está pronto
docker ps
```

## 2\. Acessar o banco

Opcionalmente você pode entrar no psql dentro do container:

```bash
docker exec -it postgres_container psql -U root -d bd_aula02
```

Ou use a sua extensão para executar os blocos SQL que seguem.

## 3\. Criar esquema e dados de exemplo

Cole e execute o bloco abaixo. Ele cria a tabela de contas e a tabela de auditoria usadas na demonstração.

```sql
-- criar tabelas de exemplo
CREATE TABLE IF NOT EXISTS conta (
  conta_id SERIAL PRIMARY KEY,
  titular VARCHAR(150) NOT NULL,
  saldo NUMERIC(12,2) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS conta_auditoria (
  audit_id SERIAL PRIMARY KEY,
  conta_id INT,
  operacao VARCHAR(10),
  antiga NUMERIC(12,2),
  nova NUMERIC(12,2),
  usuario VARCHAR(150),
  data_hora TIMESTAMPTZ DEFAULT now()
);

-- limpar e inserir dados iniciais
TRUNCATE TABLE conta RESTART IDENTITY CASCADE;
TRUNCATE TABLE conta_auditoria RESTART IDENTITY;

INSERT INTO conta(titular, saldo) VALUES
('Alice', 1000.00),
('Bruno', 500.00);

-- conferir
SELECT * FROM conta ORDER BY conta_id;
```

## 4\. Criar a Trigger de Auditoria

Para que a tabela `conta_auditoria` funcione, precisamos criar a função e a trigger. Execute o bloco abaixo:

```sql
-- 1. Criar a função que será executada pela trigger
CREATE OR REPLACE FUNCTION fn_auditoria_saldo()
RETURNS TRIGGER AS $$
BEGIN
  -- Insere na tabela de auditoria os dados da operação
  INSERT INTO conta_auditoria (conta_id, operacao, antiga, nova, usuario)
  VALUES (
    NEW.conta_id,       -- ID da conta afetada
    TG_OP,              -- Operação (UPDATE)
    OLD.saldo,          -- Saldo anterior
    NEW.saldo,          -- Saldo novo
    current_user        -- Usuário do banco
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Criar a trigger associada à tabela conta
CREATE TRIGGER trg_audit_saldo
AFTER UPDATE ON conta
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_saldo();
```

## 5\. Demonstrar COMMIT com Trigger

Objetivo: mostrar uma transferência entre contas, confirmar as mudanças e verificar se a trigger registrou a auditoria.

```sql
BEGIN;
UPDATE conta SET saldo = saldo - 100.00 WHERE conta_id = 1;
UPDATE conta SET saldo = saldo + 100.00 WHERE conta_id = 2;
COMMIT;

-- Verificar o saldo atualizado
SELECT conta_id, titular, saldo FROM conta ORDER BY conta_id;

-- Verificar se a trigger gravou o histórico
SELECT * FROM conta_auditoria ORDER BY audit_id;
```

Explicação breve:

  - `BEGIN` inicia uma transação.
  - Os `UPDATE` alteram os saldos e **acionam a trigger** `trg_audit_saldo` automaticamente.
  - `COMMIT` confirma as alterações na conta e na auditoria.

## 6\. Demonstrar ROLLBACK

Objetivo: mostrar que uma sequência de operações (incluindo a trigger) pode ser anulada.

```sql
BEGIN;
-- Tentativa de transação com valores errados
UPDATE conta SET saldo = saldo - 100000.00 WHERE conta_id = 1;
UPDATE conta SET saldo = saldo + 100000.00 WHERE conta_id = 2;

-- Verificamos que algo está errado e damos rollback
ROLLBACK;

-- Verificar que os saldos voltaram ao normal
SELECT conta_id, titular, saldo FROM conta ORDER BY conta_id;

-- Verificar que a auditoria também foi revertida (não há registros dessa tentativa falha)
SELECT * FROM conta_auditoria WHERE nova > 10000;
```

Explicação breve:

  - `ROLLBACK` desfaz todas as alterações feitas desde o `BEGIN`.
  - Como a trigger roda dentro da mesma transação, o registro na auditoria também é desfeito.

## 7\. Demonstrar SAVEPOINT e ROLLBACK TO SAVEPOINT

Objetivo: desfazer apenas parte de uma transação.

```sql
BEGIN;
UPDATE conta SET saldo = saldo - 10.00 WHERE conta_id = 1;
SAVEPOINT antes_bonus;

UPDATE conta SET saldo = saldo + 10.00 WHERE conta_id = 2;

-- desfazer apenas a segunda atualização (crédito no id 2)
ROLLBACK TO antes_bonus;

COMMIT;

SELECT conta_id, titular, saldo FROM conta ORDER BY conta_id;
```

Explicação breve:

  - `SAVEPOINT` cria um ponto intermediário dentro da transação.
  - `ROLLBACK TO` reverte até esse ponto sem abortar toda a transação.