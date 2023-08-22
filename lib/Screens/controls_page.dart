import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:websocket_universal/websocket_universal.dart';
import 'package:adas/Cubit/ble_cubit.dart';
import 'controller_page.dart';
import 'setter_page.dart';
import 'settings_page.dart';

TextEditingController _ipController = TextEditingController();
TextEditingController _portController = TextEditingController();
String _status = "disconnected";
List<int> _msg = [48, 48, 48, 48, 48, 48, 48];
bool _connected = false;
late dynamic _bytesSocketHandler;

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  void initState() {
    _ipController.text = C.box.get("Ip") ?? "192.168.137.1";
    _portController.text = C.box.get("Port") ?? "8000";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        C.theme = Theme.of(context).colorScheme;
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
    appBar: AppBar(toolbarHeight: 0),
    body: SamsungUiScrollEffect(
        expandedTitle: Text("ControlTitle".tr(), style: const TextStyle(fontSize: 32)),
        collapsedTitle: Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 0),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 40.0, right: 50.0, top: C.lang == "ar" ? 6 : 0),
                child: Text(
                  "ControlTitle".tr(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor:
            C.brightness == Brightness.light ? C.theme.background : C.theme.surfaceVariant,
        elevation: 1,
        expandedHeight: 300,
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const ControllerPage())),
              icon: const Icon(
                Icons.games,
              )),
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const SettingsPage())),
              icon: const Icon(
                Icons.settings,
              ))
        ],
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 35,
                        child: TextField(
                          controller: _ipController,
                        ),
                      ),
                      const Text(":", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 60,
                        height: 35,
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: _portController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: _connected
                              ? () async {
                                  // Disconnecting from server:
                                  await _bytesSocketHandler.disconnect('manual disconnect');
                                  // Disposing webSocket:
                                  _bytesSocketHandler.close();
                                  _connected = false;
                                  _msg = [48, 48, 48, 48, 48, 48, 48];
                                  C.stateChanged();
                                }
                              : () async {
                                  _ipController.text == C.box.get("Ip")
                                      ? null
                                      : C.box.put("Ip", _ipController.text);
                                  _portController.text == C.box.get("Port")
                                      ? null
                                      : C.box.put("Port", _portController.text);
                                  var websocketConnectionUri =
                                      'ws://${_ipController.text}:${_portController.text}'
                                      '/websocket';
                                  const connectionOptions = SocketConnectionOptions(
                                      timeoutConnectionMs: 4000, // fail timeout after 4000 ms
                                      skipPingMessages: true,
                                      pingRestrictionForce: true);

                                  final IMessageProcessor<List<int>, List<int>>
                                      bytesSocketProcessor = SocketSimpleBytesProcessor();
                                  _bytesSocketHandler =
                                      IWebSocketHandler<List<int>, List<int>>.createClient(
                                    websocketConnectionUri, // Local ws server
                                    bytesSocketProcessor,
                                    connectionOptions: connectionOptions,
                                  );
                                  // Listening to debug events inside webSocket
                                  _bytesSocketHandler.logEventStream.listen((debugEvent) {
                                    // ignore: avoid_print
                                    _status = debugEvent.status.value;
                                    _status == "connected" ? _connected = true : _connected = false;
                                    if (kDebugMode) {
                                      print('> debug event: ${debugEvent.socketLogEventType}'
                                          ' ping=${debugEvent.pingMs} ms. '
                                          'Debug message=${debugEvent.message}');
                                    }
                                    C.stateChanged();
                                  });

                                  // Listening to server responses:
                                  _bytesSocketHandler.incomingMessagesStream.listen((inMsg) {
                                    inMsg.length >= 5 ? _msg = inMsg : null;
                                    if (kDebugMode) {
                                      print('> webSocket  got bytes message from server: "$inMsg"');
                                    }
                                  });

                                  // Listening to outgoing messages:
                                  _bytesSocketHandler.outgoingMessagesStream.listen((inMsg) {
                                    if (kDebugMode) {
                                      print('> webSocket sent bytes message to   server: "$inMsg"');
                                    }
                                    C.stateChanged();
                                  });

                                  // Connecting to server:
                                  final isBytesSocketConnected =
                                      await _bytesSocketHandler.connect();
                                  if (!isBytesSocketConnected) {
                                    if (kDebugMode) {
                                      print('Connection to [$websocketConnectionUri] '
                                          'for bytesSocketHandler '
                                          'failed for some reason!');
                                    }
                                    return;
                                  }
                                },
                          child: _connected
                              ? Text("Disconnect".toUpperCase().tr())
                              : Text("Connect".toUpperCase().tr()),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text("Status".tr()),
                    const Text(": "),
                    Text(
                      _status.toUpperCase().tr(),
                      style: TextStyle(color: getStatusColor(_status)),
                    ),
                  ],
                ),
                Stack(alignment: Alignment.bottomRight, children: [
                  Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Icon(
                            Icons.arrow_circle_up_outlined,
                            size: 40,
                            color: (_msg[1] - 48) > 0
                                ? Colors.green.withOpacity((_msg[1] - 48) / 5)
                                : C.theme.onBackground,
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.arrow_circle_left_outlined,
                                  size: 40,
                                  color: (_msg[4] - 48) > 0
                                      ? Colors.green.withOpacity((_msg[4] - 48) / 5)
                                      : C.theme.onBackground)),
                          Stack(
                            children: [
                              SvgPicture.asset(
                                "assets/images/car.svg",
                                colorFilter: ColorFilter.mode(
                                    (_msg[0] - 48) == 1 ? Colors.red : C.theme.onBackground,
                                    BlendMode.srcIn),
                                height: 200,
                              ),
                              SvgPicture.asset(
                                "assets/images/headlight.svg",
                                colorFilter: ColorFilter.mode(
                                    _msg.length == 7
                                        ? (_msg[5] - 48) > 0
                                            ? (_msg[6] - 48) > 0
                                                ? Colors.green
                                                : C.theme.primary
                                            : (_msg[6] - 48) > 0
                                                ? Colors.yellow
                                                : (_msg[0] - 48) == 1
                                                    ? Colors.red
                                                    : C.theme.onBackground
                                        : (_msg[0] - 48) == 1
                                            ? Colors.red
                                            : C.theme.onBackground,
                                    BlendMode.srcIn),
                                height: 200,
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.arrow_circle_right_outlined,
                                  size: 40,
                                  color: (_msg[3] - 48) > 0
                                      ? Colors.green.withOpacity((_msg[3] - 48) / 5)
                                      : C.theme.onBackground)),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Icon(Icons.arrow_circle_down,
                              size: 40,
                              color: (_msg[2] - 48) > 0
                                  ? Colors.green.withOpacity((_msg[2] - 48) / 5)
                                  : C.theme.onBackground)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 5),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 90,
                          width: 90,
                          child: AnimatedRadialGauge(

                              /// The animation duration.
                              duration: const Duration(seconds: 1),
                              curve: Curves.elasticOut,
                              alignment: Alignment.bottomCenter,

                              /// Gauge value.
                              value: (_msg[1] - 48) != 1
                                  ? (_msg[1] - 48) > 0
                                      ? (_msg[1] - 48)
                                      : (_msg[2] - 48) > 0
                                          ? (_msg[2] - 48)
                                          : 0
                                  : 0,

                              /// Optionally, you can configure your gauge, providing additional
                              /// styles and transformers.
                              axis: GaugeAxis(
                                /// Provide the [min] and [max] value for the [value] argument.
                                min: 0,
                                max: 5,

                                /// Render the gauge as a 180-degree arc.
                                degrees: 200,

                                /// Set the background color and axis thickness.
                                style: GaugeAxisStyle(
                                  thickness: 12,
                                  background: C.theme.inversePrimary,
                                ),

                                progressBar: GaugeRoundedProgressBar(
                                  gradient: GaugeAxisGradient(
                                    colors: [C.theme.primary, C.theme.error],
                                  ),
                                ),

                                /// Define the pointer that will indicate the progress.
                                pointer: NeedlePointer(
                                  position: const GaugePointerPosition.center(offset: Offset(0, 8)),
                                  color: C.theme.onBackground,
                                  width: 10,
                                  height: 35,
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              "${"Speed".tr()}: ${(_msg[1] - 48) != 1 ? (_msg[1] - 48) > 0 ? (_msg[1] - 48) : (_msg[2] - 48) > 0 ? -(_msg[2] - 48) : 0 : 0}"),
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          )
        ]),
  );
}

Color getStatusColor(status) {
  Color color;
  status == "connected"
      ? color = Colors.green
      : status == "disconnected"
          ? color = Colors.red
          : color = C.theme.onBackground;
  return color;
}
