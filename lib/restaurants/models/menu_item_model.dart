/// 🍔 نموذج الصنف في المنيو
class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String? nameEn;
  final String? description;
  final String category;
  final double price;
  final String? imageUrl;
  final bool available;
  final bool isPopular;
  
  // خيارات إضافية
  final bool hasOptions;
  final List<MenuOption>? options;
  
  final DateTime? createdAt;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.nameEn,
    this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    required this.available,
    required this.isPopular,
    required this.hasOptions,
    this.options,
    this.createdAt,
  });

  /// 📥 من JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    List<MenuOption>? options;
    if (json['options'] != null) {
      try {
        final optionsData = json['options'] as List;
        options = optionsData.map((opt) => MenuOption.fromJson(opt)).toList();
      } catch (e) {
        print('⚠️ Error parsing options: $e');
      }
    }

    return MenuItem(
      id: json['id'] ?? '',
      restaurantId: json['restaurant_id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      description: json['description'],
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      available: json['available'] ?? true,
      isPopular: json['is_popular'] ?? false,
      hasOptions: json['has_options'] ?? false,
      options: options,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  /// 📤 إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'category': category,
      'price': price,
      'image_url': imageUrl,
      'available': available,
      'is_popular': isPopular,
      'has_options': hasOptions,
      'options': options?.map((opt) => opt.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// 💵 السعر (نص)
  String get priceText => '${price.toStringAsFixed(0)} ر.س';

  /// 🏷️ أيقونة التصنيف
  String get categoryEmoji {
    const emojis = {
      'مقبلات': '🥗',
      'وجبات رئيسية': '🍽️',
      'برجر': '🍔',
      'بيتزا': '🍕',
      'ساندويتش': '🥪',
      'أطباق جانبية': '🍟',
      'حلويات': '🍰',
      'مشروبات': '🥤',
      'عصائر': '🥤',
      'قهوة': '☕',
    };
    return emojis[category] ?? '🍽️';
  }

  @override
  String toString() => '$name - ${priceText}';
}

/// 🎛️ خيارات الصنف (حجم، إضافات، إلخ)
class MenuOption {
  final String name;
  final bool required;
  final List<MenuOptionChoice> choices;

  MenuOption({
    required this.name,
    required this.required,
    required this.choices,
  });

  factory MenuOption.fromJson(Map<String, dynamic> json) {
    return MenuOption(
      name: json['name'] ?? '',
      required: json['required'] ?? false,
      choices: (json['choices'] as List?)
          ?.map((choice) => MenuOptionChoice.fromJson(choice))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'required': required,
      'choices': choices.map((choice) => choice.toJson()).toList(),
    };
  }
}

/// ✅ خيار واحد
class MenuOptionChoice {
  final String name;
  final double additionalPrice;

  MenuOptionChoice({
    required this.name,
    required this.additionalPrice,
  });

  factory MenuOptionChoice.fromJson(Map<String, dynamic> json) {
    return MenuOptionChoice(
      name: json['name'] ?? '',
      additionalPrice: (json['additional_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'additional_price': additionalPrice,
    };
  }

  /// 💵 السعر الإضافي (نص)
  String get priceText {
    if (additionalPrice == 0) {
      return '';
    }
    return '+${additionalPrice.toStringAsFixed(0)} ر.س';
  }
}