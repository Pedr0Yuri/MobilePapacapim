import 'package:flutter/material.dart';
import 'app_colors.dart';

// Este widget desenha o logotipo do passarinho usando curvas (Paths).
// Foi criado usando CustomPainter ao invés de uma imagem (.png/.svg) para ser super leve,
// não perder qualidade em telas diferentes e permitir mudar a cor dinamicamente.
class BirdLogo extends StatelessWidget {
  final double size; // Tamanho do logo
  final Color color; // Cor principal

  const BirdLogo({
    super.key,
    this.size = 48,
    this.color = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    // CustomPaint é o widget do Flutter que permite desenhar formas vetoriais na tela.
    return CustomPaint(
      size: Size(size, size), // Define a área em que o pintor pode trabalhar.
      painter: _BirdPainter(color: color), // O pintor (nossa classe abaixo) que fará o desenho.
    );
  }
}

// A classe que estende CustomPainter contém as instruções matemáticas para desenhar.
class _BirdPainter extends CustomPainter {
  final Color color;
  _BirdPainter({required this.color});

  // Método onde a mágica acontece. 'canvas' é a tela, 'size' é o tamanho disponível.
  @override
  void paint(Canvas canvas, Size size) {
    // 'Paint' é como se fosse o pincel. Definimos a cor e o estilo (preenchimento ou borda).
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Desenhando o corpo do pássaro usando Path (Caminho).
    // moveTo: move o pincel sem desenhar.
    // cubicTo: desenha uma curva Bezier cúbica (usa 2 pontos de controle e 1 ponto final para fazer curvas suaves).
    final body = Path()
      ..moveTo(w * 0.50, h * 0.30)
      ..cubicTo(w * 0.30, h * 0.20, w * 0.10, h * 0.35, w * 0.08, h * 0.55)
      ..cubicTo(w * 0.06, h * 0.72, w * 0.20, h * 0.80, w * 0.38, h * 0.78)
      ..cubicTo(w * 0.45, h * 0.90, w * 0.40, h * 0.96, w * 0.32, h * 0.98)
      ..cubicTo(w * 0.44, h * 0.97, w * 0.56, h * 0.90, w * 0.58, h * 0.78)
      ..cubicTo(w * 0.75, h * 0.82, w * 0.92, h * 0.72, w * 0.92, h * 0.56)
      ..cubicTo(w * 0.92, h * 0.40, w * 0.78, h * 0.28, w * 0.62, h * 0.28)
      ..cubicTo(w * 0.60, h * 0.18, w * 0.55, h * 0.10, w * 0.50, h * 0.10)
      ..cubicTo(w * 0.45, h * 0.10, w * 0.42, h * 0.18, w * 0.50, h * 0.30)
      ..close(); // Fecha o caminho de volta ao ponto inicial.

    canvas.drawPath(body, paint); // Desenha a forma sólida do corpo.

    // Desenhando a asa com um caminho diferente.
    final wing = Path()
      ..moveTo(w * 0.50, h * 0.42)
      ..cubicTo(w * 0.38, h * 0.36, w * 0.22, h * 0.40, w * 0.18, h * 0.54)
      ..cubicTo(w * 0.28, h * 0.48, w * 0.42, h * 0.46, w * 0.50, h * 0.52)
      ..close();

    // A asa é pintada com a mesma cor, mas com 30% de opacidade (alpha 0.3), criando um efeito de sombra/sobreposição.
    canvas.drawPath(wing, Paint()..color = color.withValues(alpha: 0.3)..style = PaintingStyle.fill);

    // Desenhando o olho do pássaro como um simples círculo.
    final eyePaint = Paint()..color = AppColors.primary..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.52, h * 0.22), w * 0.04, eyePaint);
  }

  // Define se o desenho deve ser refeito caso os parâmetros mudem. 
  // Como o nosso logo é fixo e não se anima, retornamos false para poupar processamento.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
