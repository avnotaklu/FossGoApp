import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/counry_codes.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/homepage/matchmaking_page.dart';
import 'package:go/modules/homepage/profile/edit_profile_provider.dart';
import 'package:go/services/api.dart';
import 'package:go/widgets/app_error_snackbar.dart';
import 'package:go/widgets/basic_alert.dart';
import 'package:go/widgets/my_text_form_field.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final key = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  String? nationality;

  void setup({String? fName, String? email, String? bio, String? nationality}) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      nameController.text = fName ?? "";
      emailController.text = email ?? "";
      bioController.text = bio ?? "";
      setNationality(nationality);
    });
  }

  void setNationality(String? nat) {
    setState(() {
      nationality = nat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ChangeNotifierProvider<EditProfileProvider>(
        create: (context) => EditProfileProvider(
          auth: context.read<AuthProvider>(),
          api: Api(),
        )..setup(setup),
        builder: (context, child) {
          return Consumer<EditProfileProvider>(builder: (context, pro, child) {
            return Form(
              key: key,
              autovalidateMode: AutovalidateMode.always,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Edit your profile",
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineLarge,
                        ),
                        SizedBox(height: context.height * 0.1),
                        MyTextFormField(
                          controller: emailController,
                          hintText: 'Email',
                          enabled: false,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const BasicDialog(
                                  title: "Email Services not available",
                                  content: "Planning to do later",
                                );
                              },
                            );
                          },
                          validator: pro.emailValidator().flutterFieldValidate,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        MyTextFormField(
                          controller: nameController,
                          hintText: 'Name',
                          validator: pro.fullNameValidator().flutterFieldValidate,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        MyTextFormField(
                          controller: bioController,
                          hintText: 'Bio',
                          validator: pro.bioValidator().flutterFieldValidate,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Nationality",
                                  style: context.textTheme.titleLarge,
                                ),
                                WidgetSpan(
                                    child: IconButton(
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all(
                                            const EdgeInsets.all(0),
                                          ),
                                        ),
                                        onPressed: () {
                                          showPicker(
                                            setNationality,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.flag_circle,
                                          size: 25,
                                        )),
                                    baseline: TextBaseline.ideographic,
                                    alignment: PlaceholderAlignment.baseline),
                    
                                WidgetSpan(
                                    child: SizedBox(width: 20,),
                                    baseline: TextBaseline.alphabetic,
                                    alignment: PlaceholderAlignment.baseline),
                                if (nationality != null)
                                  TextSpan(
                                    text: "Current: ${countryCodesMap[nationality]!}",
                                    style: context.textTheme.labelSmall,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        PrimaryButton(
                            onPressed: () async {
                              var res = await pro.saveProfile(
                                nameController.text.trim(),
                                bioController.text.trim(),
                                nationality ?? "",
                              );
                    
                              if (context.mounted) {
                                showAppErrorSnackBar(context, res,
                                    successPhrase: "Profile Successfully Updated");
                              }
                            },
                            text: "Save")
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  void showPicker(void Function(String) onSelect) {
    showCountryPicker(
      context: context,
      onSelect: (v) => onSelect(v.countryCode),
    );
  }
}
