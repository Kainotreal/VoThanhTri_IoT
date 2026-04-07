import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

class CountryOriginScreen extends StatefulWidget {
  const CountryOriginScreen({super.key});

  @override
  State<CountryOriginScreen> createState() => _CountryOriginScreenState();
}

class _CountryOriginScreenState extends State<CountryOriginScreen> {
  String _selectedCountryName = "";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> _countries = [
    {'name': 'Afghanistan', 'flag': '🇦🇫'}, {'name': 'Albania', 'flag': '🇦🇱'}, {'name': 'Algeria', 'flag': '🇩🇿'},
    {'name': 'Andorra', 'flag': '🇦🇩'}, {'name': 'Angola', 'flag': '🇦🇴'}, {'name': 'Antigua and Barbuda', 'flag': '🇦🇬'},
    {'name': 'Argentina', 'flag': '🇦🇷'}, {'name': 'Armenia', 'flag': '🇦🇲'}, {'name': 'Australia', 'flag': '🇦🇺'},
    {'name': 'Austria', 'flag': '🇦🇹'}, {'name': 'Azerbaijan', 'flag': '🇦🇿'}, {'name': 'Bahamas', 'flag': '🇧🇸'},
    {'name': 'Bahrain', 'flag': '🇧🇭'}, {'name': 'Bangladesh', 'flag': '🇧🇩'}, {'name': 'Barbados', 'flag': '🇧🇧'},
    {'name': 'Belarus', 'flag': '🇧🇾'}, {'name': 'Belgium', 'flag': '🇧🇪'}, {'name': 'Belize', 'flag': '🇧🇿'},
    {'name': 'Benin', 'flag': '🇧🇯'}, {'name': 'Bhutan', 'flag': '🇧🇹'}, {'name': 'Bolivia', 'flag': '🇧🇴'},
    {'name': 'Bosnia and Herzegovina', 'flag': '🇧🇦'}, {'name': 'Botswana', 'flag': '🇧🇼'}, {'name': 'Brazil', 'flag': '🇧🇷'},
    {'name': 'Brunei', 'flag': '🇧🇳'}, {'name': 'Bulgaria', 'flag': '🇧🇬'}, {'name': 'Burkina Faso', 'flag': '🇧🇫'},
    {'name': 'Burundi', 'flag': '🇧🇮'}, {'name': 'Cabo Verde', 'flag': '🇨🇻'}, {'name': 'Cambodia', 'flag': '🇰🇭'},
    {'name': 'Cameroon', 'flag': '🇨🇲'}, {'name': 'Canada', 'flag': '🇨🇦'}, {'name': 'Central African Republic', 'flag': '🇨🇫'},
    {'name': 'Chad', 'flag': '🇹🇩'}, {'name': 'Chile', 'flag': '🇨🇱'}, {'name': 'China', 'flag': '🇨🇳'},
    {'name': 'Colombia', 'flag': '🇨🇴'}, {'name': 'Comoros', 'flag': '🇰🇲'}, {'name': 'Congo', 'flag': '🇨🇬'},
    {'name': 'Costa Rica', 'flag': '🇨🇷'}, {'name': 'Croatia', 'flag': '🇭🇷'}, {'name': 'Cuba', 'flag': '🇨🇺'},
    {'name': 'Cyprus', 'flag': '🇨🇾'}, {'name': 'Czech Republic', 'flag': '🇨🇿'}, {'name': 'Denmark', 'flag': '🇩🇰'},
    {'name': 'Djibouti', 'flag': '🇩🇯'}, {'name': 'Dominica', 'flag': '🇩🇲'}, {'name': 'Dominican Republic', 'flag': '🇩🇴'},
    {'name': 'Ecuador', 'flag': '🇪🇨'}, {'name': 'Egypt', 'flag': '🇪🇬'}, {'name': 'El Salvador', 'flag': '🇸🇻'},
    {'name': 'Equatorial Guinea', 'flag': '🇬🇶'}, {'name': 'Eritrea', 'flag': '🇪🇷'}, {'name': 'Estonia', 'flag': '🇪🇪'},
    {'name': 'Eswatini', 'flag': '🇸🇿'}, {'name': 'Ethiopia', 'flag': '🇪🇹'}, {'name': 'Fiji', 'flag': '🇫🇯'},
    {'name': 'Finland', 'flag': '🇫🇮'}, {'name': 'France', 'flag': '🇫🇷'}, {'name': 'Gabon', 'flag': '🇬🇦'},
    {'name': 'Gambia', 'flag': '🇬🇲'}, {'name': 'Georgia', 'flag': '🇬🇪'}, {'name': 'Germany', 'flag': '🇩🇪'},
    {'name': 'Ghana', 'flag': '🇬🇭'}, {'name': 'Greece', 'flag': '🇬🇷'}, {'name': 'Grenada', 'flag': '🇬🇩'},
    {'name': 'Guatemala', 'flag': '🇬🇹'}, {'name': 'Guinea', 'flag': '🇬🇳'}, {'name': 'Guinea-Bissau', 'flag': '🇬🇼'},
    {'name': 'Guyana', 'flag': '🇬🇾'}, {'name': 'Haiti', 'flag': '🇭🇹'}, {'name': 'Honduras', 'flag': '🇭🇳'},
    {'name': 'Hungary', 'flag': '🇭🇺'}, {'name': 'Iceland', 'flag': '🇮🇸'}, {'name': 'India', 'flag': '🇮🇳'},
    {'name': 'Indonesia', 'flag': '🇮🇩'}, {'name': 'Iran', 'flag': '🇮🇷'}, {'name': 'Iraq', 'flag': '🇮🇶'},
    {'name': 'Ireland', 'flag': '🇮🇪'}, {'name': 'Israel', 'flag': '🇮🇱'}, {'name': 'Italy', 'flag': '🇮🇹'},
    {'name': 'Jamaica', 'flag': '🇯🇲'}, {'name': 'Japan', 'flag': '🇯🇵'}, {'name': 'Jordan', 'flag': '🇯🇴'},
    {'name': 'Kazakhstan', 'flag': '🇰🇿'}, {'name': 'Kenya', 'flag': '🇰🇪'}, {'name': 'Kiribati', 'flag': '🇰🇮'},
    {'name': 'Korea, North', 'flag': '🇰🇵'}, {'name': 'Korea, South', 'flag': '🇰🇷'}, {'name': 'Kuwait', 'flag': '🇰🇼'},
    {'name': 'Kyrgyzstan', 'flag': '🇰🇬'}, {'name': 'Laos', 'flag': '🇱🇦'}, {'name': 'Latvia', 'flag': '🇱🇻'},
    {'name': 'Lebanon', 'flag': '🇱🇧'}, {'name': 'Lesotho', 'flag': '🇱🇸'}, {'name': 'Liberia', 'flag': '🇱🇷'},
    {'name': 'Libya', 'flag': '🇱🇾'}, {'name': 'Liechtenstein', 'flag': '🇱🇮'}, {'name': 'Lithuania', 'flag': '🇱🇹'},
    {'name': 'Luxembourg', 'flag': '🇱🇺'}, {'name': 'Madagascar', 'flag': '🇲🇬'}, {'name': 'Malawi', 'flag': '🇲🇼'},
    {'name': 'Malaysia', 'flag': '🇲🇾'}, {'name': 'Maldives', 'flag': '🇲🇻'}, {'name': 'Mali', 'flag': '🇲🇱'},
    {'name': 'Malta', 'flag': '🇲🇹'}, {'name': 'Marshall Islands', 'flag': '🇲🇭'}, {'name': 'Mauritania', 'flag': '🇲🇷'},
    {'name': 'Mauritius', 'flag': '🇲🇺'}, {'name': 'Mexico', 'flag': '🇲🇽'}, {'name': 'Micronesia', 'flag': '🇫🇲'},
    {'name': 'Moldova', 'flag': '🇲🇩'}, {'name': 'Monaco', 'flag': '🇲🇨'}, {'name': 'Mongolia', 'flag': '🇲🇳'},
    {'name': 'Montenegro', 'flag': '🇲🇪'}, {'name': 'Morocco', 'flag': '🇲🇦'}, {'name': 'Mozambique', 'flag': '🇲🇿'},
    {'name': 'Myanmar', 'flag': '🇲🇲'}, {'name': 'Namibia', 'flag': '🇳🇦'}, {'name': 'Nauru', 'flag': '🇳🇷'},
    {'name': 'Nepal', 'flag': '🇳🇵'}, {'name': 'Netherlands', 'flag': '🇳🇱'}, {'name': 'New Zealand', 'flag': '🇳🇿'},
    {'name': 'Nicaragua', 'flag': '🇳🇮'}, {'name': 'Niger', 'flag': '🇳🇪'}, {'name': 'Nigeria', 'flag': '🇳🇬'},
    {'name': 'North Macedonia', 'flag': '🇲🇰'}, {'name': 'Norway', 'flag': '🇳🇴'}, {'name': 'Oman', 'flag': '🇴🇲'},
    {'name': 'Pakistan', 'flag': '🇵🇰'}, {'name': 'Palau', 'flag': '🇵🇼'}, {'name': 'Panama', 'flag': '🇵🇦'},
    {'name': 'Papua New Guinea', 'flag': '🇵🇬'}, {'name': 'Paraguay', 'flag': '🇵🇾'}, {'name': 'Peru', 'flag': '🇵🇪'},
    {'name': 'Philippines', 'flag': '🇵🇭'}, {'name': 'Poland', 'flag': '🇵🇱'}, {'name': 'Portugal', 'flag': '🇵🇹'},
    {'name': 'Qatar', 'flag': '🇶🇦'}, {'name': 'Romania', 'flag': '🇷🇴'}, {'name': 'Russia', 'flag': '🇷🇺'},
    {'name': 'Rwanda', 'flag': '🇷🇼'}, {'name': 'Saint Kitts and Nevis', 'flag': '🇰🇳'}, {'name': 'Saint Lucia', 'flag': '🇱🇨'},
    {'name': 'Samoa', 'flag': '🇼🇸'}, {'name': 'San Marino', 'flag': '🇸🇲'}, {'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'name': 'Senegal', 'flag': '🇸🇳'}, {'name': 'Serbia', 'flag': '🇷🇸'}, {'name': 'Seychelles', 'flag': '🇸🇨'},
    {'name': 'Sierra Leone', 'flag': '🇸🇱'}, {'name': 'Singapore', 'flag': '🇸🇬'}, {'name': 'Slovakia', 'flag': '🇸🇰'},
    {'name': 'Slovenia', 'flag': '🇸🇮'}, {'name': 'Solomon Islands', 'flag': '🇸🇧'}, {'name': 'Somalia', 'flag': '🇸🇴'},
    {'name': 'South Africa', 'flag': '🇿🇦'}, {'name': 'South Sudan', 'flag': '🇸🇸'}, {'name': 'Spain', 'flag': '🇪🇸'},
    {'name': 'Sri Lanka', 'flag': '🇱🇰'}, {'name': 'Sudan', 'flag': '🇸🇩'}, {'name': 'Suriname', 'flag': '🇸🇷'},
    {'name': 'Sweden', 'flag': '🇸🇪'}, {'name': 'Switzerland', 'flag': '🇨🇭'}, {'name': 'Syria', 'flag': '🇸🇾'},
    {'name': 'Taiwan', 'flag': '🇹🇼'}, {'name': 'Tajikistan', 'flag': '🇹🇯'}, {'name': 'Tanzania', 'flag': '🇹🇿'},
    {'name': 'Thailand', 'flag': '🇹🇭'}, {'name': 'Timor-Leste', 'flag': '🇹🇱'}, {'name': 'Togo', 'flag': '🇹🇬'},
    {'name': 'Tonga', 'flag': '🇹🇴'}, {'name': 'Trinidad and Tobago', 'flag': '🇹🇹'}, {'name': 'Tunisia', 'flag': '🇹🇳'},
    {'name': 'Turkey', 'flag': '🇹🇷'}, {'name': 'Turkmenistan', 'flag': '🇹🇲'}, {'name': 'Tuvalu', 'flag': '🇹🇻'},
    {'name': 'Uganda', 'flag': '🇺🇬'}, {'name': 'Ukraine', 'flag': '🇺🇦'}, {'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    {'name': 'United Kingdom', 'flag': '🇬🇧'}, {'name': 'United States', 'flag': '🇺🇸'}, {'name': 'Uruguay', 'flag': '🇺🇾'},
    {'name': 'Uzbekistan', 'flag': '🇺🇿'}, {'name': 'Vanuatu', 'flag': '🇻🇺'}, {'name': 'Vatican City', 'flag': '🇻🇦'},
    {'name': 'Venezuela', 'flag': '🇻🇪'}, {'name': 'Vietnam', 'flag': '🇻🇳'}, {'name': 'Yemen', 'flag': '🇾🇪'},
    {'name': 'Zambia', 'flag': '🇿🇲'}, {'name': 'Zimbabwe', 'flag': '🇿🇼'},
  ];

  List<Map<String, String>> get _filteredCountries {
    if (_searchQuery.isEmpty) return _countries;
    return _countries
        .where((country) => country['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onContinue() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Processing...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
        context.push(AppRoutes.homeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredCountries;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar (1/4)
              Row(
                children: [
                  const SizedBox(width: 48), // Balancing back button
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.25,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "1 / 4",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                    fontFamily: 'Inter',
                  ),
                  children: [
                    const TextSpan(text: "Select "),
                    TextSpan(
                      text: "Country",
                      style: TextStyle(color: AppColors.primary),
                    ),
                    const TextSpan(text: " of Origin"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Let's start by selecting the country where your smart haven resides.",
                style: TextStyle(color: Color(0xFF757575), fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search Country...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFBDBDBD), size: 22),
                  filled: true,
                  fillColor: const Color(0xFFFBFBFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: displayList.isEmpty 
                  ? const Center(child: Text("No country found", style: TextStyle(color: Color(0xFF757575))))
                  : ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final country = displayList[index];
                        final isSelected = _selectedCountryName == country['name'];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => setState(() => _selectedCountryName = country['name']!),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Flag placeholder or actual emoji (image mockup uses images, but we use flags/emojis)
                                  Container(
                                    width: 40,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFEEEEEE)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(country['flag']!, style: const TextStyle(fontSize: 20)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      country['name']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: const Color(0xFF1F1F1F),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: "Skip",
                      onPressed: () => context.push(AppRoutes.homeName),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: "Continue",
                      onPressed: _selectedCountryName.isNotEmpty ? _onContinue : () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
