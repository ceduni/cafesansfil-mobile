import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class RoleToggle extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const RoleToggle({super.key, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      minWidth: 90.0,
      cornerRadius: 20.0,
      activeBgColors: const [
        [Color.fromARGB(255, 138, 199, 249)],
        [Color.fromARGB(255, 138, 199, 249)]
      ],
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.white,
      inactiveFgColor: Colors.black,
      initialLabelIndex: selectedIndex,
      totalSwitches: 2,
      labels: const ['Volunteer', 'Admin'],
      radiusStyle: true,
      onToggle: (index) => onSelect(index!),
    );
  }
}
