import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/text_title.dart';
import '../constants.dart';
import 'components/app_container.dart';
import 'components/custom_content_dialog.dart';
import 'components/custom_dialog_box.dart';
import 'components/filters.dart';
import 'components/sk_loader.dart';
import 'components/text_desc.dart';
import 'cubits/controller.dart';
import 'database/realm.dart';
import 'objects/location_object.dart';
import 'package:fluttericon/font_awesome_icons.dart';

var mainColorApp = rpnAccentBlue;

class ConsultationScreen extends StatefulWidget {
  final item;
  final app;
  const ConsultationScreen({Key? key, required this.item, String? this.app})
      : super(key: key);

  @override
  _ConsultationScreen createState() => _ConsultationScreen();
}

class _ConsultationScreen extends State<ConsultationScreen> {
  final Controller cget = Get.put(Controller());
  final RiveAnimationController _controller = OneShotAnimation(
    'active',
    autoplay: true,
  );
  var setProviders = [];
  //var cantResult = 0;
  List<String> search = [];
  List countries = [];
  List<String> searchName = [];
  List<LocationObject> _searchResult = [];
  List<LocationObject> _searchResultState = [];
  List<LocationObject> _searchResult0 = [];
  late Position position;

  final TextEditingController myController = TextEditingController();
  final TextEditingController myController3 = TextEditingController();
  final TextEditingController myController4 = TextEditingController();
  final myController2 = TextEditingController();
  final FocusNode _textNode = FocusNode();
  var expandedList = false;
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //cget.getCountries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //cget.resultByType.clear();
      //cget.cantResult(0);
      cget.getProviders("-1-", 50);
      /* Future.delayed(const Duration(seconds: 1), () {
        if (!cget.loadingProviders.value) {
          cget.getProviders("-1-", 50);
        }
      }); */
    });
    //getSetProviders();
  }

  onSearchTextChanged() async {
    if (search.isEmpty) {
      _searchResult = [];
      _searchResult0 = [];
      myController.text = '';
      cget.cantResult(cget.resultByType.length);
      setState(() {});
      return;
    }
    var p = [];
    for (var element in search) {
      p.add('(?=.*$element)');
      //p.add(RegExp('^(?=.*"$element").*\$'));
    }
    var e = p.join("");
    var regex = RegExp("^$e.*\$", caseSensitive: false, multiLine: true);
    _searchResult = [];
    for (var element in cget.resultByType) {
      var k = jsonEncode(element);
      if (regex.hasMatch(k)) {
        _searchResult.add(element);
      }
    }
    cget.cantResult(_searchResult.length);
    if (_searchResult.isEmpty) {
      showToast("No se encontraron resultados", context);
    }
    myController.text = '';
    myController.clearComposing();
    setState(() {});
  }

  onSearchTextChangedName(String option) {
    if (option.isEmpty) {
      onSearchTextChanged();
      return;
    }
    if (search.isEmpty) {
      _searchResult = [];
      var x = cget.resultByType.where((element) =>
          element.idProvider!.name!.contains(option.toUpperCase()) ||
          element.fullAddress!
              .replaceAll('ª', '')
              .replaceAll('º', '')
              .contains(option.toUpperCase()));
      _searchResult.addAll(x);
    } else {
      _searchResult0 = [];
      var x = _searchResult.where((element) =>
          element.idProvider!.name!.contains(option.toUpperCase()) ||
          element.fullAddress!
              .replaceAll('ª', '')
              .replaceAll('º', '')
              .contains(option.toUpperCase()));
      _searchResult0.addAll(x);
      _searchResult = _searchResult0;
    }
    _searchResult.sort((a, b) {
      double d1 = a.distance;
      double d2 = b.distance;
      if (d1 > d2) {
        return 1;
      } else if (d1 < d2) {
        return -1;
      } else {
        return 0;
      }
    });
    cget.cantResult(_searchResult.length);
    setState(() {});
  }

  onSearchTextChangedState(String option) {
    if (option.length == 2) {
      onSearchTextChanged();
      return;
    }
    if (option.length >= 3) {
      if (search.isEmpty) {
        _searchResultState = _searchResult;
        var x = cget.resultByType.where((element) =>
            element.idProvider!.name!.contains(option.toUpperCase()) ||
            element.fullAddress!
                .replaceAll('ª', '')
                .replaceAll('º', '')
                .contains(option.toUpperCase()));
        _searchResult.addAll(x);
      } else {
        _searchResult0 = [];
        var x = _searchResult.where((element) =>
            element.idProvider!.name!.contains(option.toUpperCase()) ||
            element.fullAddress!
                .replaceAll('ª', '')
                .replaceAll('º', '')
                .contains(option.toUpperCase()));
        _searchResult0.addAll(x);
        _searchResult = _searchResult0;
      }
      _searchResult.sort((a, b) {
        double d1 = a.distance;
        double d2 = b.distance;
        if (d1 > d2) {
          return 1;
        } else if (d1 < d2) {
          return -1;
        } else {
          return 0;
        }
      });
      cget.cantResult(_searchResult.length);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    //BlocProvider.of<CartCubit>(context).resetval();
    /* String myurl = Uri.base.toString(); //get complete url
    String? para1 =
        Uri.base.queryParameters["card"]; //get parameter with attribute "para1" */
    //print("PARAMETRO: $para1");
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

  _testStacked() {
    return AppContainerWoAppbar(
      title: "Consultas Medicas",
      appbar: AppBar(
        backgroundColor: widget.app == "RPN" ? Color(0xff5174B9) : kDefaultBlue,
        elevation: 10,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Center(
                child: TextTitle(
                  title: "${cget.cantResult.value} Médicos",
                  color: kTextWhiteColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 80, left: 20),
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
                  ? SkSliverLoader()
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
            color: widget.app == "RPN" ? Color(0xff5174B9) : kDefaultBlue,
          ),
          onChanged: (Country? newValue) async {
            cget.dropdownValue[0] = newValue!;
            print(newValue.providerCodes);
            await cget.getSetProviders([newValue.providerCodes!], "");
            cget.getProviders("-1-", 50);
            //cget.startCompute(newValue.providerCodes!, "-1-", 100);
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
                    buildSearchBox(context),
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
                cgetFilter.searchResult[index].idProvider!.specialty,
                cgetFilter.searchResult[index].idProvider!.subSpecialty));
      } else {
        items = List.generate(
            cgetFilter.searchResult.length,
            (index) => _miCard(
                index,
                cgetFilter.searchResult,
                cgetFilter.searchResult[index].idProvider!.specialty,
                cgetFilter.searchResult[index].idProvider!.subSpecialty));
      }
    }
    if (cgetFilter.searchResult.isEmpty || cgetFilter.search.isEmpty) {
      if (width >= 780.0) {
        items = List.generate(
            cget.resultByType.length,
            (index) => _miCardGrid(
                index,
                cget.resultByType,
                cget.resultByType[index].idProvider!.specialty,
                cget.resultByType[index].idProvider!.subSpecialty));
      } else {
        items = List.generate(
            cget.resultByType.length,
            (index) => _miCard(
                index,
                cget.resultByType,
                cget.resultByType[index].idProvider!.specialty,
                cget.resultByType[index].idProvider!.subSpecialty));
      }
    }
    //return SliverList(delegate: SliverChildListDelegate(items));
    return width < 780.0
        ? SliverList(
            delegate: SliverChildListDelegate(items),
          )
        : SliverGrid.extent(
            //crossAxisCount: width >= 800 && width <= 1000 ? 2 : 3,
            maxCrossAxisExtent: 500,
            //childAspectRatio: width >= 980 ? 1.0 : 1.0,
            children: items,
          );
  }

  Widget _miCard(
      index, List<LocationObject> listasp, List special, List subSpecial) {
    //final bloc = BlocProvider.of<CartCubit>(context);
    var tsp = special.length + subSpecial.length;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPaddin),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextTitle(
                        //Se escribe el nombre del proveedor
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
              padding: const EdgeInsets.only(bottom: 10.0),
              child: tsp < 5
                  ? _wrapSpecialties(special, subSpecial, index)
                  : ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 350,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50.0),
                                    topRight: Radius.circular(50.0),
                                  ),
                                ),
                                child: Center(
                                  child: _wrapSpecialties2(
                                      special, subSpecial, index),
                                ),
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentBlue, textStyle: wLabelStyle),
                      child: TextDesc(
                        title: "Ver las $tsp especialidades...",
                        color: kTextWhiteColor,
                      ),
                    ),
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: kDefaultPaddin, top: kDefaultPaddin),
                child: TextTitle(
                  title: listasp[index].fullAddress!,
                  color: chipColor,
                  lines: 4,
                )),
            const SizedBox(
              height: 20.0,
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
                  onPressed: () async {
                    launchWaze(
                        listasp[index].latitude!,
                        listasp[index].longitude!,
                        listasp[index].name!,
                        context);
                    /* var urlt = Uri.parse(
                        'https://waze.com/ul?q=${listasp[index].name}&ll=${listasp[index].latitude},${listasp[index].longitude}&navigate=yes');
                    // ignore: unrelated_type_equality_checks
                    if (canLaunchUrl(Uri.parse("waze://")) == true) {
                      urlt = Uri.parse(
                          'waze://waze.com/ul?q=${listasp[index].name}&ll=${listasp[index].latitude},${listasp[index].longitude}&navigate=yes');
                      var p = await launchUrl(urlt);
                      debugPrint(p);
                    } else {
                      var p = await launchUrl(urlt);
                    } */
                    /* launchUrlString(
                        'https://waze.com/ul?q=${listasp[index].name}&ll=${listasp[index].latitude},${listasp[index].longitude}&navigate=yes'); */
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
                      splashColor: rpnAccentBlue,
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
                        /* getContactById(listasp[index].id).then((value) => {
                              if (value.isNotEmpty)
                                {showDetailsContacts(listasp[index], value)}
                              else
                                {_showToast("No tiene Contactos disponibles")}
                            }); */
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

  Widget _miCardGrid(
      index, List<LocationObject> listasp, List special, List subSpecial) {
    //final bloc = BlocProvider.of<CartCubit>(context);
    var tsp = special.length + subSpecial.length;
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
          children: [
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
            /* const SizedBox(
              height: 10,
            ), */
            const Spacer(),
            tsp < 5
                ? _wrapSpecialties(special, subSpecial, index)
                : ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 350,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50.0),
                                  topRight: Radius.circular(50.0),
                                ),
                              ),
                              child: Center(
                                child: _wrapSpecialties2(
                                    special, subSpecial, index),
                              ),
                            );
                          });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentBlue, textStyle: wLabelStyle),
                    child: TextDesc(
                      title: "Ver las $tsp especialidades...",
                      color: kTextWhiteColor,
                    ),
                  ),
            const Spacer(),
            TextTitle(
              title: listasp[index].fullAddress!,
              lines: 4,
            ),
            const Spacer(),
            /* const SizedBox(
              height: 20,
            ), */
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
                  onPressed: () async {
                    launchWaze(
                        listasp[index].latitude!,
                        listasp[index].longitude!,
                        listasp[index].name!,
                        context);
                    /* launchUrlString(
                        'https://waze.com/ul?q=${listasp[index].name}&ll=${listasp[index].latitude},${listasp[index].longitude}&navigate=yes'); */
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
            /* const SizedBox(
              height: 10,
            ), */
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
                      splashColor: rpnAccentBlue,
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
                        /* getContactById(listasp[index].id).then((value) => {
                              if (value.isNotEmpty)
                                {showDetailsContacts(listasp[index])}
                              else
                                {_showToast("No tiene Contactos disponibles")}
                            }); */
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

  Widget _wrapSpecialties(List special, List subSpecial, int index) {
    return Wrap(
      spacing: 1.0,
      runSpacing: 5.0,
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: <Widget>[
        Wrap(
            alignment: WrapAlignment.start,
            direction: Axis.horizontal,
            runAlignment: WrapAlignment.start,
            children: List.generate(
                special.length, (index) => _chip(special[index]['alias']!))),
        Wrap(
            alignment: WrapAlignment.start,
            direction: Axis.horizontal,
            children: List.generate(subSpecial.length,
                (index) => _chip(subSpecial[index]['alias']!))),
      ],
    );
  }

  Widget _wrapSpecialties2(List special, List subSpecial, int index) {
    return Wrap(
      spacing: 2.0,
      runSpacing: 3.0,
      alignment: WrapAlignment.spaceBetween,
      direction: Axis.horizontal,
      children: <Widget>[
        Wrap(
            alignment: WrapAlignment.spaceBetween,
            direction: Axis.horizontal,
            //runAlignment: WrapAlignment.start,
            spacing: 2.0,
            runSpacing: 3.0,
            children: List.generate(
                special.length, (index) => _chip(special[index]['alias']!))),
        Wrap(
            alignment: WrapAlignment.spaceBetween,
            direction: Axis.horizontal,
            spacing: 2.0,
            runSpacing: 3.0,
            children: List.generate(
                subSpecial.length, (index) => _chip(subSpecial[index].alias!))),
      ],
    );
  }

  Widget _chip(String special) {
    var _isSelected = true;
    return FilterChip(
      elevation: 0.75,
      label: Text(
        special,
        textScaleFactor: 0.8,
        style: wLabelStyle,
      ),
      showCheckmark: false,
      selected: _isSelected,
      selectedColor: widget.app == "RPN" ? rpnAccentBlue : kDefaultBlue,
      onSelected: (bool selected) {
        setState(() {
          _isSelected = selected;
        });
      },
    );
  }

  void showDetails(int index, LocationObject listap) async {
    List c = await getCustomData("settingsOrms");
    var d = listap.idProvider!.code.toString().split("-");
    var f = c.firstWhere(
        (element) => element['strDescription'] == baseUrlProd)['value'];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
              title: "Detalle de direccion",
              descriptions: listap.idProvider!.name!,
              medic: listap,
              price: '',
              text: "Agregar al Carrito",
              img: FontAwesome.info);
        });
  }
}

