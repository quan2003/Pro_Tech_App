import 'package:flutter/material.dart';

class OptionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  OptionItem({
    required this.icon, 
    required this.title, 
    required this.subtitle, 
    required this.onTap
  });
}

class CustomOptionsBottomSheet extends StatelessWidget {
  final List<OptionItem> options;

  const CustomOptionsBottomSheet({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(option.icon, color: Colors.blue),
                  ),
                  title: Text(option.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(option.subtitle),
                  onTap: () {
                    Navigator.pop(context);
                    option.onTap();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}