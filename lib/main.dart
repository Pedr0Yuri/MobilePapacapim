import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pacote usado para carregar fontes do Google (neste caso, Inter).
import 'core/app_colors.dart'; // Arquivo central com as cores do aplicativo.
import 'screens/login_screen.dart'; // Telas do nosso app
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/settings_screen.dart';

// Ponto de entrada (entry point) da aplicação Flutter.
// Sem o 'main', o Flutter não sabe por onde começar a rodar o app.
void main() {
  // runApp "infla" o widget raiz do app (PapacapimApp) e o anexa à tela.
  runApp(const PapacapimApp());
}

// Widget principal que configura o aplicativo. 
// É StatelessWidget porque a configuração global (tema, rotas) não muda seu estado interno após iniciar.
class PapacapimApp extends StatelessWidget {
  const PapacapimApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos a fonte padrão do aplicativo como 'Inter'.
    // Usamos o GoogleFonts para não precisar baixar e linkar os arquivos da fonte manualmente.
    final textTheme = GoogleFonts.interTextTheme(
      Theme.of(context).textTheme,
    );

    // O MaterialApp é o widget pai que fornece a base visual do Material Design (navegação, tema, etc).
    // Se removermos o MaterialApp e retornarmos direto um Text, a tela ficará preta com o texto em vermelho e amarelo (estilo de erro/sem estilo).
    return MaterialApp(
      title: 'Papacapim', // Título que aparece no gerenciador de tarefas do celular.
      debugShowCheckedModeBanner: false, // Remove a faixa "DEBUG" no canto superior direito.

      // ThemeData é onde definimos a identidade visual (Cores, Fontes, Estilos de botões).
      // Isso evita ter que passar cores manualmente em cada widget do app.
      theme: ThemeData(
        // ColorScheme define as cores principais seguindo o padrão do Material 3.
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background, // Cor de fundo padrão de todas as telas (Scaffolds).
        
        // Aplica a nossa fonte 'Inter' e define a cor principal dos textos.
        textTheme: textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        
        // Configuração padrão da AppBar (Barra superior) para não precisar repetir em cada tela.
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0, // Remove a sombra embaixo da AppBar para um visual mais "flat/limpo".
          iconTheme: const IconThemeData(color: AppColors.beige), // Cor dos ícones, como o botão de voltar.
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Estilo padrão dos "SnackBars" (aquelas mensagens pop-up rápidas na parte inferior).
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating, // Flutua sobre a tela ao invés de grudar no fundo.
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Bordas arredondadas.
        ),
        useMaterial3: true, // Habilita o design mais recente e moderno do Flutter (Material Design 3).
      ),
      
      // Define a rota inicial do app. Quando abre, vai direto para a tela de Login.
      initialRoute: '/login',
      
      // 'routes' é um mapa que associa um nome (string) a uma Tela (Widget).
      // Isso permite navegar usando Navigator.pushNamed(context, '/home'), que é muito mais limpo.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
