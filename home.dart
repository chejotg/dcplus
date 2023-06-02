import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';

import 'package:flutter/material.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:providers/objects/location_object.dart';

import 'package:providers/provider_list_screen.dart';
import 'package:rive/rive.dart';

import 'components/text_title.dart';
import 'constants.dart';
import 'consultation_screen.dart';
import 'cubits/controller.dart';

var setProviders = "";
var cardData = "";
var countryData = "";

class HomeRpn extends StatefulWidget {
  final String setProvs;
  final String app;
  final String card;
  const HomeRpn(
      {Key? key, required this.setProvs, required this.app, required this.card})
      : super(key: key);

  @override
  State<HomeRpn> createState() => _HomeRpnState();
}

class _HomeRpnState extends State<HomeRpn> {
  Controller cget = Get.put(Controller());

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  void getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('', 'Location Permission Denied');
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    //bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    //setProviders = await getDataFromAdnroid();
    //cardData = await getcardfromAndroid();
    setProviders = setProviders == "" ? widget.setProvs : setProviders;
    cardData = cardData == "" ? widget.card : cardData;
    List p = cardData.split("-");
    if (p.isNotEmpty) {
      cget.dropdownValue.clear();
      cget.dropdownValue.add(Country(
          id: "0",
          code: p[0],
          iso: p[0],
          providerCodes: setproviders,
          strDescription: ""));
    }

    setProvidersList.clear();
    /* for (var element in jsonDecode(setproviders)) {
      setproviders = "$setproviders${element["code"]},";
      setProvidersList.add("${element["code"]}");
    }
    if (setproviders.isNotEmpty) {
      setproviders = setproviders.substring(0, setproviders.length - 1);
    } */
    widget.setProvs.split(",").forEach((element) {
      setProvidersList.add("$element");
    });

