# ADR 001: Escolha do Provider para Gerenciamento de Estado

## Status

Aceito

## Contexto

Precisávamos de uma solução de gerenciamento de estado para o aplicativo aBible que fosse simples, eficiente e bem integrada com o ecossistema Flutter.

## Decisão

Escolhemos o `Provider` como a nossa principal solução de gerenciamento de estado. Ele permite a injeção de dependências e o gerenciamento de estado de forma reativa e com baixo boilerplate.

## Consequências

-   **Positivas**:
    -   Fácil de aprender e usar.
    -   Boa performance.
    -   Excelente integração com o Flutter.
-   **Negativas**:
    -   Pode se tornar complexo em cenários de estado muito grandes e interconectados.