void showDetailsSchedules(LocationObject listap, BuildContext context) async {
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultPaddin),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: CustomContentDialog(
                title: "${listap.idProvider!.name}",
                content: setupAlertDialoadContainer2(listap.schedule!),
                img: const Icon(
                  Icons.schedule_rounded,
                  color: kTextWhiteColor,
                  size: 40,
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        throw "test";
      });
}

void showDetailsContacts(LocationObject listap, BuildContext context) async {
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultPaddin),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              //title: TextTitle(title: '${listap.idProvider!.name}'),
              child: CustomContentDialog(
                title: '${listap.idProvider!.name}',
                content: setupAlertDialoadContainer(listap.contacts ?? []),
                img: const Icon(
                  Icons.phone_android_rounded,
                  color: kTextWhiteColor,
                  size: 40,
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        throw "test";
      });
}

Widget setupAlertDialoadContainer(List listap) {
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
                if (GetUtils.isEmail(
                    listap[index]['strDescription'] ?? "sin descripcion")) {
                  launchUrlString(
                      "mailto://${listap[index]['strDescription'] ?? "sin descripcion"}");
                } else {
                  launchUrlString(
                      "tel://${listap[index]['strDescription'] ?? "sin descripcion"}");
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? cardDarkBackground : cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
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
                        /* TextTitle(
                            title: listap[index]['idTypeContact']
                                    ['strDescription'] ??
                                "sin descripción"), */
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

showDetailsCopay(String name, BuildContext context) async {
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultPaddin),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: CustomContentDialog(
                title: name,
                content: CopayDialogDetail(),
                img: const Icon(
                  Icons.info_outline_rounded,
                  color: kTextWhiteColor,
                  size: 40,
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        throw "test";
      });
}

Widget setupAlertDialoadContainer2(List listap) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(8.0),
        height: 350,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: listap.length,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => {},
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: SizedBox(
                    height: 80,
                    width: 200,
                    child: TextTitle(
                      title:
                          listap[index]['strDescription'] ?? "sin descripción",
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
      )
    ],
  );
}

