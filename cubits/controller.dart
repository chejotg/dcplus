import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:providers/consultation_screen.dart';
import 'package:providers/database/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../objects/location_object.dart';

class Controller extends GetxController {
  var count = 0.obs;
  var cantResult = 0.obs;
  List<LocationObject> pl = [];
  RxList<Country> countries = <Country>[].obs;
  var result = [].obs;
  var itemSelected = {}.obs;
  var dropdownValue = <Country>[].obs;
  var defaultCountry = <Country>[].obs;
  var providerCodes = "".obs;
  var resultPrice = [].obs;
  var loadingProviders = false.obs;
  var setProvidersList = [];
  RxList<LocationObject> resultByType = <LocationObject>[].obs;
  increment() => count++;

  getTypesOfP(String s, String card) async {
    var cd = card == "" ? "506" : card.split("-")[0];
    getTypesOfProviders(s, cd).then((value) {
      result.clear();
      result.addAll(value);
    });
  }

  /* getSetProviders(String codes, String ctry) async {
    List prov = [];
    prov.addAll(codes.split(","));
    var resProv = await setProviders(prov, ctry);
    List lista = await resProv.data!['setProviderOrms'];
    var result = await bigTask(lista);
    saveCustomData("setProviders", json.encode(result));
  } */
  getSetProviders(List codes, String ctry) async {
    resultByType.clear();
    cantResult.value = 0;
    var resProv =
        await getProvidersBySet(codes, ctry); //await setProviders(prov, ctry);
    //List lista = json.decode(resProv); //await resProv.data!['setProviderOrms'];
    //var result = bigTask(lista);
    saveCustomData("setProviders", jsonEncode(resProv));
  }

  /* startCompute(String codes, String type, int cSize) async {
    resultByType.clear();
    cantResult(0);
    loadingProviders(true);
    //print("setproviders: startCOmpute: $codes");
    //saveCustomData("setProviders", codes);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List prov = [];
    var ctry = "";
    var card = "";
    if (dropdownValue.isNotEmpty) {
      ctry = dropdownValue[0].code!;
    } else {
      card = prefs.getString("cardNumber") ?? "";
      ctry = card.split("-")[0];
    } //var ctry = dropdownValue[0].code!;

    prov.addAll(codes.split(","));
    //compute(bigTask, lista);
    /* saveCustomData(
        "settingsOrms", json.encode(resProv.data!['settingsOrmProds'])); */
    loadingProviders(false);
    getProviders(type, cSize);
    //getTypesOfP();
  } */

  List bigTask(List counters) {
    List provider = [];
    for (var setP in counters) {
      //provider.addAll(setP["provider"]);
      for (var prov in setP["provider"]) {
        provider.add(prov['code']);
        /*  if (prov['name'].toString().contains('CEDEÑO')) {
          print("found: ${prov['_id']}, ${prov['code']}, ${prov['name']}");
        }  */
      }
    }
    return provider;
  }

  getProviders(String type, int cSize) async {
    resultByType.clear();
    cantResult.value = 0;
    List<LocationObject> q = [];
    List c = await getCustomData("setProviders");
    var stype = "";
    if (type.length > 10 && type.contains(";")) {
      type.split(';').forEach((tpeprov) {
        stype = tpeprov;
        var p = c.where((element) =>
            LocationObject.fromJson(element).code!.contains(stype));
        if (p.isNotEmpty) {
          for (var element in p) {
            q.add(LocationObject.fromJson(element));
          }
        }
      });
    } else {
      if (type.length > 1 && type.contains(",")) {
        type.split(',').forEach((tpeprov) {
          stype = "-$tpeprov-";
          var p = c.where((element) => LocationObject.fromJson(element)
              .code!
              .contains("${dropdownValue[0].code}$stype"));
          if (p.isNotEmpty) {
            for (var element in p) {
              q.add(LocationObject.fromJson(element));
            }
          }
        });
      } else {
        stype = "-$type-";
        if (type.contains("-")) {
          stype = type;
        }
        print(dropdownValue[0].code);
        var p = c.where((element) {
          return LocationObject.fromJson(element)
              .code!
              .contains("${dropdownValue[0].code}$stype");
        });
        for (var element in p) {
          q.add(LocationObject.fromJson(element));
        }
      }
    }

    /* var chunkSize = 70;
    if (stype.contains("4")) {
      chunkSize = 1;
    }
    for (var i = 0; i < q.length; i += chunkSize) {
      chunks.add(
          q.sublist(i, i + chunkSize > q.length ? q.length : i + chunkSize));
    }
    List<LocationObject> result = await getAllInforProviders(q, q); */

    resultByType(q);
    cantResult.value = q.length;
    cantResult.refresh();
  }

  getCountries() async {
    var p = await getCountriesOfProviders();
    countries.clear();
    p.forEach((element) {
      countries.add(Country(
          id: element['_id'],
          code: element['code'],
          iso: element['iso'],
          providerCodes: element['providerCodes'],
          strDescription: element['strDescription']));
    });
    var c = "Costa Rica"; //await getCountryName();
    var l = countries.firstWhereOrNull(
        (p0) => p0.strDescription!.toUpperCase().contains(c.toUpperCase()));
    //print(l!.strDescription!);
    defaultCountry.clear();
    dropdownValue.clear();
    var codes = countries[0].providerCodes!;
    if (l != null) {
      codes = l.providerCodes!;
      defaultCountry.add(l);
      dropdownValue.add(l);
    } else {
      defaultCountry.add(countries[0]);
      dropdownValue.add(countries[0]);
    }

    //startCompute(codes, "-1-", 70);
    //print("dropdonwvalue C: ${defaultCountry.length}");
    countries.refresh();
  }

  Future<String> getCountryName() async {
    var position = currentLoc;
    try {
      position =
          await Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 2));
    } catch (e) {
      print(position.latitude);
    }
    /*  Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); */
    debugPrint('location: ${position.latitude}');

    /* GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        googleMapApiKey: "AIzaSyCUeHSEKRAF-uDM_KlvEj5cPnixrPk0W9U"); */
    return "506";
  }

  void mPrice(LocationObject item, BuildContext context) async {
    resultPrice.clear();
    var res = await jsonDecode(await getPhysicianPrice(item));
    if (res["code"] == 701 || res["code"] == 711) {
      resultPrice(res["resultInsuredPartipation"]["success"]);
    } else {
      showToast("No se obtuvo informacion de copagos.", context);
    }
  }
}
