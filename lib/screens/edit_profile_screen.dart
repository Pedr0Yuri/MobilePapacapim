import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import '../data/profile_store.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

// Tela de Edição de Perfil com crop de imagem nativo.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileStore _profileStore = ProfileStore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey _cropKey = GlobalKey();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileStore.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _profileStore.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }


  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: kIsWeb ? null : 1200,
        maxHeight: kIsWeb ? null : 1200,
        imageQuality: kIsWeb ? null : 88,
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      _showCropMock(bytes);
    } on PlatformException catch (e) {
      if (!mounted) return;
      _showPickError(source, e.message);
    } catch (_) {
      if (!mounted) return;
      _showPickError(source, null);
    }
  }

  void _showPickError(ImageSource source, String? detail) {
    final isCamera = source == ImageSource.camera;
    final base = isCamera ? 'Não foi possível abrir a câmera.' : 'Não foi possível abrir a galeria.';
    final message = (detail != null && detail.isNotEmpty) ? '$base ($detail)' : base;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showCropMock(Uint8List bytes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Recortar Foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent, width: 2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: RepaintBoundary(
                  key: _cropKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Ajuste o tamanho e a posição.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final boundary = _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
                        if (boundary != null) {
                          final image = await boundary.toImage(pixelRatio: 3.0);
                          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                          final pngBytes = byteData?.buffer.asUint8List();
                          if (pngBytes != null) {
                            _profileStore.setLocalProfileImageBytes(pngBytes);
                          } else {
                            _profileStore.setLocalProfileImageBytes(bytes);
                          }
                        } else {
                          _profileStore.setLocalProfileImageBytes(bytes);
                        }
                      } catch (e) {
                        _profileStore.setLocalProfileImageBytes(bytes);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cta,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Concluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                const Text('Alterar foto de perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 24),
                _PhotoOption(
                  icon: Icons.photo_library_outlined,
                  iconBg: AppColors.accent.withValues(alpha: 0.1),
                  iconColor: AppColors.accent,
                  title: 'Selecionar da Galeria',
                  subtitle: 'Escolha uma foto do seu dispositivo',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickProfileImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
                _PhotoOption(
                  icon: Icons.camera_alt_outlined,
                  iconBg: AppColors.cta.withValues(alpha: 0.1),
                  iconColor: AppColors.cta,
                  title: 'Tirar Foto',
                  subtitle: 'Use a câmera do seu dispositivo',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickProfileImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    final imageProvider = _profileStore.profileImageProvider;
    return CircleAvatar(
      radius: 52,
      backgroundColor: AppColors.inputBg,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(Icons.person, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Editar Perfil', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 22)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showPhotoOptions(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cta, width: 3),
                          boxShadow: [BoxShadow(color: AppColors.cta.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: _buildProfileAvatar(),
                      ),
                      Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.cta, shape: BoxShape.circle), child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Pedr0Yuri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                const Text('@Pedr0Yuri', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                const AppTextField(label: 'Nome', icon: Icons.badge_outlined, initialValue: 'Pedr0Yuri'),
                const SizedBox(height: 16),
                AppTextField(label: 'Nova Senha', icon: Icons.lock_outline, obscureText: true, controller: _passwordController),
                const SizedBox(height: 16),
                AppTextField(label: 'Confirmar Nova Senha', icon: Icons.lock_outline, obscureText: true, controller: _confirmPasswordController),
                const SizedBox(height: 36),
                AppButton(
                  label: 'Salvar Alterações',
                  onPressed: () {
                    final pass = _passwordController.text;
                    final confirm = _confirmPasswordController.text;

                    if (pass.isNotEmpty || confirm.isNotEmpty) {
                      if (pass != confirm) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.card,
                            title: const Text('Senhas não coincidem', style: TextStyle(color: AppColors.danger)),
                            content: const Text('A nova senha e a confirmação devem ser iguais.', style: TextStyle(color: AppColors.textPrimary)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK', style: TextStyle(color: AppColors.cta)),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      if (pass.length < 3) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.card,
                            title: const Text('Senha muito curta', style: TextStyle(color: AppColors.danger)),
                            content: const Text('A nova senha deve ter no mínimo 3 caracteres.', style: TextStyle(color: AppColors.textPrimary)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK', style: TextStyle(color: AppColors.cta)),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Alterações salvas com sucesso!'),
                        backgroundColor: AppColors.accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.card,
                        title: const Text('Excluir Conta', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                        content: const Text('Tem certeza? Esta ação apagará todos os seus dados e não pode ser desfeita.', style: TextStyle(color: AppColors.textPrimary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary))),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.of(context, rootNavigator: true).pushReplacementNamed('/login');
                            },
                            child: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  label: const Text('Excluir Perfil', style: TextStyle(color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoOption({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: iconColor, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inputBorder, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
