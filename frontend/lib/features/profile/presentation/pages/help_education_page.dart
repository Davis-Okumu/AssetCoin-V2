
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

// =============================================================
// SHARED FAQ DATA
// =============================================================

const List<Map<String, String>> _assetCoinFaqs = [
  {
    'question': 'What is AssetCoin?',
    'answer':
        'AssetCoin is a centralized digital asset tokenization platform '
            'that allows users to submit eligible real-world assets for '
            'verification, approval and tokenization.',
  },
  {
    'question': 'How do I create an AssetCoin account?',
    'answer':
        'You can create an account using your personal details, email '
            'address and phone number. Follow the registration instructions '
            'and complete the required verification steps.',
  },
  {
    'question': 'What is KYC verification?',
    'answer':
        'KYC means Know Your Customer. It is an identity verification '
            'process used to help confirm your identity and protect the '
            'platform and its users.',
  },
  {
    'question': 'How do I submit an asset?',
    'answer':
        'Open the Assets section, select the option to submit an asset, '
            'provide the requested asset information and upload the '
            'required supporting documents.',
  },
  {
    'question': 'Can I tokenize any asset?',
    'answer':
        'No. Assets must meet AssetCoin eligibility and verification '
            'requirements. Each submission is reviewed before approval.',
  },
  {
    'question': 'What happens after I submit an asset?',
    'answer':
        'Your asset enters the review process. You can monitor its status '
            'from your submitted assets section. The review team may approve '
            'it, reject it or request additional information.',
  },
  {
    'question': 'What is the AssetCoin wallet?',
    'answer':
        'The wallet provides an overview of your available balances, '
            'token holdings and wallet transactions within AssetCoin.',
  },
  {
    'question': 'How do I buy or sell tokens?',
    'answer':
        'Visit the Trading section to explore available listings and '
            'supported trading actions. Follow the instructions displayed '
            'before confirming a transaction.',
  },
  {
    'question': 'Can I change my profile information?',
    'answer':
        'You can manage supported personal information from the Profile '
            'section. Some verified details may require additional '
            'verification before they can be changed.',
  },
  {
    'question': 'How can I protect my account?',
    'answer':
        'Use a strong password, keep your login credentials private, '
            'secure your device and never share verification codes with '
            'anyone.',
  },
];

// =============================================================
// MAIN HELP & EDUCATION PAGE
// =============================================================

class HelpEducationPage extends StatefulWidget {
  const HelpEducationPage({super.key});

  @override
  State<HelpEducationPage> createState() => _HelpEducationPageState();
}

class _HelpEducationPageState extends State<HelpEducationPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  List<Map<String, String>> get _filteredFaqs {
    if (_searchQuery.trim().isEmpty) {
      return _assetCoinFaqs.take(4).toList();
    }