    cget.getSetProviders(setProvidersList, cardData.split("-")[0]);
    cget.getTypesOfP(widget.app, cardData);
    //cget.startCompute(widget.setProvs, "-1-", 70);
    //sincProvidersModule();
  }

  @override
  Widget build(BuildContext context) {
    final RiveAnimationController _controller = OneShotAnimation(
      'active',
      autoplay: true,
    );
    Color colorcardHome = rpnAccentBlue;
    switch (widget.app) {
      case "ATLANTIDA":
        colorcardHome = Colors.red;
        break;
      case "ASSA":
        colorcardHome = kDefaultBlue;
        break;
      case "RPN":
        colorcardHome = rpnAccentBlue;
        break;
      default:
    }
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (cget.result.isEmpty) {
            return Center(
              child: TextTitle(title: "Cargando la red de proveedores..."),
            );
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 200,
                  //childAspectRatio: 3.5,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2),
              shrinkWrap: true,
              itemCount: cget.result.length,
              itemBuilder: ((context, index) {
                return GestureDetector(
                  onTap: () {
                    cget.itemSelected(cget.result[index]);
                    if (cget.result[index]['filterOption'] == '1') {
                      Get.to(() => ConsultationScreen(
                            item: cget.result[index],
                            app: "RPN",
                          ));
                    } else {
                      if (cget.result[index]['icon'].contains(";")) {
                        cget.getProviders(cget.result[index]['icon'], 50);
                      } else {
                        cget.getProviders(
                            cget.result[index]['filterOption'], 50);
                      }
                      Get.to(() => ProviderListScreen(
                            type: cget.result[index]['filterOption'],
                            title: cget.result[index]['title'],
                            icon: cget.result[index]['icon'],
                            item: cget.result[index],
                            app: "RPN",
                          ));
                    }
                  },
                  child: Card(
                    color: (index % 2) == 0 ? lightAccentBlue : colorcardHome,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextTitle(
                            title: cget.result[index]['title'],
                            color: (index % 2) == 0
                                ? darkBlueCardBackground
                                : lightAccentBlue,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset(
                            'assets/rpn/${cget.result[index]['iconText']}.png',
                            fit: BoxFit.cover,
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }
        }),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final String app;
  const Home({Key? key, required this.app}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController _tabController;
  final Controller cget = Get.put(Controller());
  final Controller c = Get.put(Controller());

  /// Controller for playback
  final RiveAnimationController _controller = OneShotAnimation(
    'active',
    autoplay: true,
  );

  /// Is the animation currently playing?
  bool _isPlaying = true;
  @override
  void initState() {
    // TODO: implement initState
    getLocation();
    super.initState();
  }

  void getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('', 'Location Permission Denied');
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    //bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    await c.getCountries();
    c.getSetProviders(["506-1"], "");
    c.getTypesOfP("ASSA", "");
    //c.startCompute("506-1", "-1-", 70);
    //sincProvidersModule();
  }

  /* void getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('', 'Location Permission Denied');
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    //bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    //setProviders = await getDataFromAdnroid();
    //cardData = await getcardfromAndroid();
    setProviders = "506-1";
    cardData = "506-1";
    cget.dropdownValue.listen((p0) {
      setProvidersList.clear();
      c.getSetProviders(
          ["${p0[0].providerCodes}"], p0[0].providerCodes.toString());
      c.getTypesOfP(widget.app, p0[0].providerCodes.toString());
      setProvidersList.add(p0[0].providerCodes.toString());
    });
    await c.getCountries();
    List p = cardData.split("-");
    if (p.isNotEmpty) {
      cget.dropdownValue.clear();
      cget.dropdownValue.add(Country(
          id: "0",
          code: p[0],
          iso: p[0],
          providerCodes: setproviders,
          strDescription: ""));
    }

    /* for (var element in jsonDecode(setproviders)) {
      setproviders = "$setproviders${element["code"]},";
      setProvidersList.add("${element["code"]}");
    }
    if (setproviders.isNotEmpty) {
      setproviders = setproviders.substring(0, setproviders.length - 1);
    } */
    //cget.startCompute(widget.setProvs, "-1-", 70);
    //sincProvidersModule();
  } */

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [];
    List<TabItem> tabs = [];
    Color colorcardHome = rpnAccentBlue;
    switch (widget.app) {
      case "ATLANTIDA":
        colorcardHome = Colors.red;
        break;
      case "ASSA":
        colorcardHome = kDefaultBlue;
        break;
      case "RPN":
        colorcardHome = rpnAccentBlue;
        break;
      default:
    }
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (cget.result.isEmpty) {
            return LoaderAnim(controller: _controller);
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 200,
                  //childAspectRatio: 3.5,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2),
              shrinkWrap: true,
              itemCount: cget.result.length,
              itemBuilder: ((context, index) {
                return GestureDetector(
                  onTap: () {
                    cget.itemSelected(cget.result[index]);
                    if (cget.result[index]['filterOption'] == '1') {
                      Get.to(() => ConsultationScreen(
                            item: cget.result[index],
                            app: "ASSA",
                          ));
                    } else {
                      if (cget.result[index]['icon'].contains(";")) {
                        cget.getProviders(cget.result[index]['icon'], 50);
                      } else {
                        cget.getProviders(
                            cget.result[index]['filterOption'], 50);
                      }
                      Get.to(() => ProviderListScreen(
                            type: cget.result[index]['filterOption'],
                            title: cget.result[index]['title'],
                            icon: cget.result[index]['icon'],
                            item: cget.result[index],
                            app: "ASSA",
                          ));
                    }
                  },
                  child: Card(
                    color: (index % 2) == 0 ? lightAccentBlue : colorcardHome,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextTitle(
                            title: cget.result[index]['title'],
                            color: (index % 2) == 0
                                ? darkBlueCardBackground
                                : lightAccentBlue,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset(
                            'assets/rpn/${cget.result[index]['iconText']}.png',
                            fit: BoxFit.cover,
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }
        }),
      ),
    );

    /* AppContainerNoAppbar(
      title: "Busqueda de Proveedores",
      child: Obx(
        () {
          if (c.result.isNotEmpty) {
            _tabController = TabController(
                vsync: this, length: c.result.length, initialIndex: 0);
            for (var element in c.result) {
              if (element['filterOption'] == '1') {
                screens.add(ConsultationScreen(
                      item: element,
                      app: "RPN",
                    ));
              } else {
                /* screens.add(ProviderListScreen(
                  type: element['filterOption'],
                  title: element['title'],
                  icon: element['icon'],
                  item: element,
                  app: "RPN",
                )); */
              }
              if (tabs.length < c.result.length) {
                tabs.add(
                  TabItem(
                    color: kAccentBlue,
                    unselectedColor: kDefaultBlue,
                    title: Row(
                      children: [
                        Hero(
                          tag: element['title'],
                          child: Image.asset(
                            'assets/provider/${element['iconText']}.png',
                            fit: BoxFit.cover,
                            height: 40,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(element['title']),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          } else {
            screens = [];
            tabs = [];
          }
          return c.result.isEmpty
              ? LoaderAnim(controller: _controller)
              : tabContent(tabs, screens);
        },
      ),
    ); */
  }

  Widget tabContent(tabs, screens) {
    return Center(
      child: Column(
        children: [
          Container(
            color: kDefaultBlue,
            child: ColorfulTabBar(
              selectedHeight: 80,
              unselectedHeight: 50,
              indicatorHeight: 1,
              verticalTabPadding: 10.0,
              unselectedLabelColor: Colors.white30,
              labelStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              tabs: tabs,
              controller: _tabController,
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: screens.isNotEmpty
                ? screens
                : List.generate(4, (index) => _pageView(index)),
          ),
        ],
      ),
    );
  }

  Widget _pageView(int index) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(),
        ),
      ),
    );
  }

  Widget providerSwipe(BuildContext context, List typesOfProviders) {
    return Swiper(
      itemCount: typesOfProviders.length,
      itemWidth: 40,
      viewportFraction: 0.4,
      scale: 0.1,
      pagination: const SwiperPagination(builder: SwiperPagination.fraction),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: 150,
              width: 200,
              child: Hero(
                tag: typesOfProviders[index]['title'],
                child: Image.asset(
                  'assets/provider/${typesOfProviders[index]['iconText']}.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
                child: Text(
              typesOfProviders[index]['title'],
              style: kTitleStyleText,
            )),
          ],
        );
      },
      onTap: (index) {
        var stype = "";
        if (typesOfProviders[index]['storyboardId'].length > 1) {
          typesOfProviders[index]['storyboardId'].split(',').forEach((element) {
            stype = "-$element-";
          });
        } else {
          stype = "-${typesOfProviders[index]['storyboardId']}-";
        }
        switch (typesOfProviders[index]['storyboardId']) {
          case 'showProviders':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProviderListScreen(
                  type: typesOfProviders[index]['filterOption'],
                  title: typesOfProviders[index]['title'],
                  icon: typesOfProviders[index]['icon'],
                  item: typesOfProviders[index],
                ),
              ),
            );
            break;
          case 'showSpecialties':
            //c.startCompute("504-1", "-1-", 70);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ConsultationScreen(item: typesOfProviders[index])));
            break;
          default:
        }
      },
    );
  }

  Widget _buildCarousel(BuildContext context, typesOfProviders) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AspectRatio(
          // you may want to use an aspect ratio here for tablet support
          aspectRatio: 16 / 9,
          child: PageView.builder(
            // store this controller in a State to save the carousel scroll position
            itemCount: typesOfProviders.length,
            controller: PageController(viewportFraction: 0.5),
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(context, typesOfProviders[itemIndex]);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCarouselItem(BuildContext context, typesOfProviders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: GestureDetector(
          onTap: () {
            c.resultByType.clear();
            c.cantResult(0);
            c.loadingProviders(true);
            switch (typesOfProviders['storyboardId']) {
              case 'showProviders':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProviderListScreen(
                      type: typesOfProviders['filterOption'],
                      title: typesOfProviders['title'],
                      icon: typesOfProviders['icon'],
                      item: typesOfProviders,
                    ),
                  ),
                );
                break;
              case 'showSpecialties':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ConsultationScreen(
                              item: typesOfProviders,
                            )));
                break;
              default:
            }
          },
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
                width: 30,
                child: Image.asset(
                  'assets/provider/${typesOfProviders['iconText']}.png',
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                  child: Text(
                typesOfProviders['title'],
                style: kTitleStyleText,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class LoaderAnim extends StatelessWidget {
  final RiveAnimationController controller = OneShotAnimation(
    'active',
    autoplay: true,
  );
  LoaderAnim({
    Key? key,
    RiveAnimationController? controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: RiveAnimation.asset(
          'assets/iconspack.riv',
          artboard: 'map',
          controllers: [controller],
        ),
      ),
    );
  }
}

class fragment extends StatelessWidget {
  final item;
  final String type;
  const fragment({Key? key, required this.item, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(); /* type != 0
        ? ConsultationScreen(item: item)
        : ProviderListScreen(type: type, title: item['title'], item: item); */
  }
}
