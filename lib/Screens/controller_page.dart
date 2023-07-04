import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:websocket_universal/websocket_universal.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'setter_page.dart';

late String _ip;
late String _port;
List<int> _lastMessage = [0, 0, 0, 0, 0];
int _hlPressed = 0;
int _llPressed = 0;
late dynamic _bytesSocketHandler;
bool _brakes = false;

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  @override
  void initState() {
    _ip = B.box.get("Ip") ?? "192.168.137.1";
    _port = B.box.get("Port") ?? "8000";
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    connect();
    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Disposing webSocket:
    _bytesSocketHandler.close();
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
                        listener: (details) async {
                          // Most RIGHT returns 0.99 while most LEFT returns -0.99
                          _lastMessage[3] = details.x > 0 ? (details.x * 5).round() : 0;
                          _lastMessage[4] = details.x < 0 ? (-details.x * 5).round() : 0;
                          final bytesMessage =
                              utf8.encode("${_lastMessage.join()}$_hlPressed$_llPressed");
                          _brakes ? null : _bytesSocketHandler.sendMessage(bytesMessage);
                          B.stateChanged();
                        }),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            _brakes = !_brakes;
                            _lastMessage = _brakes ? [1, 0, 0, 0, 0] : [0, 0, 0, 0, 0];
                            final bytesMessage =
                                utf8.encode("${_lastMessage.join()}$_hlPressed$_llPressed");
                            _bytesSocketHandler.sendMessage(bytesMessage);
                            B.stateChanged();
                          },
                          child: _brakes
                              ? const Text("RELEASE BRAKES").tr()
                              : const Text("BRAKES").tr(),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            _hlPressed == 0 ? _hlPressed = 1 : _hlPressed = 0;
                            final bytesMessage =
                                utf8.encode("${_lastMessage.join()}$_hlPressed$_llPressed");
                            _bytesSocketHandler.sendMessage(bytesMessage);
                            B.stateChanged();
                          },
                          child: Text("HIGH LIGHTS".tr(),
                              style:
                                  TextStyle(color: _hlPressed == 1 ? Colors.red : B.theme.primary)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            _llPressed == 0 ? _llPressed = 1 : _llPressed = 0;
                            final bytesMessage =
                                utf8.encode("${_lastMessage.join()}$_hlPressed$_llPressed");
                            _bytesSocketHandler.sendMessage(bytesMessage);
                            B.stateChanged();
                          },
                          child: Text("LOW LIGHTS".tr(),
                              style:
                                  TextStyle(color: _llPressed == 1 ? Colors.red : B.theme.primary)),
                        )
                      ],
                    ),
                    Joystick(
                        mode: JoystickMode.vertical,
                        listener: (details) async {
                          // Most DOWN returns 0.99 while most UP returns -0.99
                          _lastMessage[1] = details.y < 0 ? (-details.y * 5).round() : 0;
                          _lastMessage[2] = details.y > 0 ? (details.y * 5).round() : 0;
                          final bytesMessage =
                              utf8.encode("${_lastMessage.join()}$_hlPressed$_llPressed");
                          _brakes ? null : _bytesSocketHandler.sendMessage(bytesMessage);
                          B.stateChanged();
                        }),
                  ],
                )
              : const Text("Switch to landscape mode to use the controller")
        ],
      ),
    ),
  );
}

connect() async {
  var websocketConnectionUri = 'ws://$_ip:$_port'
      '/websocket';
  const connectionOptions = SocketConnectionOptions(
      timeoutConnectionMs: 4000, // fail timeout after 4000 ms
      skipPingMessages: true,
      pingRestrictionForce: true);

  final IMessageProcessor<List<int>, List<int>> bytesSocketProcessor = SocketSimpleBytesProcessor();
  _bytesSocketHandler = IWebSocketHandler<List<int>, List<int>>.createClient(
    websocketConnectionUri, // Local ws server
    bytesSocketProcessor,
    connectionOptions: connectionOptions,
  );

  // Connecting to server:
  await _bytesSocketHandler.connect();
}
