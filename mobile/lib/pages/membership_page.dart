// mobile/lib/pages/membership_page.dart
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  final StorageService _storageService = StorageService();
  User? _user;
  String? _selectedPlan;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _plans = [
    {'type': 'weekly', 'name': '周卡会员', 'price': 19.9, 'days': 7, 'color': 0xFF4CAF50, 'save': null},
    {'type': 'monthly', 'name': '月卡会员', 'price': 49.9, 'days': 30, 'color': 0xFF2196F3, 'save': '推荐'},
    {'type': 'quarterly', 'name': '季卡会员', 'price': 119.9, 'days': 90, 'color': 0xFFFF9800, 'save': '省20%'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _storageService.getUser();
    setState(() {
      _user = user ?? User();
    });
  }

  Future<void> _activateMembership() async {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择套餐')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    
    final plan = _plans.firstWhere((p) => p['type'] == _selectedPlan);
    final expireDate = DateTime.now().add(Duration(days: plan['days']));
    
    await _storageService.updateUser({'isVip': true, 'vipExpireDate': expireDate});
    
    setState(() {
      _user!.isVip = true;
      _user!.vipExpireDate = expireDate;
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${plan['name']}激活成功！')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isVip = _user?.isVipActive ?? false;
    
    return Scaffold(
      appBar: AppBar(title: const Text('会员中心'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.workspace_premium, size: 60, color: Colors.white),
                        const SizedBox(height: 12),
                        Text(isVip ? 'VIP会员' : '开通VIP会员', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(isVip ? '有效期至 ${_user!.vipExpireDate?.toString().substring(0, 10) ?? "长期"}' : '无限生成故事 + 精品故事库', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VIP 专属权益', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildBenefitItem(Icons.infinite, '无限生成故事', '每天不限次数'),
                        _buildBenefitItem(Icons.library_books, '精品故事库', '1000+精选故事'),
                        _buildBenefitItem(Icons.volume_up, '高清语音', '专业配音朗读'),
                        _buildBenefitItem(Icons.download, '离线下载', '随时随地听故事'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isVip) ...[
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('选择套餐', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 16),
                    ..._plans.map((plan) => _buildPlanCard(plan)),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _activateMembership,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.brown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                          child: const Text('立即开通', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.deepPurple)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == plan['type'];
    final color = Color(plan['color']);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: isSelected ? color.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1)),
      child: RadioListTile<String>(
        value: plan['type'],
        groupValue: _selectedPlan,
        onChanged: (value) => setState(() => _selectedPlan = value),
        title: Row(children: [Text(plan['name'], style: const TextStyle(fontWeight: FontWeight.bold)), if (plan['save'] != null) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)), child: Text(plan['save'], style: const TextStyle(color: Colors.white, fontSize: 10)))] ]),
        subtitle: Text('${plan['days']}天有效'),
        secondary: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('¥${plan['price']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))]),
      ),
    );
  }
}
