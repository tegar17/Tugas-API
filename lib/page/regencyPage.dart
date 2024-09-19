

import 'dart:convert';

import 'package:address_app/page/districPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'provincePage.dart';

var idRegencyClicked;
var nameRegencyClicked;

//? Step 1: Create a model class for Province
class Regency {
  final String id;
  final provinceId;
  final String name;

  Regency({required this.id, required this.provinceId, required this.name});

  factory Regency.fromJson(Map<String, dynamic> json) {
    return Regency(
      id: json['id'],
      provinceId: json['provinceId'],
      name: json['name'],
    );
  }
}

//? Step 2: Fetch provinces from API
Future<List<Regency>> fetchRegency() async {
  final response = await http.get(Uri.parse(
      'https://emsifa.github.io/api-wilayah-indonesia/api/regencies/$idProvinceClicked.json'));

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => Regency.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load regencies: ${response.statusCode}');
  }
}

////////////////////////////////////////////////////////////

class RegencyListPage extends StatefulWidget {

  RegencyListPage({super.key});

  @override
  RegencyListPageState createState() => RegencyListPageState();
}

class RegencyListPageState extends State<RegencyListPage> {
  //? Step 6: Late demo using FutureBuilder
  late Future<List<Regency>> _RegencyFuture;

  @override
  void initState() {
    super.initState();
    _RegencyFuture = fetchRegency();
  }

  @override
  Widget build(BuildContext context) {
    //? Step 5: Early demo using .then()
    fetchRegency().then((regency) {
      print('Fetched ${regency.length} regency');
      for (var regency in regency.take(5)) {
        print('${regency.id}: ${regency.name}');
      }
    }).catchError((error) {
      print('Error fetching regencies: $error');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Province $nameProvinceClicked'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Check the console for the .then() demo output',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Regency>>(
              future: _RegencyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          idRegencyClicked = {snapshot.data![index].id}.join("");
                          nameRegencyClicked = {snapshot.data![index].name}.join("");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DistrictListPage(),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(snapshot.data![index].name),
                          subtitle: Text('ID: ${snapshot.data![index].id}'),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
