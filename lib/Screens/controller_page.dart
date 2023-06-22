import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:websocket_universal/websocket_universal.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'setter_page.dart';

TextEditingController _ipController = TextEditingController();
TextEditingController _portController = TextEditingController();
bool _hlPressed = false;
bool _llPressed = false;
late dynamic _bytesSocketHandler;

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  @override
  void initState() {
    _ipController.text = B.box.get("Ip") ?? "192.168.137.1";
    _portController.text = B.box.get("Port") ?? "8000";
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {},
      builder: (context, state) {
        B.theme = Theme.of(context).colorScheme;
        return ColoredBox(
          color: Colors.white,
          child: theScaffold(
            context: context,
          ),
        );
      },
    );
  }
}

Widget theScaffold({required BuildContext context, numDevices}) {
  return Scaffold(
    appBar: AppBar(
      title: Text("ControllerTitle".tr()),
      backgroundColor: B.theme.onPrimary,
    ),
    body: Padding(
      padding: const EdgeInsets.all(33.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Joystick(
                        mode: JoystickMode.horizontal,
                        listener: (details) {
                          // Most RIGHT returns 0.99 while most LEFT returns -0.99
                        }),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("BRAKES"),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("STOP CAR"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _hlPressed = !_hlPressed;
                            B.stateChanged();
                          },
                          child: Text("HIGH LIGHTS",
                              style: TextStyle(color: _hlPressed ? Colors.red : B.theme.primary)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _llPressed = !_llPressed;
                            B.stateChanged();
                          },
                          child: Text("LOW LIGHTS",
                              style: TextStyle(color: _llPressed ? Colors.red : B.theme.primary)),
                        )
                      ],
                    ),
                    Joystick(
                        mode: JoystickMode.vertical,
                        listener: (details) {
                          // Most DOWN returns 0.99 while most UP returns -0.99
                        }),
                  ],
                )
              : const Text("Switch to landscape mode to use the controller")
        ],
      ),
    ),
  );
}

Color getStatusColor(status) {
  Color color;
  status == "connected"
      ? color = Colors.green
      : status == "disconnected"
          ? color = Colors.red
          : color = B.theme.onBackground;
  return color;
}
