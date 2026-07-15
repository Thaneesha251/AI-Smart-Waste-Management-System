import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass/glass_widgets.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/gradients.dart';
import '../../models/user_model.dart';
import '../../core/localization/app_localization.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _areaController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.fullName);
    _phoneController = TextEditingController(text: user?.phone);
    _areaController = TextEditingController(text: user?.area);
    _addressController = TextEditingController(text: user?.address);
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.user!;
      
      final updatedUser = user.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        area: _areaController.text.trim(),
        address: _addressController.text.trim(),
      );

      await auth.updateProfile(updatedUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully!'), backgroundColor: AppColors.citizenPrimary),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(context.tr('edit_profile'), style: AppTypography.heading(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: context.tr('full_name'), prefixIcon: const Icon(Icons.person_outline)),
                        validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(labelText: context.tr('phone'), prefixIcon: const Icon(Icons.phone_outlined)),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.length < 10 ? 'Enter valid phone' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _areaController,
                        decoration: const InputDecoration(labelText: 'Area', prefixIcon: Icon(Icons.location_city_outlined)),
                        validator: (v) => v!.isEmpty ? 'Enter your area' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Detailed Address', prefixIcon: Icon(Icons.home_outlined)),
                        validator: (v) => v!.isEmpty ? 'Enter your address' : null,
                      ),
                      const SizedBox(height: 32),
                      GlassButton(
                        text: 'SAVE CHANGES',
                        gradient: AppGradients.citizen,
                        isLoading: Provider.of<AuthProvider>(context).isLoading,
                        onPressed: _handleSave,
                      ),
                    ],
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
