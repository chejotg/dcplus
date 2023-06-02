import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/sk_loader.dart';
import '../objects/location_object.dart';
import 'components/app_container.dart';
import 'components/filters.dart';
import 'components/text_title.dart';
import 'constants.dart';
import 'consultation_screen.dart';
import 'cubits/controller.dart';

class ProviderListScreen extends StatefulWidget {
  final String type;
  final String title;
  final String icon;
  final item;
  final app;
  const ProviderListScreen(
      {Key? key,
      required this.type,
      required this.title,
      required this.icon,
      required this.item,
      String? this.app})
      : super(key: key);

  @override
  _ProviderListScreenState createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final Controller cget = Get.put(Controller());

  var setProviders = [];
  List<String> search = [];
  List<String> searchName = [];
  //List<LocationObject> lista = [];
  List<LocationObject> _searchResult = [];
  List<LocationObject> _searchResult0 = [];
  var specialty = "";
  String type = "0";
  var idProviders = [];
  var expandedList = false;
  final myController2 = TextEditingController();
  final myController = TextEditingController();
  final TextEditingController myController3 = TextEditingController();
  final TextEditingController myController4 = TextEditingController();
  final FocusNode _textNode = FocusNode();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    type = widget.type;
    if (widget.icon.contains(";")) {
      type = widget.icon;
    }
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      cget.resultByType.clear();
      cget.cantResult(0);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!cget.loadingProviders.value) {
          cget.getProviders(type, 50);
        }
      });
    }); */
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.app) {
      case "ATLANTIDA":
        mainColorApp = Colors.red;
        break;
      case "ASSA":
        mainColorApp = kDefaultBlue;
        break;
      case "RPN":
        mainColorApp = rpnAccentBlue;
        break;
      default:
        mainColorApp = rpnAccentBlue;
    }
    return _testStacked();
  }

  bool isDarkMode() {
    final darkMode = WidgetsBinding.instance.window.platformBrightness;
    if (darkMode == Brightness.dark) {
      return true;
    } else {
      return false;
    }
  }

  _testStacked() {
    //widget.title
    return AppContainerWoAppbar(
      title: widget.title,
      appbar: AppBar(
        backgroundColor: mainColorApp,
        elevation: 10,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Center(
                child: TextTitle(
                  title: "${cget.cantResult.value} Proveedores",
                  color: kTextWhiteColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 80),
            child: dropdown(),
          )
        ],
      ),
      child: Scaffold(
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                //shrinkWrap: true,
                //physics: const NeverScrollableScrollPhysics(),
                children: [
                  expansionFilter(),
                  const Padding(
                    padding: EdgeInsets.only(
                        bottom: kDefaultPaddin, top: kDefaultPaddin),
                    child: SearchChip(),
                  ),
                ],
              ),
            ),
            Obx(() {
              return cget.resultByType.isEmpty
                  ? const SkSliverLoader()
                  : _listMed(context, MediaQuery.of(context).size.width);
            }),
          ],
        ),
      ),
    );
  }

  Widget dropdown() {
    return Obx(() {
      if (cget.countries.isEmpty || cget.defaultCountry.isEmpty) {
        return Container();
      } else {
        return DropdownButton<Country>(
          value: cget.dropdownValue.isEmpty
              ? cget.defaultCountry[0]
              : cget.dropdownValue[0],
          hint: const Text(
            "Seleccione su país.",
            style: TextStyle(color: kTextColor),
          ),
          elevation: 16,
          style: const TextStyle(color: Colors.white),
          underline: Container(
            height: 2,
            color: mainColorApp,
          ),
          onChanged: (Country? newValue) async {
            cget.dropdownValue[0] = newValue!;
            print(newValue.providerCodes!);
            await cget.getSetProviders([newValue.providerCodes!], "");
            cget.getProviders(widget.type, 100);
            //cget.startCompute(newValue.providerCodes!, widget.type, 100);
          },
          selectedItemBuilder: (BuildContext context) {
            return cget.countries.map<Widget>((item) {
              return Center(
                child: Text(
                  item.strDescription!,
                  style: const TextStyle(color: kTextWhiteColor),
                ),
              );
            }).toList();
          },
          items: cget.countries.map((value) {
            return DropdownMenuItem<Country>(
              value: value,
              child: Text(
                value.strDescription!,
                style: const TextStyle(color: kTextColor),
              ),
            );
          }).toList(),
        );
      }
    });
  }

  String currentText = "";
  Widget expansionFilter() {
    return ExpansionPanelList(
      animationDuration: const Duration(milliseconds: 1000),
      dividerColor: Colors.red,
      elevation: 1,
      children: [
        ExpansionPanel(
          canTapOnHeader: true,
          body: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GridView(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 480,
                      childAspectRatio: 5.5,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2),
                  shrinkWrap: true,
                  children: [
                    buildSearchBoxName(context),
                  ],
                ),
              ],
            ),
          ),
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(
                        left: kDefaultPaddin, right: kDefaultPaddin),
                    child: Icon(Icons.filter_alt_rounded),
                  ),
                  Text(
                    "Filtros de Búsqueda",
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: rpnAccentBlue,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            );
          },
          isExpanded: expandedList,
        )
      ],
      expansionCallback: (int item, bool status) {
        setState(() {
          expandedList = !expandedList;
        });
      },
    );
  }

  _listMed(BuildContext context, double width) {
    List<Widget> items = [];
    if (cgetFilter.searchResult.isNotEmpty || cgetFilter.search.isNotEmpty) {
      if (width >= 780.0) {
        items = List.generate(
            cgetFilter.searchResult.length,
            (index) => _miCardGrid(
                  index,
                  cgetFilter.searchResult,
                ));
      } else {
        items = List.generate(
            cgetFilter.searchResult.length,
            (index) => _miCard(
                  index,
                  cgetFilter.searchResult,
                ));
      }
    }
    if (cgetFilter.searchResult.isEmpty || cgetFilter.search.isEmpty) {
      if (width >= 780.0) {
        items = List.generate(
            cget.resultByType.length,
            (index) => _miCardGrid(
                  index,
                  cget.resultByType,
                ));
      } else {
        items = List.generate(
            cget.resultByType.length,
            (index) => _miCard(
                  index,
                  cget.resultByType,
                ));
      }
    }
    //return SliverList(delegate: SliverChildListDelegate(items));
    return width < 780.0
        ? SliverList(
            delegate: SliverChildListDelegate(items),
          )
        : SliverGrid.extent(
            //crossAxisCount: width >= 800 && width <= 1000 ? 2 : 3,
            maxCrossAxisExtent: 485,
            childAspectRatio: 1.1,
            children: items,
          );
  }

  Widget _miCard(index, List<LocationObject> listasp) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPaddin),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextTitle(
                        title: listasp[index].idProvider!.name!,
                        scale: 1.25,
                      )),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: kDefaultPaddin, top: kDefaultPaddin),
                child: TextTitle(
                  title: listasp[index].fullAddress!,
                  color: chipColor,
                  lines: 4,
                )),
            //Spacer(),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rpnAccentBlue,
                    padding: const EdgeInsets.all(16.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    launchWaze(
                        listasp[index].latitude!,
                        listasp[index].longitude!,
                        listasp[index].name!,
                        context);
                  },
                  icon: const Icon(FontAwesomeIcons.waze),
                  label: const TextTitle(
                    title: "Waze",
                    color: kTextWhiteColor,
                    scale: 1.0,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rpnAccentBlue,
                    padding: const EdgeInsets.all(kDefaultPaddin),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: TextTitle(
                    scale: 1.0,
                    color: kTextWhiteColor,
                    title:
                        'Distancia ${listasp[index].distance.toStringAsFixed(2)} KM',
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
<<<<<<< Updated upstream
                widget.app == "RPN"
=======
                widget.app != "ASSA"
>>>>>>> Stashed changes
                    ? Card(
                        color: providerBtnBlue,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Material(
                          color: Colors.transparent, // button color
                          child: InkWell(
                            splashColor: rpnAccentBlue, // inkwell color
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: const [
                                  Icon(
                                    CupertinoIcons.creditcard,
                                    color: providericonBlue,
                                    size: 40,
                                  ),
                                  TextTitle(
                                    title: "Copagos",
                                    scale: 0.8,
                                    color: providericonBlue,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              cget.mPrice(listasp[index], context);
                              showDetailsCopay(
                                  listasp[index].idProvider!.name!, context);
                            },
                          ),
                        ),
                      )
                    : Container(),
                Card(
                  elevation: 10,
                  color: providerBtnBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Material(
                    color: Colors.transparent, // button color
                    child: InkWell(
                      splashColor: rpnAccentBlue, // inkwell color
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: const [
                            Icon(
                              CupertinoIcons.clock,
                              color: providericonBlue,
                              size: 40,
                            ),
                            TextTitle(
                              title: "Horarios",
                              scale: 0.8,
                              color: providericonBlue,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (listasp[index].schedule!.isNotEmpty) {
                          showDetailsSchedules(listasp[index], context);
                        } else {
                          showToast("No tiene Horarios disponibles", context);
                        }
                      },
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  color: providerBtnBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Material(
                    color: Colors.transparent, // button color
                    child: InkWell(
                      splashColor: rpnAccentBlue, // inkwell color
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.phone_iphone,
                              color: providericonBlue,
                              size: 40,
                            ),
                            TextTitle(
                              title: "Telefonos",
                              scale: 0.8,
                              color: providericonBlue,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (listasp[index].contacts!.isNotEmpty) {
                          showDetailsContacts(listasp[index], context);
                        } else {
                          showToast("No tiene Contactos disponibles", context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miCardGrid(index, List<LocationObject> listasp) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPaddin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          //shrinkWrap: false,
          //physics: const NeverScrollableScrollPhysics(),
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextTitle(
                        title: listasp[index].idProvider!.name!,
                        scale: 1.25,
                      )),
                ),
              ],
            ),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(
                    left: kDefaultPaddin, top: kDefaultPaddin),
                child: TextTitle(
                  title: listasp[index].fullAddress!,
                  color: chipColor,
                  lines: 4,
                )),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rpnAccentBlue,
                    padding: const EdgeInsets.all(16.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    launchWaze(
                        listasp[index].latitude!,
                        listasp[index].longitude!,
                        listasp[index].name!,
                        context);
                  },
                  icon: const Icon(FontAwesomeIcons.waze),
                  label: const TextTitle(
                    title: "Waze",
                    color: kTextWhiteColor,
                    scale: 1.0,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rpnAccentBlue,
                    padding: const EdgeInsets.all(kDefaultPaddin),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: TextTitle(
                    scale: 1.0,
                    color: kTextWhiteColor,
                    title:
                        'Distancia ${listasp[index].distance.toStringAsFixed(2)} KM',
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.app == "RPN"
                    ? Card(
                        color: providerBtnBlue,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Material(
                          color: Colors.transparent, // button color
                          child: InkWell(
                            splashColor: rpnAccentBlue, // inkwell color
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: const [
                                  Icon(
                                    CupertinoIcons.creditcard,
                                    color: providericonBlue,
                                    size: 40,
                                  ),
                                  TextTitle(
                                    title: "Copagos",
                                    scale: 0.8,
                                    color: providericonBlue,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              cget.mPrice(listasp[index], context);
                              showDetailsCopay(
                                  listasp[index].idProvider!.name!, context);
                            },
                          ),
                        ),
                      )
                    : Container(),
                Card(
                  elevation: 10,
                  color: providerBtnBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Material(
                    color: Colors.transparent, // button color
                    child: InkWell(
                      splashColor: rpnAccentBlue, // inkwell color
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: const [
                            Icon(
                              CupertinoIcons.clock,
                              color: providericonBlue,
                              size: 40,
                            ),
                            TextTitle(
                              title: "Horarios",
                              scale: 0.8,
                              color: providericonBlue,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (listasp[index].schedule!.isNotEmpty) {
                          showDetailsSchedules(listasp[index], context);
                        } else {
                          showToast("No tiene Horarios disponibles", context);
                        }
                      },
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  color: providerBtnBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Material(
                    color: Colors.transparent, // button color
                    child: InkWell(
                      splashColor: rpnAccentBlue, // inkwell color
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.phone_iphone,
                              color: providericonBlue,
                              size: 40,
                            ),
                            TextTitle(
                              title: "Telefonos",
                              scale: 0.8,
                              color: providericonBlue,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (listasp[index].contacts!.isNotEmpty) {
                          showDetailsContacts(listasp[index], context);
                        } else {
                          showToast("No tiene Contactos disponibles", context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget setupAlertDialoadContainer(List listap) {
    var isdark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: listap.length,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.all(kDefaultPaddin),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  if (GetUtils.isEmail(listap[index]['strDescription'])) {
                    launchUrlString("mailto:${listap[index]['strDescription']}",
                        mode: LaunchMode.externalApplication);
                  } else {
                    launchUrlString("tel://${listap[index]['strDescription']}");
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isdark ? cardDarkBackground : cardBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_android_rounded,
                            color: rpnAccentBlue,
                            size: MediaQuery.of(context).size.height * 0.03,
                          ),
                          TextTitle(
                              title: listap[index]['idTypeContact']
                                      ['strDescription'] ??
                                  "sin descripción"),
                          SizedBox(
                            width: 170,
                            child: TextTitle(
                                scale: 1.0,
                                lines: 2,
                                align: TextAlign.center,
                                title: listap[index]['strDescription'] ??
                                    "sin descripción"),
                          ),
                        ],
                        //onTap: () => {launch("tel://${listap[index]['strDescription']}")},
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget setupAlertDialoadContainer2(List listap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          width: 350,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: listap.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => {},
                child: Container(
                  width: 500,
                  margin: const EdgeInsets.only(bottom: 30),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: SizedBox(
                      height: 100,
                      width: 200,
                      child: TextTitle(
                        title: listap[index]['strDescription'] ??
                            "Sin descripción de horarios",
                        lines: 5,
                        align: TextAlign.center,
                      )),
                ),
              );
              /* ListTile(
            title: TextTitle(title: listap[index]['strDescription']),
          ); */
            },
          ),
        ),
      ],
    );
  }

  void showDetails(int index, LocationObject listap) async {
    /*  List c = await getCustomData("settingsOrms");
    var d = listap.idProvider!.code.toString().split("-");
    var f = c.firstWhere(
        (element) => element['strDescription'] == baseUrlProd)['value'];
    var url =
        "$f/v2/findPhisycianPrice?providerCountryCode=${d[0]}&providerType=${d[1]}&providerCode=${d[2]}&policyCountryCode=${d[0]}&policyCardNumber=502836158";
    String res = await getMethod(url, context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
              title:
                  "${json.decode(res)['resultPhisycianPrice']['iso']} ${json.decode(res)['resultPhisycianPrice']['total']}",
              descriptions: listap.idProvider!.name!,
              medic: listap,
              price: "${json.decode(res)['resultPhisycianPrice']['total']}",
              text: "Agregar al Carrito",
              img: FontAwesome.info);
        });
   */
  }
}
