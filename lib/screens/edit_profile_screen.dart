import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import '../data/profile_store.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

// Tela de Editar Perfil. (Onde editamos a foto, nome, bio etc)
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileStore _profileStore = ProfileStore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _profileStore.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _profileStore.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() => setState(() {});

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        // Redimensionamento via plugin falha em alguns ambientes Web.
        maxWidth: kIsWeb ? null : 1200,
        maxHeight: kIsWeb ? null : 1200,
        imageQuality: kIsWeb ? null : 88,
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      _profileStore.setLocalProfileImageBytes(bytes);
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
    final base = isCamera
        ? 'Não foi possível abrir a câmera.'
        : 'Não foi possível abrir a galeria.';
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

  // Função que abre uma "gaveta" de baixo para cima (BottomSheet) perguntando de onde quer pegar a foto.
  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card, // Fundo bege claro
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ocupa só o espaço necessário para não tampar a tela toda
              children: [
                // "Puxador" visual cinza no topo
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Alterar foto de perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 24),
                
                // Botão de Galeria
                _PhotoOption(
                  icon: Icons.photo_library_outlined,
                  iconBg: AppColors.accent.withValues(alpha: 0.1),
                  iconColor: AppColors.accent,
                  title: 'Selecionar da Galeria',
                  subtitle: 'Escolha uma foto do seu dispositivo',
                  onTap: () {
                    // No Web o seletor precisa ser aberto ainda no gesto do toque;
                    // fechar o sheet antes quebra a abertura da galeria/câmera no Chrome.
                    _pickProfileImage(ImageSource.gallery).whenComplete(() {
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Botão de Câmera
                _PhotoOption(
                  icon: Icons.camera_alt_outlined,
                  iconBg: AppColors.cta.withValues(alpha: 0.1),
                  iconColor: AppColors.cta,
                  title: 'Tirar Foto',
                  subtitle: 'Use a câmera do seu dispositivo',
                  onTap: () {
                    _pickProfileImage(ImageSource.camera).whenComplete(() {
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    });
                  },
                ),
                const SizedBox(height: 12),
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
        // Botão voltar customizado
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 22),
        ),
        centerTitle: true, // Centraliza o título no Android e iOS
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView( // Permite rolar quando o teclado abre
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Column(
              children: [
                const SizedBox(height: 8),
                
                // Stack sobrepõe o botão de câmera na foto de perfil
                Stack(
                  alignment: Alignment.bottomRight, // Alinha o botão de câmera no canto inferior direito da foto
                  children: [
                    // Círculo com a foto atual
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cta, width: 3), // Borda Laranja
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cta.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _buildProfileAvatar(),
                    ),
                    // Pequeno botão de câmera sobreposto no canto
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: AppColors.cta, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gustavo Just',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  '@gustavo',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                
                // Botão para trocar foto (Abre a BottomSheet criada na função acima)
                AppButton(
                  label: 'Alterar foto de perfil',
                  variant: AppButtonVariant.outlined,
                  icon: Icons.image_outlined,
                  onPressed: () => _showPhotoOptions(context),
                ),
                const SizedBox(height: 36),
                
                // Campos de edição. Usamos initialValue para já vir preenchido.
                const AppTextField(
                  label: 'Nome',
                  icon: Icons.badge_outlined,
                  initialValue: 'Gustavo Just',
                ),
                const SizedBox(height: 18),
                const AppTextField(
                  label: 'Bio',
                  icon: Icons.edit_note_rounded,
                  maxLines: 3, // Bio precisa de mais espaço
                  initialValue: 'Lorem ipsum dolor sit amet',
                ),
                const SizedBox(height: 18),
                const AppTextField(
                  label: 'Localização',
                  icon: Icons.location_on_outlined,
                  initialValue: 'Recife, PE',
                ),
                const SizedBox(height: 18),
                const AppTextField(
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  obscureText: true, // Esconde os caracteres
                  initialValue: 'senha123',
                ),
                const SizedBox(height: 36),
                
                // Botão Salvar
                AppButton(
                  label: 'Salvar Alterações',
                  onPressed: () {
                    // SnackBar exibe uma notificação verde (accent) rápida no rodapé
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Alterações salvas com sucesso!'),
                        backgroundColor: AppColors.accent,
                        behavior: SnackBarBehavior.floating, // Flutua sobre o bottom do teclado/tela
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Botões daquela janelinha que abre para escolher foto (Galeria/Câmera)
class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
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
