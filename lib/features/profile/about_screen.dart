import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("About Archana's Herbal")),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _buildLogoSection(context),
          const SizedBox(height: 24),
          _buildPhilosophy(context),
          const SizedBox(height: 32),
          _buildCatalogHeader(),
          const SizedBox(height: 16),
          ..._catalog.map((product) => _buildProductCard(product)),
          const SizedBox(height: 32),
          _buildFooter(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: AppTheme.primary, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            "Archana's Herbal",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "A Pack of Nature's Love",
            style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophy(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.self_improvement_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Our Philosophy',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Our focus is to bring people closer to the nature. We offer a range of herbal cosmetic products which are artisanal and 100% herbal that are safe and effective. Our herbal product formulations are well researched and quality-certified. These products are beneficial in every part of the globe.",
            style: TextStyle(
                fontSize: 14, color: AppTheme.textMedium, height: 1.6),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('Skin Care'),
              _buildTag('Hair Care'),
              _buildTag('Body Care'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent)),
    );
  }

  Widget _buildCatalogHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: AppTheme.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'PRODUCT CATALOG',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppTheme.textLight,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.divider)),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: AppTheme.primary,
        collapsedIconColor: AppTheme.textLight,
        shape: const Border(),
        title: Text(
          product['name'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            product['subtitle'],
            style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Benefits'),
                const SizedBox(height: 8),
                ...List<Widget>.from((product['benefits'] as List).map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle, size: 6, color: AppTheme.accent),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(b, style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.5))),
                    ],
                  ),
                ))),
                const SizedBox(height: 16),
                
                _buildSectionTitle('Ingredients'),
                const SizedBox(height: 8),
                Text(product['ingredients'], style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.5)),
                const SizedBox(height: 16),

                _buildSectionTitle('Direction to Use'),
                const SizedBox(height: 8),
                Text(product['direction'], style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.5)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Available Size: ${product['size']}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppTheme.textLight),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        _buildContactInfo(),
        const SizedBox(height: 32),
        const Text('Follow Us', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(Icons.facebook_outlined),
            _socialIcon(Icons.camera_alt_outlined), // For Instagram
            _socialIcon(Icons.language_outlined),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_cart_checkout_rounded, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text('Online Available At: amazon.in/archana herbals', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
        const SizedBox(height: 4),
        const Text("© 2025 Archana's Herbal. All Rights Reserved.", style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          _contactRow(Icons.email_outlined, 'archana.herbals@gmail.com'),
          const Divider(height: 24, color: AppTheme.divider),
          _contactRow(Icons.phone_outlined, '+91 77418 33859'),
          const Divider(height: 24, color: AppTheme.divider),
          _contactRow(Icons.location_on_outlined, 'Savedi, Ahmednagar 414 003\n(M.S.), India'),
          const Divider(height: 24, color: AppTheme.divider),
          _contactRow(Icons.language_outlined, 'www.archanaherbals.com'),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.5)),
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.textMedium, size: 22),
      ),
    );
  }
}

