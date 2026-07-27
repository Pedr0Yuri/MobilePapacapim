import 'package:flutter/material.dart';

// Centraliza as cores do app para manter o padrão visual.
class AppColors {
  static const Color primary = Color(
    0xFF4A3428,
  ); // Marrom escuro: Cor base principal (ex: AppBar, nav bar)
  static const Color secondary = Color(
    0xFF6E4C3A,
  ); // Marrom médio: Usado em avatares, gradientes e acentos suaves
  static const Color background = Color(
    0xFFF7F3EB,
  ); // Bege super claro: Cor de fundo de todas as telas (Scaffold)
  static const Color card = Color(
    0xFFFFFDF8,
  ); // Branco pastel: Fundo de cards, modais e postagens
  static const Color accent = Color(
    0xFF708238,
  ); // Verde musgo: Destaque secundário (ex: aba selecionada, ícones ativos)
  static const Color cta = Color(
    0xFFD97A2B,
  ); // Laranja (Call to Action): Botões principais e botões flutuantes (FAB)
  static const Color textPrimary = Color(
    0xFF2E2E2E,
  ); // Cinza escuro: Cor principal para títulos e textos de leitura
  static const Color textSecondary = Color(
    0xFF777777,
  ); // Cinza médio: Textos auxiliares (@handle, hora, dicas)
  static const Color white = Color(
    0xFFFFFFFF,
  ); // Branco puro: Textos em cima de fundos escuros (ex: botões CTA)
  static const Color inputBg = Color(
    0xFFF2EDE5,
  ); // Bege claro: Cor de preenchimento dos campos de texto (TextField)
  static const Color inputBorder = Color(
    0xFFD9D3CA,
  ); // Bege escuro: Borda dos campos de texto inativos
  static const Color danger = Color(
    0xFFDC2626,
  ); // Vermelho: Ações destrutivas (ex: Excluir postagem)
  static const Color beige = Color(
    0xFFE8DFD2,
  ); // Bege médio: Textos auxiliares em fundos escuros (ex: drawer e navbar inativo)
  static const Color likeRed = Color(
    0xFFE74C3C,
  ); // Vermelho vibrante: Usado especificamente para o coraçãozinho de "Curtir"
}
