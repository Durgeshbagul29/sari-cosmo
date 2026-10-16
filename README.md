# 📱 Archana's Herbal — IICTN App

**Indian Institute of Cosmetology, Trichology & Nutrition**

A cross-platform Flutter mobile application that unifies **herbal e-commerce**, **professional certification courses**, and **expert health consultations** into one seamless digital wellness platform.

---

## ✨ Highlights

- 🛒 **E-Commerce** — Product catalog, cart, checkout with Razorpay payments
- 🎓 **EdTech** — Professional courses in Trichology, Cosmetology & Nutrition
- 📅 **HealthTech** — Expert consultation booking (Video Call / In-Person)
- 🎨 **Premium UI** — Custom animations, dark mode, responsive design
- 🌐 **Offline-First** — Real-time network monitoring with graceful fallback

## 📊 Project Stats

| Metric | Value |
|---|---|
| Screens | 30+ |
| Source Files | 51 |
| Lines of Code | ~9,200 |
| Platforms | Android · iOS · Web |

## 🏗️ Architecture

```
lib/
├── main.dart                    # Entry point, Navigation shell
├── core/                        # Shared foundation
│   ├── controllers/             # GetX controllers (Cart, Products, Network)
│   ├── models/                  # Data models (Product, Course, Expert)
│   ├── data/                    # Static data & catalog
│   ├── theme/                   # Light + Dark themes, color system
│   ├── widgets/                 # Reusable UI components
│   └── utils/                   # Constants & helpers
└── features/                    # Feature modules
    ├── auth/                    # Login, Signup
    ├── onboarding/              # First-launch walkthrough
    ├── home/                    # Dashboard with banners, featured items
    ├── shop/                    # Product listing, detail, cart, checkout
    ├── courses/                 # Course catalog, enrollment, payment
    ├── appointments/            # Expert directory, booking system
    ├── search/                  # Unified search
    └── profile/                 # Orders, wishlist, addresses, loyalty, etc.
```

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **State Management** | GetX |
| **Payments** | Razorpay |
| **Typography** | Google Fonts (Inter) |
| **Persistence** | SharedPreferences |
| **Networking** | connectivity_plus |
| **Images** | cached_network_image |

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

### Requirements

- Flutter SDK ≥ 3.0.0
- Android API 21+ / iOS 12+
- Razorpay test keys (included for development)

## 📱 Key Screens

| Home & Shop | Courses & Booking | Profile |
|---|---|---|
| Home Dashboard | Course Catalog | Profile Dashboard |
| Product Grid/List | Course Detail | My Orders & Tracking |
| Product Detail | Payment Success | Wishlist & Addresses |
| Cart & Checkout | Expert Directory | Loyalty & Referrals |

## 🎨 Design System

- **Primary Brand:** `#D1A84F` (Gold/Sand)
- **Accent:** `#063426` (Dark Green)
- **Font:** Inter
- **Themes:** Light + Dark (auto-detect)
- **Components:** BadgeChip, StarRating, PriceTag, NetworkImage, CategoryChip

## 📞 Contact

| | |
|---|---|
| **Email** | archana@gmail.com |
| **Phone** | +91 4345 33859 |
| **Website** | www.example.com |

## 📄 License

Proprietary software. All rights reserved.

---

<p align="center">
  <b>Built with ❤️ using Flutter</b><br>
  v1.0.0 · June 2026
</p>

# sari-cosmo
