import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_colors.dart';
import '../../cars/models/car_model.dart';

/// 🤖 شاشة الدردشة مع الذكاء الاصطناعي
/// تساعد المستخدم في اختيار السيارة المناسبة
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =============================
  // 👋 رسالة الترحيب
  // =============================
  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "مرحباً بك! 👋\n\nأنا مساعدك الذكي لاختيار السيارة المثالية. يمكنني مساعدتك في:\n\n🚗 اقتراح سيارات مناسبة\n💰 مقارنة الأسعار\n📍 البحث حسب المدينة\n✨ معرفة المميزات\n\nكيف يمكنني مساعدتك اليوم؟",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  // =============================
  // 📤 إرسال رسالة
  // =============================
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // إضافة رسالة المستخدم
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // معالجة الرسالة والرد
    await _processMessage(text);
  }

  // =============================
  // 🤖 معالجة الرسالة
  // =============================
  Future<void> _processMessage(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final message = userMessage.toLowerCase();
    String response = "";
    List<CarModel>? suggestedCars;

    try {
      // 1️⃣ البحث عن سيارة رخيصة
      if (message.contains('رخيص') || 
          message.contains('اقتصادي') || 
          message.contains('أرخص')) {
        final cars = await _searchCars(maxPrice: 150);
        if (cars.isNotEmpty) {
          response = "وجدت لك أفضل السيارات الاقتصادية! 💰\n\nإليك الخيارات المتاحة بأسعار تبدأ من ${cars.first.pricePerDay.toInt()} ر.س/اليوم:";
          suggestedCars = cars.take(3).toList();
        }
      }
      
      // 2️⃣ البحث عن سيارة فاخرة
      else if (message.contains('فاخر') || 
               message.contains('فخم') || 
               message.contains('راقي')) {
        final cars = await _searchCars(category: 'فاخرة');
        if (cars.isNotEmpty) {
          response = "لديك ذوق رفيع! ✨\n\nإليك أفخم سياراتنا:";
          suggestedCars = cars.take(3).toList();
        }
      }
      
      // 3️⃣ البحث عن سيارة عائلية
      else if (message.contains('عائل') || 
               message.contains('كبير') || 
               message.contains('7 مقاعد') ||
               message.contains('سبع مقاعد')) {
        final cars = await _searchCars(category: 'كبيرة');
        if (cars.isNotEmpty) {
          response = "مثالي للعائلات! 👨‍👩‍👧‍👦\n\nإليك سيارات واسعة ومريحة:";
          suggestedCars = cars.take(3).toList();
        }
      }
      
      // 4️⃣ البحث حسب المدينة
      else if (message.contains('الرياض')) {
        final cars = await _searchCars(city: 'الرياض');
        response = "سيارات متاحة في الرياض 📍\n\nلدينا ${cars.length} سيارة متاحة:";
        suggestedCars = cars.take(3).toList();
      }
      else if (message.contains('جدة')) {
        final cars = await _searchCars(city: 'جدة');
        response = "سيارات متاحة في جدة 📍\n\nلدينا ${cars.length} سيارة متاحة:";
        suggestedCars = cars.take(3).toList();
      }
      else if (message.contains('الدمام')) {
        final cars = await _searchCars(city: 'الدمام');
        response = "سيارات متاحة في الدمام 📍\n\nلدينا ${cars.length} سيارة متاحة:";
        suggestedCars = cars.take(3).toList();
      }
      
      // 5️⃣ سؤال عن الأسعار
      else if (message.contains('سعر') || message.contains('كم')) {
        response = "أسعارنا تبدأ من:\n\n💰 سيارات اقتصادية: 115-150 ر.س/اليوم\n🚙 سيارات متوسطة: 190-220 ر.س/اليوم\n🚐 سيارات كبيرة: 350-450 ر.س/اليوم\n✨ سيارات فاخرة: 700-800 ر.س/اليوم\n\nما نوع السيارة التي تبحث عنها؟";
      }
      
      // 6️⃣ سؤال عن المميزات
      else if (message.contains('مميز') || message.contains('خاصي')) {
        response = "سياراتنا تأتي بمميزات رائعة:\n\n✅ تأمين شامل\n✅ نظام ملاحة GPS\n✅ بلوتوث وUSB\n✅ كاميرا خلفية\n✅ تكييف قوي\n✅ مقاعد مريحة\n\nهل تريد رؤية سيارات بمميزات محددة؟";
      }
      
      // 7️⃣ عرض جميع السيارات
      else if (message.contains('كل') || 
               message.contains('جميع') || 
               message.contains('شو عندكم') ||
               message.contains('ايش عندكم')) {
        final cars = await _searchCars();
        response = "لدينا ${cars.length} سيارة متنوعة! 🚗\n\nإليك بعض الخيارات المميزة:";
        suggestedCars = cars.take(4).toList();
      }
      
      // 8️⃣ رد افتراضي
      else {
        response = "يمكنني مساعدتك في:\n\n🔍 البحث عن سيارة مناسبة\n📍 اختيار سيارة في مدينة معينة\n💰 إيجاد أفضل الأسعار\n🚗 مقارنة السيارات\n\nجرب أن تقول:\n• أريد سيارة رخيصة\n• سيارة فاخرة في الرياض\n• سيارة عائلية كبيرة\n• كم الأسعار؟";
      }

    } catch (e) {
      response = "عذراً، حدث خطأ في البحث 😔\nالرجاء المحاولة مرة أخرى.";
      print('خطأ في معالجة الرسالة: $e');
    }

    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedCars: suggestedCars,
      ));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  // =============================
  // 🔍 البحث في السيارات
  // =============================
  Future<List<CarModel>> _searchCars({
    String? city,
    String? category,
    double? maxPrice,
  }) async {
    try {
      var query = supabase
          .from('cars_catalog')
          .select()
          .eq('available', true);

      if (city != null) {
        query = query.eq('city', city);
      }
      if (category != null) {
        query = query.eq('category', category);
      }
      if (maxPrice != null) {
        query = query.lte('price_per_day', maxPrice);
      }

      final response = await query.order('price_per_day', ascending: true);
      return (response as List)
          .map((json) => CarModel.fromDb(json))
          .toList();
    } catch (e) {
      print('خطأ في البحث: $e');
      return [];
    }
  }

  // =============================
  // 📜 التمرير للأسفل
  // =============================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.cardDark,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "المساعد الذكي",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "متصل الآن",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // قائمة الرسائل
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // حقل الإدخال
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  // =============================
  // 💬 فقاعة الرسالة
  // =============================
  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // الرسالة النصية
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isUser ? AppColors.primary : AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: message.isUser
                  ? null
                  : Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // السيارات المقترحة (إن وجدت)
          if (message.suggestedCars != null && message.suggestedCars!.isNotEmpty)
            ..._buildCarSuggestions(message.suggestedCars!),

          // الوقت
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================
  // 🚗 كروت السيارات المقترحة
  // =============================
  List<Widget> _buildCarSuggestions(List<CarModel> cars) {
    return [
      const SizedBox(height: 12),
      ...cars.map((car) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCarCard(car),
          )),
    ];
  }

  Widget _buildCarCard(CarModel car) {
    return InkWell(
      onTap: () {
        // TODO: فتح تفاصيل السيارة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تفاصيل ${car.fullName}')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            // الأيقونة
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(car.categoryIcon, style: TextStyle(fontSize: 30)),
              ),
            ),

            const SizedBox(width: 12),

            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        car.city,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          car.category,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // السعر
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${car.pricePerDay.toInt()} ر.س',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'لليوم',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // ⌨️ مؤشر الكتابة
  // =============================
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, double value, child) {
        return Opacity(
          opacity: (value * 2) % 1,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  // =============================
  // 📝 حقل الإدخال
  // =============================
  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(
          top: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // حقل النص
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // زر الإرسال
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isTyping
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _isTyping ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // 🕐 تنسيق الوقت
  // =============================
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }
}

// =============================
// 💬 نموذج الرسالة
// =============================
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<CarModel>? suggestedCars;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedCars,
  });
}