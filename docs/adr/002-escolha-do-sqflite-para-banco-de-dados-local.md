# ADR 002: Escolha do sqflite para Banco de Dados Local

## Status

Aceito

## Contexto

O aplicativo aBible precisa de uma solução de banco de dados local para armazenar as Bíblias, as configurações do usuário, os marcadores e o histórico de leitura.

## Decisão

Escolhemos o `sqflite` como a nossa solução de banco de dados local. Ele é um wrapper em torno do SQLite, uma solução de banco de dados robusta e amplamente utilizada.

## Consequências

-   **Positivas**:
    -   Rápido e eficiente.
    -   Confiável e estável.
    -   Boa documentação e suporte da comunidade.
-   **Negativas**:
    -   Requer a escrita de SQL bruto, o que pode ser verboso.
    -   Não possui um sistema de migração de esquema integrado (precisamos implementar o nosso próprio).
