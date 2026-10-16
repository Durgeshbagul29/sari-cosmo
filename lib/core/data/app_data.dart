import 'package:saris_cosmo_center/core/models/models.dart';

class AppData {
  static const List<Product> products = [
    Product(
      id: 'p1', name: 'Hair Growth Serum Pro', category: 'Hair Care',
      description: 'Advanced trichology formula with biotin, keratin & DHT blockers. Clinically tested for hair regrowth in 90 days.',
      imageUrl: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?w=400',
      price: 899, originalPrice: 1299, rating: 4.8, reviews: 342, stock: 50, badge: 'Bestseller',
      benefits: ['Reduces hair fall 70%', 'Boosts hair volume', 'Nourishes scalp', 'DHT Blocker'],
    ),
    Product(
      id: 'p2', name: 'Scalp Detox Shampoo', category: 'Hair Care',
      description: 'Deep cleansing formula with tea tree oil & salicylic acid for dandruff-free scalp health.',
      imageUrl: 'https://images.unsplash.com/photo-1585751119414-ef2636f8aede?w=400',
      price: 499, originalPrice: 699, rating: 4.6, reviews: 218, stock: 80, badge: 'New',
      benefits: ['Eliminates dandruff', 'Balances pH', 'Sulfate-free', 'Dermatologist tested'],
    ),
    Product(
      id: 'p3', name: 'Collagen Boost Face Cream', category: 'Skin Care',
      description: 'Anti-aging formula with marine collagen, hyaluronic acid & vitamin C for radiant skin.',
      imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
      price: 1199, originalPrice: 1799, rating: 4.9, reviews: 189, stock: 35, badge: 'Top Rated',
      benefits: ['Reduces wrinkles', 'Deep hydration', 'Brightens skin tone', 'SPF 30'],
    ),
    Product(
      id: 'p4', name: 'Biotin & Zinc Supplement', category: 'Nutrition',
      description: 'Premium hair & nail growth supplement with biotin 10000mcg, zinc & selenium complex.',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      price: 649, originalPrice: 849, rating: 4.7, reviews: 456, stock: 120, badge: 'Bestseller',
      benefits: ['Hair & nail growth', 'Reduces brittleness', '3-month supply', 'Vegetarian'],
    ),
    Product(
      id: 'p5', name: 'Trichology Hair Mask', category: 'Hair Care',
      description: 'Deep conditioning treatment with argan oil, protein complex & keratin repair technology.',
      imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
      price: 749, originalPrice: 999, rating: 4.5, reviews: 134, stock: 60, badge: '',
      benefits: ['Repairs damage', 'Restores shine', 'Protein-rich', 'Heat protection'],
    ),
    Product(
      id: 'p6', name: 'Vitamin D3 + K2 Drops', category: 'Nutrition',
      description: 'High-potency vitamin D3 with K2 for bone health, immunity & hair follicle support.',
      imageUrl: 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=400',
      price: 549, originalPrice: 749, rating: 4.6, reviews: 267, stock: 95, badge: 'New',
      benefits: ['Immune support', 'Bone strength', 'Hair follicle health', 'Easy absorption'],
    ),
  ];

  static const List<Expert> experts = [
    Expert(
      id: 'e1', name: 'Dr. Priya Sharma', specialization: 'Senior Trichologist',
      qualification: 'MBBS, DTD, Certified Trichologist (UK)',
      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
      bio: 'Over 15 years of experience in diagnosing and treating all forms of hair loss and scalp disorders. Trained in London and Mumbai.',
      rating: 4.9, patients: 3200, experience: 15,
      services: ['Hair Loss Analysis', 'PRP Consultation', 'Scalp Treatment', 'Diet Planning'],
      availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
    ),
    Expert(
      id: 'e2', name: 'Dr. Meera Nair', specialization: 'Clinical Cosmetologist',
      qualification: 'MD Dermatology, FAAD',
      imageUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400',
      bio: 'Specializes in advanced skin treatments, anti-aging procedures and clinical cosmetology. Pioneer of holistic skin health approach.',
      rating: 4.8, patients: 2800, experience: 12,
      services: ['Skin Analysis', 'Chemical Peels', 'Anti-aging Consultation', 'Acne Treatment'],
      availableDays: ['Tue', 'Thu', 'Sat', 'Sun'],
    ),
    Expert(
      id: 'e3', name: 'Dr. Ankit Patel', specialization: 'Nutrition & Wellness Expert',
      qualification: 'PhD Nutrition Science, CSSD',
      imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
      bio: 'Clinical nutritionist specializing in therapeutic nutrition for hair loss, skin health and metabolic disorders.',
      rating: 4.7, patients: 1950, experience: 10,
      services: ['Diet Planning', 'Supplement Guidance', 'Metabolic Analysis', 'Gut Health'],
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    ),
    Expert(
      id: 'e4', name: 'Dr. Sunita Rao', specialization: 'Dermatologist & Cosmetologist',
      qualification: 'MBBS, MD Skin & VD, FCPS',
      imageUrl: 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400',
      bio: 'Expert in medical and aesthetic dermatology with a focus on evidence-based cosmetic treatments.',
      rating: 4.8, patients: 2400, experience: 11,
      services: ['Skin Consultation', 'Laser Treatments', 'Pigmentation', 'Scar Revision'],
      availableDays: ['Mon', 'Wed', 'Fri'],
    ),
  ];

  static const List<Appointment> myAppointments = [
    Appointment(
      id: 'a1', expertName: 'Dr. Priya Sharma', service: 'Hair Loss Analysis',
      date: '10 Jun 2025', time: '10:30 AM', status: 'Upcoming', type: 'Video Call',
    ),
    Appointment(
      id: 'a2', expertName: 'Dr. Ankit Patel', service: 'Diet Planning',
      date: '5 Jun 2025', time: '3:00 PM', status: 'Completed', type: 'In-Person',
    ),
    Appointment(
      id: 'a3', expertName: 'Dr. Meera Nair', service: 'Skin Analysis',
      date: '28 May 2025', time: '11:00 AM', status: 'Completed', type: 'Video Call',
    ),
  ];

  static const List<String> productCategories = ['All', 'Hair Care', 'Skin Care', 'Nutrition', 'Kits'];

  static const List<Map<String, String>> banners = [
    {'title': 'Hair Wellness Week', 'subtitle': 'Up to 40% off on all hair care products', 'tag': 'Limited Offer'},
    {'title': 'New Courses Live', 'subtitle': 'Advanced Trichology Certification — Enroll now', 'tag': 'New Launch'},
    {'title': 'Free Consultation', 'subtitle': 'Book your first expert consultation at no cost', 'tag': 'Exclusive'},
  ];
}
