-- Cria o banco de dados principal (Data Warehouse)
CREATE DATABASE dw;

-- Cria o usuário administrador para o Airflow e DBT
CREATE USER dw_user WITH ENCRYPTED PASSWORD 'dw_pass';

-- Concede todos os privilégios no banco 'dw' para o usuário 'dw_user'
GRANT ALL PRIVILEGES ON DATABASE dw TO dw_user;
