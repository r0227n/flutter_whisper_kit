import 'package:flutter/material.dart';

/// Widget for device information section
class DeviceInformationSection extends StatelessWidget {
  const DeviceInformationSection({
    super.key,
    required this.deviceNameResult,
    required this.isLoadingDeviceName,
    required this.onGetDeviceNamePressed,
  });

  final String deviceNameResult;
  final bool isLoadingDeviceName;
  final VoidCallback onGetDeviceNamePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Device Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isLoadingDeviceName ? null : onGetDeviceNamePressed,
          child: Text(
            isLoadingDeviceName ? 'Loading...' : 'Get Device Name',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            deviceNameResult.isEmpty
                ? 'Press the button to get device name'
                : deviceNameResult,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
