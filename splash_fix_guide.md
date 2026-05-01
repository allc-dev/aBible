# Guia de Ajuste: Splash Screen Branca em Modo Escuro (Android)

Para garantir que a Splash Screen fique sempre branca com o ícone no tamanho correto, independente do tema do sistema, siga estes passos nos arquivos nativos do Android em seus projetos Flutter.

## 1. Ajuste para Android 12 ou superior (v31)
Edite o arquivo: `android/app/src/main/res/values-night-v31/styles.xml`

**O que mudar:**
Altere o `parent` dos temas `LaunchTheme` e `NormalTheme` de **Black** para **Light**.

```xml
<!-- Antes -->
<style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">

<!-- Depois -->
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
```

> **NOTA IMPORTANTE:** Não adicione as tags `windowSplashScreenBackground` ou `windowSplashScreenAnimatedIcon` manualmente. Ao mudar o tema pai para `Light`, o Android assume o fundo branco e mantém a escala original do ícone.

## 2. Ajuste para versões anteriores do Android
Edite o arquivo: `android/app/src/main/res/values-night/styles.xml`

**O que mudar:**
Faça a mesma alteração do tema pai:

```xml
<!-- Antes -->
<style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">

<!-- Depois -->
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
```

## 3. Configuração no pubspec.yaml (Prevenção)
Para evitar que o plugin `flutter_native_splash` reverta essas alterações ao ser executado novamente, adicione:

```yaml
flutter_native_splash:
  color: "#ffffff"
  color_dark: "#ffffff" # Força o fundo branco na geração automática
```

---
**Por que isso funciona?**
O Android usa o tema pai para definir a cor da janela inicial. Forçando `Theme.Light` nos arquivos de "night mode", garantimos o fundo branco sem ativar as restrições de redimensionamento de ícone da nova Splash API do Android 12.