    return _assetCoinFaqs.where((faq) {
      final question = faq['question']!.toLowerCase();
      final answer = faq['answer']!.toLowerCase();
      final query = _searchQuery.toLowerCase().trim();

      return question.contains(query) || answer.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSection(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Help & Education',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 22),
              _buildSearchField(),
              const SizedBox(height: 26),
              _buildSectionHeading(
                'How can we help?',
                'Explore resources to help you use AssetCoin.',
              ),
              const SizedBox(height: 16),
              _buildHelpCards(),
              const SizedBox(height: 28),
              _buildSectionHeading(
                'Frequently asked questions',
                'Quick answers to common questions.',
              ),
              const SizedBox(height: 14),
              _buildFaqPreview(),
              const SizedBox(height: 12),
              _buildViewAllFaqsButton(),
              const SizedBox(height: 28),
              _buildSupportBanner(),
              const SizedBox(height: 24),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // WELCOME HEADER
  // =============================================================

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF174EA6),
            Color(0xFF2878D0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'We are here to help.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers, learn how AssetCoin works and get support '
            'whenever you need it.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SEARCH
  // =============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search for help...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE5EAF2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF2878D0),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SECTION HEADING
  // =============================================================

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // =============================================================
  // HELP CARDS
  // =============================================================

  Widget _buildHelpCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildHelpCard(
                title: 'FAQs',
                subtitle: 'Common questions',
                icon: Icons.quiz_outlined,
                color: const Color(0xFF2878D0),
                onTap: () => _openSection(const _FaqPage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHelpCard(
                title: 'User Guide',
                subtitle: 'Learn AssetCoin',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFFDC3545),
                onTap: () => _openSection(const _UserGuidePage()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHelpCard(
                title: 'Troubleshooting',
                subtitle: 'Fix common issues',
                icon: Icons.build_circle_outlined,
                color: const Color(0xFF2878D0),
                onTap: () => _openSection(const _TroubleshootingPage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHelpCard(
                title: 'Contact Support',
                subtitle: 'Get assistance',
                icon: Icons.headset_mic_outlined,
                color: const Color(0xFFDC3545),
                onTap: () => _openSection(const _ContactSupportPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFE8ECF3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Color(0xFF2878D0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // FAQ PREVIEW
  // =============================================================

  Widget _buildFaqPreview() {
    if (_filteredFaqs.isEmpty) {
      return _buildEmptySearchResult();
    }

    return Column(
      children: _filteredFaqs.map((faq) {
        return _buildFaqTile(faq);
      }).toList(),
    );
  }

  Widget _buildFaqTile(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8ECF3),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 3,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        iconColor: const Color(0xFF2878D0),
        collapsedIconColor: Colors.grey.shade600,
        title: Text(
          faq['question']!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              faq['answer']!,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 35,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          const Text(
            'No matching help articles found.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try using different search words.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllFaqsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _openSection(const _FaqPage()),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2878D0),
          side: const BorderSide(
            color: Color(0xFF2878D0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'View all FAQs',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SUPPORT BANNER
  // =============================================================

  Widget _buildSupportBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFFAD1D6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: Color(0xFFDC3545),
                size: 24,
              ),
              SizedBox(width: 9),
              Text(
                'Still need help?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team can help you with account, verification '
            'and platform-related questions.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openSection(const _ContactSupportPage()),
              icon: const Icon(Icons.mail_outline_rounded),
              label: const Text('Contact support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // FOOTER
  // =============================================================

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          const Text(
            'AssetCoin',
            style: TextStyle(
              color: Color(0xFF2878D0),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Unlock the value of your assets securely.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help & Education',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// FAQ PAGE
// =============================================================

class _FaqPage extends StatefulWidget {
  const _FaqPage();

  @override
  State<_FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<_FaqPage> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  List<Map<String, String>> get _filteredFaqs {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return _assetCoinFaqs;
    }

    return _assetCoinFaqs.where((faq) {
      return faq['question']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5EAF2),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredFaqs.isEmpty
                  ? const Center(
                      child: Text('No matching questions found.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                      itemCount: _filteredFaqs.length,
                      itemBuilder: (context, index) {
                        final faq = _filteredFaqs[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE8ECF3),
                            ),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              faq['question']!,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  faq['answer']!,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// USER GUIDE PAGE
// =============================================================

class _UserGuidePage extends StatelessWidget {
  const _UserGuidePage();

  static const List<Map<String, dynamic>> _sections = [
    {
      'title': 'Getting started with AssetCoin',
      'icon': Icons.rocket_launch_outlined,
      'steps': [
        'Create your AssetCoin account.',
        'Log in using your registered credentials.',
        'Complete your profile information.',
        'Follow the KYC verification instructions.',
        'Explore your dashboard and available features.',
      ],
    },
    {
      'title': 'Submitting an asset',
      'icon': Icons.add_home_work_outlined,
      'steps': [
        'Open the Assets section.',
        'Choose the option to submit an asset.',
        'Select the appropriate asset category.',
        'Enter the requested asset details.',
        'Upload the required supporting documents and photographs.',
        'Review your information and submit the application.',
        'Monitor the review status from your submitted assets.',
      ],
    },
    {
      'title': 'Using your wallet',
      'icon': Icons.account_balance_wallet_outlined,
      'steps': [
        'Open the Wallet section.',
        'Review your available balances.',
        'Explore supported deposit and withdrawal options.',
        'Review your wallet transaction history.',
        'Check transaction details before confirming an action.',
      ],
    },
    {
      'title': 'Exploring the marketplace',
      'icon': Icons.storefront_outlined,
      'steps': [
        'Open the Trading section.',
        'Browse available token listings.',
        'Review listing details and prices.',
        'Follow the instructions for supported buy or sell actions.',
        'Review your orders and token holdings.',
      ],
    },
    {
      'title': 'Managing your profile',
      'icon': Icons.person_outline_rounded,
      'steps': [
        'Open your Profile section.',
        'Review your personal information.',
        'Manage your security and privacy settings.',
        'Update supported notification preferences.',
        'Contact support if you need additional assistance.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Guide'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF2878D0),
                  size: 30,
                ),
                SizedBox(height: 12),
                Text(
                  'Learn how to use AssetCoin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Follow these guides to understand the main features '
                  'and navigate the platform confidently.',
                  style: TextStyle(
                    color: Color(0xFF526176),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._sections.map((section) {
            final steps = section['steps'] as List<String>;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFE8ECF3),
                ),
              ),
              child: ExpansionTile(
                leading: Icon(
                  section['icon'] as IconData,
                  color: const Color(0xFF2878D0),
                ),
                title: Text(
                  section['title'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                children: [
                  ...steps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: const Color(0xFFEAF3FF),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Color(0xFF2878D0),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================
// TROUBLESHOOTING PAGE
// =============================================================

class _TroubleshootingPage extends StatelessWidget {
  const _TroubleshootingPage();

  static const List<Map<String, String>> _issues = [
    {
      'title': 'I cannot log in',
      'problem':
          'You may be entering incorrect login details or your session '
              'may have expired.',
      'solution':
          'Check your registered email or phone number and password. '
              'If you cannot remember your password, use Forgot Password. '
              'Make sure your internet connection is working.',
    },
    {
      'title': 'I did not receive my verification code',
      'problem':
          'A verification message may be delayed or your contact details '
              'may be incorrect.',
      'solution':
          'Confirm your registered phone number or email address. '
              'Wait briefly before requesting another code. Check your '
              'message inbox and spam folder where applicable.',
    },
    {
      'title': 'My asset submission is still pending',
      'problem':
          'Your submission may still be waiting for review.',
      'solution':
          'Open My Submitted Assets and check the current status. '
              'If additional information is requested, follow the '
              'instructions shown in the application.',
    },
    {
      'title': 'My asset submission was rejected',
      'problem':
          'The submitted asset may not have met the verification '
              'requirements.',
      'solution':
          'Review the feedback provided with your submission. '
              'Correct any missing or inaccurate information before '
              'submitting again, if resubmission is available.',
    },
    {
      'title': 'My wallet balance is not updating',
      'problem':
          'A transaction may still be processing or the latest balance '
              'may not yet have refreshed.',
      'solution':
          'Refresh the wallet page and check your transaction history. '
              'If the issue continues, contact support with the relevant '
              'transaction reference. Never share your password or OTP.',
    },
    {
      'title': 'I cannot complete a trade',
      'problem':
          'The listing may no longer be available or the transaction '
              'may not meet the platform requirements.',
      'solution':
          'Check the listing status, available balance and order details. '
              'Try again only after confirming the information displayed '
              'by the platform.',
    },
    {
      'title': 'The application is not loading properly',
      'problem':
          'Your internet connection or application session may be '
              'affecting the page.',
      'solution':
          'Check your internet connection, refresh the page and sign in '
              'again if necessary. If the issue persists, contact support.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Troubleshooting'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  color: Color(0xFFDC3545),
                  size: 30,
                ),
                SizedBox(height: 12),
                Text(
                  'Having trouble?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Find possible solutions to common AssetCoin issues.',
                  style: TextStyle(
                    color: Color(0xFF526176),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._issues.map((issue) {
            return Container(
              margin: const EdgeInsets.only(bottom: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE8ECF3),
                ),
              ),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF2878D0),
                ),
                title: Text(
                  issue['title']!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _issueDetail(
                    'What might be happening',
                    issue['problem']!,
                  ),
                  const SizedBox(height: 12),
                  _issueDetail(
                    'What you can do',
                    issue['solution']!,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _issueDetail(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2878D0),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey.shade700,
            height: 1.5,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// CONTACT SUPPORT PAGE
// =============================================================

class _ContactSupportPage extends StatefulWidget {
  const _ContactSupportPage();

  @override
  State<_ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<_ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'General enquiry';

  bool _isSubmitting = false;

  static const List<String> _categories = [
    'General enquiry',
    'Account and login',
    'KYC and verification',
    'Asset submission',
    'Wallet and transactions',
    'Trading and orders',
    'Technical issue',
    'Other',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Support request backend integration has not been connected yet.
    // This currently prepares the request but does not send it.

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2878D0),
            size: 35,
          ),
          title: const Text('Support request prepared'),
          content: const Text(
            'Your message has passed validation, but support request '
            'submission is not connected yet. Please contact support '
            'through an available official channel for now.',
            style: TextStyle(
              height: 1.5,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Contact Support'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.headset_mic_rounded,
                        color: Color(0xFF2878D0),
                        size: 30,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'How can we assist you?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Tell us about the issue you are experiencing.',
                        style: TextStyle(
                          color: Color(0xFF526176),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Support category'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDecoration(
                    hint: 'Select a category',
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                _buildLabel('Subject'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _subjectController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hint: 'Briefly describe your issue',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subject.';
                    }

                    if (value.trim().length < 4) {
                      return 'Subject must be at least 4 characters.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildLabel('Message'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  minLines: 5,
                  maxLines: 7,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hint: 'Explain how we can help you...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your message.';
                    }

                    if (value.trim().length < 10) {
                      return 'Please provide a little more detail.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFE2A6),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: Color(0xFFB7791F),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'For your security, never include your password, '
                          'OTP, PIN or National ID number in a support message.',
                          style: TextStyle(
                            color: Color(0xFF805B1B),
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSubmitting ? null : _submitSupportRequest,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _isSubmitting
                          ? 'Preparing request...'
                          : 'Submit request',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2878D0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    'AssetCoin Support',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hint,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE5EAF2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFF2878D0),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDC3545),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDC3545),
          width: 1.4,
        ),
      ),
    );
  }
}