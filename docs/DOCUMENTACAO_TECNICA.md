# Documentação do Projeto aBible

Esta documentação fornece uma visão geral detalhada do projeto aBible, incluindo sua arquitetura, componentes principais e funcionalidades.

## 1. Estrutura do Projeto

A seguir, uma descrição da estrutura de diretórios do projeto e a finalidade de cada um.

- `lib/`: Contém todo o código-fonte do aplicativo em Dart.
  - `constants/`: Arquivos com constantes utilizadas em todo o aplicativo, como IDs de anúncios, chaves de preferência e valores fixos.
  - `database/`: Classes responsáveis pela gestão do banco de dados SQLite, incluindo o `DatabaseHelper` que gerencia o acesso e as operações na base de dados da Bíblia.
  - `models/`: Modelos de dados que representam as estruturas de dados do aplicativo, como versículos, livros e marcadores.
  - `screens/`: As diferentes telas (telas de UI) do aplicativo, como a tela principal de navegação, a tela de leitura da Bíblia e as configurações.
  - `services/`: Lógica de negócios e serviços, como `ThemeManager` para gerenciar temas, `PurchaseService` para compras no aplicativo e `FontManager` para o gerenciamento de fontes.
  - `widgets/`: Componentes de UI reutilizáveis usados em várias telas do aplicativo.

## 2. Inicialização do Aplicativo

O ponto de entrada do aplicativo é `lib/main.dart`. Esta seção detalha o processo de inicialização.

O processo de inicialização do aplicativo (`main` function) segue os seguintes passos:

1.  **`WidgetsFlutterBinding.ensureInitialized()`**: Garante que o binding do Flutter seja inicializado antes de qualquer outra coisa.
2.  **Inicialização do SQFLite para Desktop**: Se a plataforma for Windows, Linux ou macOS, ele inicializa o `sqflite_common_ffi`.
3.  **`WakelockPlus.enable()`**: Verifica as preferências do usuário para manter a tela ligada e ativa o `WakelockPlus` se necessário.
4.  **`MobileAds.instance.initialize()`**: Inicializa o SDK do Google Mobile Ads.
5.  **`PurchaseService`**: Inicializa o serviço de compras e carrega o status de compra do usuário.
6.  **`ThemeManager`**: Inicializa o gerenciador de temas, configurando o status premium com base no `PurchaseService`.
7.  **`FontManager`**: Inicializa o gerenciador de fontes.
8.  **`BookmarksProvider` e `NavigationProvider`**: Inicializam os providers de marcadores e navegação.
9.  **`runApp(MyApp(...))`**: Inicia a aplicação com o widget `MyApp`, passando todas as instâncias dos serviços inicializados.
10. **Verificação do Banco de Dados**: No `_MyAppState`, `_checkDatabaseInitialization` verifica se o banco de dados já foi inicializado. Se não, a `DatabaseInitializationScreen` é exibida para guiar o usuário no processo de download e configuração da Bíblia.

## 3. Componentes Principais

Esta seção descreve os principais widgets e telas que compõem a interface do usuário.

-   **`MainNavigationScreen`**: A tela principal do aplicativo, que gerencia a navegação entre as diferentes seções: Leitura da Bíblia, Pesquisa, Marcadores e Configurações.
-   **`DatabaseInitializationScreen`**: Tela exibida na primeira inicialização do aplicativo para guiar o usuário no processo de download e configuração da base de dados da Bíblia.
-   **`BibleReaderScreen`**: A tela de leitura da Bíblia, onde o usuário pode navegar entre livros, capítulos e versículos.
-   **`SettingsScreen`**: Tela de configurações, onde o usuário pode personalizar o tema, a fonte e outras preferências.

## 4. Gerenciamento de Estado

O aplicativo utiliza o `Provider` para gerenciamento de estado.

O `Provider` é utilizado para disponibilizar os serviços (`ThemeManager`, `PurchaseService`, etc.) para a árvore de widgets. O `MultiProvider` em `MyApp` registra os `ChangeNotifierProvider`s, permitindo que os widgets acessem e ouçam as mudanças de estado.

Os principais providers são:

-   **`ThemeManager`**: Gerencia o tema atual do aplicativo.
-   **`PurchaseService`**: Gerencia o status de compra da versão PRO.
-   **`FontManager`**: Gerencia as configurações de fonte.
-   **`BookmarksProvider`**: Gerencia a lista de marcadores.
-   **`NavigationProvider`**: Gerencia o estado da navegação principal.

## 5. Funcionalidades Principais

Detalhes sobre as principais funcionalidades do aplicativo.

-   **Gerenciamento de Temas**: O `ThemeManager` permite que o usuário alterne entre diferentes temas (claro, escuro, etc.).
-   **Compras no Aplicativo**: O `PurchaseService` gerencia a compra da versão PRO, que desbloqueia funcionalidades adicionais.
-   **Gerenciamento de Fontes**: O `FontManager` permite que o usuário ajuste o tamanho e o tipo da fonte de leitura.
-   **Marcadores**: O `BookmarksProvider` permite que o usuário salve e gerencie marcadores de versículos.

## 6. Base de Dados

Informações sobre a gestão da base de dados no aplicativo.

O aplicativo utiliza o `sqflite` para gerenciar a base de dados. O `DatabaseHelper` é a classe principal que gerencia a inicialização e o acesso à base de dados.

-   **`bible_reader_config.db`**: Base de dados de configurações que armazena as preferências do usuário, marcadores e histórico de leitura.
-   **Bases de Dados da Bíblia**: As bases de dados da Bíblia (ex: `nvi.db`, `kjv.db`) são extraídas dos assets do aplicativo e instaladas na primeira inicialização.

## 7. Fluxo de Dados

O fluxo de dados do aplicativo segue o padrão do `Provider`, onde os widgets da UI reagem a mudanças de estado nos serviços.

1.  **Ação do Usuário**: Um usuário interage com um widget na tela (ex: clica em um botão para mudar o tema).
2.  **Chamada de Serviço**: O widget notifica o serviço correspondente (ex: `ThemeManager.setTheme(...)`).
3.  **Atualização do Estado**: O serviço atualiza seu estado interno e notifica os ouvintes através do `notifyListeners()`.
4.  **Reconstrução da UI**: Os widgets que estão ouvindo as mudanças no serviço (usando `Consumer` ou `Provider.of`) são reconstruídos para refletir o novo estado.

## 8. Descrição Detalhada dos Serviços

-   **`ThemeManager`**: Gerencia o tema do aplicativo (claro, escuro, etc.) e notifica a UI sobre mudanças.
-   **`PurchaseService`**: Lida com compras no aplicativo, verifica o status da versão PRO e disponibiliza esse estado para o restante do aplicativo.
-   **`FontManager`**: Gerencia as preferências de fonte do usuário, como tamanho e tipo de fonte.
-   **`BookmarksProvider`**: Adiciona, remove e busca marcadores de versículos no banco de dados.
-   **`NavigationProvider`**: Gerencia o estado de navegação da barra de navegação principal.
-   **`BibleMetadata`**: Carrega e fornece metadados sobre as Bíblias, como a lista de livros e o número de capítulos.
-   **`BibleSettingsService`**: Gerencia as configurações de leitura da Bíblia, como a versão preferida.
-   **`ReadingPositionService`**: Salva e recupera a última posição de leitura do usuário.
