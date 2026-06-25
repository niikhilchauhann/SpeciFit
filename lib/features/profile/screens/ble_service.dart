import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '/core/responsive/sizes.dart';

class BleService {
  // Scan for devices
  Stream<List<BluetoothDevice>> scanForDevices() async* {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    try {
      await for (var scanResults in FlutterBluePlus.scanResults) {
        yield scanResults.map((result) => result.device).toList();
      }
    } catch (e) {
      debugPrint('Error during scan: $e');
    } finally {
      FlutterBluePlus.stopScan();
    }
  }

  // Connect to device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      debugPrint('Connecting to ${device.platformName}...');
      await device.connect();
      debugPrint('Connected to ${device.platformName}');
    } catch (e) {
      debugPrint('Error connecting to ${device.platformName}: $e');
    }
  }

  // Discover services
  Future<List<BluetoothService>> discoverServices(
    BluetoothDevice device,
  ) async {
    try {
      debugPrint('Discovering services for ${device.platformName}...');
      return await device.discoverServices();
    } catch (e) {
      debugPrint('Error discovering services: $e');
      return [];
    }
  }

  // Subscribe to notifications
  void subscribeToCharacteristic(BluetoothCharacteristic characteristic) {
    try {
      characteristic.setNotifyValue(true);
      characteristic.lastValueStream.listen((value) {
        debugPrint(
          'Characteristic value: ${value.map((e) => e.toRadixString(16)).join()}',
        );
      });
    } catch (e) {
      debugPrint('Error subscribing to characteristic: $e');
    }
  }
}

class FitnessDeviceScreen extends StatefulWidget {
  const FitnessDeviceScreen({super.key});

  @override
  State<FitnessDeviceScreen> createState() => _FitnessDeviceScreenState();
}

class _FitnessDeviceScreenState extends State<FitnessDeviceScreen> {
  final ValueNotifier<int> _updateState = ValueNotifier(0);

  @override
  void dispose() {
    _updateState.dispose();
    super.dispose();
  }

  final BleService bleService = BleService();
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  List<BluetoothService>? services;
  bool isLoading = false;
  String? errorMessage;

  void scanDevices() async {
    isLoading = true;
    errorMessage = null;
    _updateState.value++;

    try {
      bleService.scanForDevices().listen((deviceList) {
        devices = deviceList;
        _updateState.value++;
      });
    } catch (e) {
      errorMessage = 'Error scanning devices: $e';
      _updateState.value++;
    } finally {
      isLoading = false;
      _updateState.value++;
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    isLoading = true;
    errorMessage = null;
    _updateState.value++;

    try {
      await bleService.connectToDevice(device);
      connectedDevice = device;
      _updateState.value++;
    } catch (e) {
      errorMessage = 'Error connecting to device: $e';
      _updateState.value++;
    } finally {
      isLoading = false;
      _updateState.value++;
    }
  }

  void discoverServices() async {
    if (connectedDevice == null) return;

    isLoading = true;
    errorMessage = null;
    _updateState.value++;

    try {
      services = await bleService.discoverServices(connectedDevice!);
    } catch (e) {
      errorMessage = 'Error discovering services: $e';
      _updateState.value++;
    } finally {
      isLoading = false;
      _updateState.value++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _updateState,
      builder: (context, _, __) {
        return Scaffold(
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : connectedDevice == null
              ? Column(
                  children: [
                    Image.network(
                      'https://imgs.search.brave.com/q4JIlDaa6LKAdQAfKEKdr2964OBHSdziKjpzTr3uf18/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/bW9zLmNtcy5mdXR1/cmVjZG4ubmV0L2hI/RGtVRHlVaExNdWZ2/SEZGdmNBMm4tMzIw/LTgwLmpwZw',
                    ),
                    s24,
                    ElevatedButton(
                      onPressed: scanDevices,
                      child: const Text('Scan for Devices'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return ListTile(
                            title: Text(
                              device.platformName.isNotEmpty
                                  ? device.platformName
                                  : 'Unknown Device',
                            ),
                            subtitle: Text(device.remoteId.toString()),
                            onTap: () => connectToDevice(device),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ElevatedButton(
                      onPressed: discoverServices,
                      child: const Text('Discover Services'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: services?.length ?? 0,
                        itemBuilder: (context, index) {
                          final service = services![index];
                          return ExpansionTile(
                            title: Text('Service: ${service.uuid}'),
                            children: service.characteristics.map((c) {
                              return ListTile(
                                title: Text('Characteristic: ${c.uuid}'),
                                onTap: () =>
                                    bleService.subscribeToCharacteristic(c),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
