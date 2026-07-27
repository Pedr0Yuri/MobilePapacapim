import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Ajuda e Sobre', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 22)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              Text(
                'Sobre o Papacapim',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: 12),
              Text(
                'O Papacapim é uma rede social inovadora focada na simplicidade e em conectar as pessoas ao redor do mundo. Feito com amor e Flutter.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
              ),
              SizedBox(height: 32),
              Text(
                'Ajuda',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: 12),
              Text(
                'Caso precise de suporte, entre em contato através do nosso e-mail de atendimento: suporte@papacapim.com',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
              ),
              SizedBox(height: 48),
              Center(
                child: Text(
                  'Versão 1.0.0',
                  style: TextStyle(fontSize: 14, color: AppColors.inputBorder, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