final List<Map<String, dynamic>> _catalog = [
  {
    'name': "ARCHANA'S HERBAL BODY SCRUB",
    'subtitle': 'Traditional Herbal Royal Bath',
    'benefits': [
      'Traditional Ayurvedic skin treatment for everyday use',
      '100% natural ingredients (No Chemicals)',
      'Composition of more than 15 herbs that gives spa-like results at home',
      'Removes dead skin and rejuvenates body with natural glow',
      'Helps remove Acne, scars and blemishes',
      'Regular use will enhance glowing, smooth and natural beauty of the skin'
    ],
    'ingredients': 'Vala (Vetiveria Zizanioides), Kachora (Curcuma Zedoaria), Manjishtha (Rubia Cordifolia), Vekhand (Acorus Calamus), Ambehalad (Curcuma Amada)',
    'direction': "Take 1-2 teaspoon of Archana's body scrub. Mix with milk or water properly. Apply the paste on body and wash. The powder can also be used directly without mixing milk or water. Don't use bath soap for better effect.",
    'size': '40 gm'
  },
  {
    'name': "ARCHANA'S HERBAL FACE PACK",
    'subtitle': 'Traditional Herbal Beauty Treatment',
    'benefits': [
      'Available in 3 types: Dry Skin, Normal Skin & Oily Skin (as per skin type)',
      'Helps to achieve glowing skin and found to be very gentle',
      'Cleans up the skin immediately',
      'Removes tan, effective on pimples, blackheads and dark spots',
      'Evens out skin tone and improves complexion'
    ],
    'ingredients': 'Ambehalad (Curcuma Amada), Neem (Azadirachta Indica), Tulasi (Ocimum Tenuiflorum), Kapur Kachri (Hedychium Spicatum), Vekhand (Acorus Calamus), Vala (Vetiveria Zizanioides), Marava (Morus Alba)',
    'direction': 'Take half teaspoon of powder and make a paste with milk / rose water / butter. Wipe your skin and apply smooth pack over face and neck evenly. Allow the pack to work on your skin for 5-6 min. Now wet your fingers and gently scrub the face in circular motion to remove the dead skin. Rinse with clean and cold water.',
    'size': '50 gm'
  },
  {
    'name': "ARCHANA'S HERBAL SILK ROSA",
    'subtitle': 'Natural Moisturizer',
    'benefits': [
      'Glows your skin',
      'Makes the skin soft',
      'Improves the skin texture',
      'A natural moisturizer with rose water base'
    ],
    'ingredients': 'Rose Water, Glycerine etc.',
    'direction': 'Use the moisturizer after bath when the pores are open. Take one or two drops and apply on the body part that exposes to Sun. Can be used before and after shave.',
    'size': '50 ml'
  },
  {
    'name': "ARCHANA'S HERBAL UTANE / UBTAN",
    'subtitle': 'Festival Skin Care Pack',
    'benefits': [
      'Traditional Festival Bath Treatment',
      '100% Natural / Chemical Free',
      'No Additional Fragrances, Colors Used',
      'Helps Nourish Skin Texture',
      'Removes Dead Skin & Enhances Smooth & Glowing Skin'
    ],
    'ingredients': 'Anantmul (Hemidesmus Indicus), Ambehalad (Curcuma Amada), Kapur Kachri (Hedychium Spicatum), Vala (Vetiveria Zizanioides), Manjishtha (Rubia Cordifolia), Santra (Citrus Sinesis), Vekhand (Acorus Calamus), Kachora (Curcuma Zedoaria), Nagarmotha (Cyterus Scariosus), Kadunimba Patra (Azadirachta Indica)',
    'direction': "Take 1-2 spoon of Archana's Herbal Utane. Mix with milk or water properly. Apply the paste on body and wash. The powder can also be used directly without mixing milk or water. Don't use bath soap for better effect.",
    'size': '20 gm'
  },
  {
    'name': "ARCHANA'S KESH SUDHA HAIR TONIC",
    'subtitle': 'Pure Ayurvedic Preparation',
    'benefits': [
      'Hair vitalizer with herbal extracts',
      'Effective for healthy and youthful hair',
      'Prevents early falling of hair',
      'Induces peaceful sleep',
      'Stimulates thickening of hair'
    ],
    'ingredients': 'Haswan (Hibiscus Rosa Sinensis), Nagarmotha (Cyperus Scarious), Brahmi (Bacopa Monierie), Bringraj (Eclipta Prostrata), Banchi (Psoralea Corylifolia), Vatajata (Ficus Benghalensis), Kadunimb Patra (Azadirachta Indica), Jatamansi (Nardostachys Jatamansi), Amla (Emblica Officinalis), Coconut Oil Base',
    'direction': 'Massage oil on scalp before bedtime or in the morning. Hair can be washed after one hour.',
    'size': '100 ml'
  },
  {
    'name': "ARCHANA'S HERBAL SHIKEKAI COMPOUND",
    'subtitle': 'Traditional Herbal Hair Wash',
    'benefits': [
      '100% natural ingredients (No Chemicals)',
      'Helps promote beautiful hair',
      'Helpful in preventing hair fall, dandruff and scalp itching',
      'Gives natural healthy bounce to hair',
      'Pure herbal alternative to any type of shampoo'
    ],
    'ingredients': 'Shikekai (Acacia Concinna), Amala (Emblica Officinalis), Nagarmotha (Cyterus Scariosus), Santra (Citrus Sinesis), Neem Sal (Azadirachta Indica), Brahmi (Bacopa Monnieri), Maka (Eclipta Alba)',
    'direction': "Boil 2 tablespoon or more (depending on hair length) of powder in water. Stir the mixture until well blended into a paste, then let sit 15 minutes or until it reaches a comfortable temperature. Thoroughly saturate your hair and apply the paste to your hair. Run your fingers gently, do not rub, through your hair and rinse thoroughly at the end of your shower. Don't let this herb get into your eyes, to avoid irritation. Carefully rinse with water.",
    'size': '50 gm'
  },
  {
    'name': "ARCHANA'S HERBAL MEHENDI",
    'subtitle': 'Traditional Herbal Hair Conditioner / Colour',
    'benefits': [
      'Complete Ayurvedic recipe to condition and colour your hair',
      '100% natural ingredients (No Chemicals)',
      'Helps nourish the hair quality naturally',
      'Helpful in preventing hair fall, hair strengthening, split ends, dandruff',
      'Improves hair tone',
      'Gives a naturally rich colour to your hair'
    ],
    'ingredients': 'Mehendi (Lawsoniainermis), Nagarmotha (Cyterus Scariosus), Jatamasi (Nardostachys Jatamansi), Brahmi (Bacopa Monnieri), Maka (Eclipta Alba), Trifala (Emblica Officinalis, Terminalia Chebula and Terminalia Belerica), Vadparambi (Ficus Benghalensis)',
    'direction': 'Make an appropriate paste of mehendi with water and keep it in an iron pan for 4 to 5 hours. Apply it on hair. Keep it for one hour for conditioning the hair and for two hours for rich colour. Wash out and feel the change.',
    'size': '80 gm'
  },
  {
    'name': "ARCHANA'S RIPPLE MASSAGE OIL",
    'subtitle': 'Traditional Full Body Massage Oil',
    'benefits': [
      'Reduces inflammation in joints and muscles',
      'Relieving pain and restoring mobility',
      'Improves metabolism',
      'Helps in detoxification, better sleep and stress reduction',
      'Improves organ function and blood circulation',
      'Helps to reverse skin damage to some extent'
    ],
    'ingredients': 'Trifala, Ashwagandha, Shatavari, Nirgudi, Vidarikand, Wala, Sesom Indicum Oil',
    'direction': "Gently massage all over the body for 10 minutes. Then rub Archana's Herbal Body Scrub & wash with hot water for smooth nourished skin.",
    'size': '50 ml, 100 ml'
  },
  {
    'name': "ARCHANA'S HERBAL FOOT SPRAY",
    'subtitle': 'Foot Care Treatment',
    'benefits': [
      'Eczema',
      'Rashes & Cracks',
      'Ringworm',
      'Burnings',
      'Fungal Infection',
      'Diabetic Skin Conditions',
      'Blisters'
    ],
    'ingredients': 'Lemon Oil, Azadirachta Indica, Peppermint Oil, Eucalyptus Oil, Lemongrass Oil',
    'direction': 'Shake well and spray from at least 10 cm away from the feet.',
    'size': '60 ml, 130 ml'
  }
];
