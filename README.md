# Muro de Grafite

Mural colaborativo de grafite onde usuários podem desenhar sobre uma parede urbana e publicar seus desenhos para todos verem.

[``PIXE  /** AAAAKIIIIIIIII !!!!!!!!!!!!!!](https://marsgristian.github.io/Muro-de-Grafite/)

## Funcionalidades

- 🎨 Desenho colaborativo em tempo real
- 🖌️ Ferramentas de desenho (pincel, borracha, navegação)
- 🌈 Seletor de cores
- 📱 Responsivo para desktop e mobile
- 🔄 Publicação e carregamento automático do mural
- 💾 Integração com Firebase Realtime Database

## Configuração

### 1. Clone o repositório
```bash
git clone https://github.com/marsgristian/Muro-de-Grafite.git
cd Muro-de-Grafite/muro_de_grafite
```

### 2. Configure o Firebase
1. Copie o arquivo de exemplo:
   ```bash
   cp lib/config/firebase_config.example.dart lib/config/firebase_config.dart
   ```

2. Edite `lib/config/firebase_config.dart` e adicione suas credenciais do Firebase:
   ```dart
   static const FirebaseOptions options = FirebaseOptions(
     apiKey: "YOUR_API_KEY",
     authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
     // ... outras credenciais
   );
   ```

### 3. Adicione a imagem de fundo
Coloque sua imagem de parede urbana em `assets/wall.jpg`

### 4. Instale as dependências
```bash
flutter pub get
```

### 5. Execute o projeto
```bash
flutter run -d chrome
```

## Deploy

### Build para produção
```bash
flutter build web
```

### Deploy no GitHub Pages
1. Copie o conteúdo de `build/web` para o branch `gh-pages`
2. Configure o GitHub Pages para usar o branch `gh-pages`

## Tecnologias

- Flutter Web
- Firebase Realtime Database
- Provider (Gerenciamento de Estado)
- Flutter Color Picker

## Licença

[Grafite](https://creativecommons.org) © 2025 by [Cristian](https://creativecommons.org) is licensed under [Creative Commons Attribution-NonCommercial 4.0 International](https://creativecommons.org/licenses/by-nc/4.0/)![](https://mirrors.creativecommons.org/presskit/icons/cc.svg)![](https://mirrors.creativecommons.org/presskit/icons/by.svg)![](https://mirrors.creativecommons.org/presskit/icons/nc.svg)

Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