/* 
List res2 = res["resultInsuredPartipation"]["success"];
      await showDetailsCopay(item.idProvider!.name!, res2);

 */

class CopayDialogDetail extends StatelessWidget {
  const CopayDialogDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller cget = Get.put(Controller());
    return Obx(() {
      if (cget.resultPrice.isEmpty) {
        return Container();
      } else {
        return Column(children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cget.resultPrice.length,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(kDefaultPaddin),
              itemBuilder: (BuildContext context, index) {
                return Container(
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
                    child: Column(
                      children: [
                        TextTitle(
                          title: cget.resultPrice[index]["type"],
                          scale: 1.0,
                        ),
                        TextTitle(
                          title: cget.resultPrice[index]["description"],
                          scale: 1.0,
                        ),
                      ],
                    ));
              },
            ),
          ),
        ]);
      }
    });
  }
}

/* 

TextTitle(
                              title: cget.resultPrice[index]["type"]
                                  ['strDescription']),
                          TextTitle(
                              title: cget.resultPrice[index]["description"])

 */
showToast(String mensaje, BuildContext context) {
  /* Get.snackbar("", "",
      messageText: TextDesc(
        title: mensaje,
        color: kTextWhiteColor,
      ),
      icon: const Icon(
        Icons.error_rounded,
        color: Colors.red,
      ),
      backgroundColor: const Color.fromRGBO(0, 58, 112, .5),
      snackPosition: SnackPosition.TOP); */
  showDialog(
      context: context,
      builder: (context) => ContentDialogGet(mensaje: mensaje));
  /* Get.dialog(
    ContentDialogGet(mensaje: mensaje),
  ); */
}

class ContentDialogGet extends StatelessWidget {
  final String mensaje;
  const ContentDialogGet({
    Key? key,
    required this.mensaje,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        // height: 200,
        padding: const EdgeInsets.only(
            left: kDefaultPaddin,
            top: kDefaultPaddin,
            right: kDefaultPaddin,
            bottom: kDefaultPaddin),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Get.isDarkMode ? cardDarkBackground : kTextWhiteColor,
            borderRadius: BorderRadius.circular(kDefaultPaddin),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ]),
        child: Material(
          color: Colors.transparent,
          child: TextTitle(
            title: mensaje,
            lines: 10,
            align: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
