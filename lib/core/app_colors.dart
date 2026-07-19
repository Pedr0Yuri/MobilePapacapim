import 'package:flutter/material.dart';

// Classe dedicada para armazenar todas as cores do aplicativo de forma centralizada.
// Por que fazer assim? 
// Se precisarmos mudar a cor 'primary' no futuro, mudamos apenas aqui, 
// e o app inteiro (todos os botões, barras, etc) será atualizado automaticamente.
// Se usássemos 'Color(0xFF4A3428)' solto em cada arquivo, daria muito trabalho atualizar depois.
class AppColors {
  // O '0xFF' antes do código hexadecimal indica total opacidade (100% visível, 0% transparente).
  
  static const Color primary = Color(0xFF4A3428); // Cor principal (Marrom escuro). Usada na AppBar, fundo principal do Drawer.
  static const Color secondary = Color(0xFF6E4C3A); // Cor secundária (Marrom claro). Usada para detalhes e avatares.
  static const Color background = Color(0xFFF7F3EB); // Fundo geral do aplicativo (um tom areia/creme claro).
  static const Color card = Color(0xFFFFFDF8); // Fundo de cards, caixas e inputs (Branco um pouco quente).
  
  static const Color accent = Color(0xFF708238); // Cor de destaque (Verde). Usada em botões e ícones ativos.
  static const Color cta = Color(0xFFD97A2B); // Call to action (Laranja). Usada para chamar a atenção, como em algumas tags ou botões específicos.
  
  static const Color textPrimary = Color(0xFF2E2E2E); // Cor principal para os textos (Quase preto, para não forçar a vista).
  static const Color textSecondary = Color(0xFF777777); // Cor secundária para textos (Cinza, usado em subtítulos e @handles).
  
  static const Color white = Color(0xFFFFFFFF); // Branco puro.
  
  static const Color inputBg = Color(0xFFF2EDE5); // Fundo específico para os campos de texto.
  static const Color inputBorder = Color(0xFFD9D3CA); // Cor da borda dos campos de texto e divisórias (linhas).
  
  static const Color danger = Color(0xFFDC2626); // Cor de perigo (Vermelho). Usada para exclusão de conta, botões de perigo, alertas.
  static const Color beige = Color(0xFFE8DFD2); // Bege. Usado no ícone do logo, botões da AppBar, etc.
}
