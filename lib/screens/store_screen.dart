import 'package:flutter/material.dart';

import '../models/shop_pack.dart';
import '../services/slide_word_controller.dart';
import '../widgets/info_chip.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({
    super.key,
    required this.controller,
  });

  final SlideWordController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Tool Shop',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InfoChip(
                  label: 'Tokens',
                  value: controller.profile.cumulativeTokens.toString(),
                  icon: Icons.local_atm,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 12),
              const TabBar(
                tabs: [
                  Tab(text: 'Hints'),
                  Tab(text: 'Refresh'),
                  Tab(text: 'Bombs'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _PackList(
                      kind: 'hints',
                      packs: SlideWordController.hintPacks,
                      icon: Icons.lightbulb_outline,
                      controller: controller,
                    ),
                    _PackList(
                      kind: 'refresh',
                      packs: SlideWordController.refreshPacks,
                      icon: Icons.refresh,
                      controller: controller,
                    ),
                    _PackList(
                      kind: 'bombs',
                      packs: SlideWordController.bombPacks,
                      icon: Icons.brightness_high,
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PackList extends StatelessWidget {
  const _PackList({
    required this.kind,
    required this.packs,
    required this.icon,
    required this.controller,
  });

  final String kind;
  final List<ShopPack> packs;
  final IconData icon;
  final SlideWordController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) {
        final pack = packs[index];
        final canAfford = controller.profile.cumulativeTokens >= pack.cost;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white10,
                  child: Icon(icon, color: Colors.orangeAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${pack.amount} ${pack.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${pack.cost} tokens', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: canAfford
                      ? () async {
                          final error = await controller.buyPack(kind, pack);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error ?? controller.message)),
                          );
                        }
                      : null,
                  child: const Text('Buy'),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: packs.length,
    );
  }
}
