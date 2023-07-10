import 'package:adas/Screens/setter_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'main_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final controller = PageController();
  bool isLastPage = false;
  bool lang = false;
  @override
  Widget build(BuildContext context) {
    B.theme = Theme.of(context).colorScheme;
    context.locale.toString() == "ar" ? lang = true : lang = false;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            PageView(
              onPageChanged: (index) {
                setState(() {
                  index == 3 ? isLastPage = true : isLastPage = false;
                });
              },
              controller: controller,
              children: [
                Container(
                  color: B.theme.background.withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 155.0),
                        child: SizedBox(
                            width: 300,
                            height: 300,
                            child: Center(
                              child: Lottie.asset(
                                'assets/animations/car.json',
                                frameRate: FrameRate(60),
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          textAlign: TextAlign.center,
                          "T6".tr(),
                          style: TextStyle(
                              color: B.theme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          textAlign: TextAlign.center,
                          "B1".tr(),
                          style: TextStyle(
                              color: B.theme.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: B.theme.background.withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 125),
                        child: SizedBox(
                          width: 350,
                          height: 350,
                          child: Lottie.asset(
                            'assets/animations/bluetooth.json',
                            frameRate: FrameRate(60),
                          ),
                        ),
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        "T7".tr(),
                        style: TextStyle(
                            color: B.theme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          textAlign: TextAlign.center,
                          "B2".tr(),
                          style: TextStyle(
                              color: B.theme.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: B.theme.background.withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 105),
                        child: SizedBox(
                          width: 350,
                          height: 300,
                          child: Lottie.asset(
                            'assets/animations/controller.json',
                            fit: BoxFit.cover,
                            frameRate: FrameRate(60),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          textAlign: TextAlign.center,
                          "T8".tr(),
                          style: TextStyle(
                              color: B.theme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          textAlign: TextAlign.center,
                          "B3".tr(),
                          style: TextStyle(
                              color: B.theme.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: B.theme.background.withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: Lottie.asset(
                            'assets/animations/start.json',
                            fit: BoxFit.cover,
                            frameRate: FrameRate(60),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 0),
                        child: Text(
                          textAlign: TextAlign.center,
                          "T9".tr(),
                          style: TextStyle(
                              color: B.theme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          textAlign: TextAlign.center,
                          "",
                          style: TextStyle(
                              color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: SizedBox(
                            height: 60,
                            width: 300,
                            child: ElevatedButton(
                              child: const Text("Start").tr(),
                              onPressed: () async {
                                B.box.put("showHome", true);
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const MainPage()));
                              },
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    lang = !lang;
                    context.setLocale(Locale(lang ? 'ar' : 'en'));
                  });
                },
                child: CircleAvatar(
                  backgroundColor: B.theme.surfaceVariant,
                  child: lang
                      ? Text(
                          "عر",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19, color: B.theme.primary),
                        )
                      : Text("En",
                          style: TextStyle(fontWeight: FontWeight.bold, color: B.theme.primary)),
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? null
          : Container(
              color: B.theme.surfaceVariant,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  TextButton(
                    child: Text(
                      "Skip".tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 20, color: B.theme.primary),
                    ),
                    onPressed: () => controller.jumpToPage(3),
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: 4,
                      effect: WormEffect(
                          activeDotColor: B.theme.primary, dotHeight: 5, dotWidth: 10, spacing: 5),
                    ),
                  ),
                  TextButton(
                    child: Text("Next".tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20, color: B.theme.primary)),
                    onPressed: () => controller.nextPage(
                        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                  )
                ]),
              ),
            ),
    );
  }
}
