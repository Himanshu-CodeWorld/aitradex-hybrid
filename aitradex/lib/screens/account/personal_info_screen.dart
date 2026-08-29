import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _primary = Color(0xff18C48F);

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _fullNameController =
  TextEditingController(text: 'Andrew Ainsley');
  final _phoneController =
  TextEditingController(text: '+1-300-555-0399');
  final _emailController =
  TextEditingController(text: 'andrew.ainsley@yourdomain.com');
  final _dobController =
  TextEditingController(text: '12/27/1995');
  final _addressController =
  TextEditingController(text: '3517 W. Gray Street, New York');

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 28),
                    _buildProfilePhoto(),
                    const SizedBox(height: 22),
                    const Divider(
                      height: 1,
                      thickness: .8,
                      color: Color(0xffE6E6E6),
                    ),
                    const SizedBox(height: 26),

                    _buildField(
                      label: 'Full Name',
                      controller: _fullNameController,
                    ),

                    _buildField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    _buildField(
                      label: 'Date of Birth',
                      controller: _dobController,
                      readOnly: true,
                      suffixIcon: Icons.calendar_month_outlined,
                      onSuffixTap: _selectDate,
                    ),

                    _buildField(
                      label: 'Street Address',
                      controller: _addressController,
                      keyboardType: TextInputType.streetAddress,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(30),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 28,
                color: Color(0xff181818),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Personal Info',
          style: GoogleFonts.poppins(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: const Color(0xff171717),
            letterSpacing: -.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffdddddd),
            ),
            clipBehavior: Clip.antiAlias,
            child: const Icon(
              Icons.person_rounded,
              size: 88,
              color: Color(0xff858585),
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff171717),
            ),
          ),
          const SizedBox(height: 13),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: const Color(0xff171717),
              letterSpacing: -.4,
            ),
            cursorColor: _primary,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.only(bottom: 12),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _primary,
                  width: 1,
                ),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _primary,
                  width: 1,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _primary,
                  width: 1.2,
                ),
              ),
              suffixIcon: suffixIcon == null
                  ? null
                  : InkWell(
                onTap: onSuffixTap,
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  suffixIcon,
                  color: _primary,
                  size: 23,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final initialDate = DateTime(1995, 12, 27);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xff171717),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    final month = selected.month.toString().padLeft(2, '0');
    final day = selected.day.toString().padLeft(2, '0');

    setState(() {
      _dobController.text = '$month/$day/${selected.year}';
    });
  }
}
