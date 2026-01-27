import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../models/address.dart';
import '../../routing/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/address_map_picker.dart';
import '../../widgets/outlined_text_field.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await AppStateScope.of(context).loadCustomerAddresses();
    });
  }

  Future<void> _openAddAddress() async {
    final payload = await showDialog<AddressPayload>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => const _AddAddressDialog(),
    );
    if (payload == null) return;
    if (!mounted) return;
    try {
      await AppStateScope.of(context).addAddress(payload);
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF8F7F3);

    final state = AppStateScope.of(context);
    final addresses = state.addresses;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: AppLocalizations.of(context)!.myAddressesTitle,
              showCartButton: false,
            ),
            Expanded(
              child: Container(
                color: pageBg,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                        itemCount: addresses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.label,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        address.addressLine,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _openAddAddress,
                            child: Text(
                              AppLocalizations.of(context)!.addAddress,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: AppBottomTab.profile,
        onMenuTap: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        onProfileTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.profile),
      ),
    );
  }
}

class _AddAddressDialog extends StatelessWidget {
  const _AddAddressDialog();

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    final commentController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.newAddressTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              width: double.infinity,
              child: AddressMapPicker(
                addressController: addressController,
                languageCode: Localizations.localeOf(context).languageCode,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedTextField(
              hintText: AppLocalizations.of(context)!.addressTitleHint,
              controller: titleController,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedTextField(
              hintText: AppLocalizations.of(context)!.addressHint,
              controller: addressController,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedTextField(
              hintText: AppLocalizations.of(context)!.commentHint,
              controller: commentController,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final title = titleController.text.trim();
                  final address = addressController.text.trim();
                  if (title.isEmpty || address.isEmpty) {
                    Navigator.of(context).pop();
                    return;
                  }
                  Navigator.of(context).pop(
                    AddressPayload(
                      label: title,
                      addressLine: address,
                      comment: commentController.text.trim().isEmpty
                          ? null
                          : commentController.text.trim(),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
