

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'regencyPage.dart';
import 'villagePage.dart';


var idDistricClicked;
var nameDistricClicked;

//? Step 1: Create a model class for Province
class District{
  final String id;
  final regenciesId;
  final String name;

  District({required this.id, required this.regenciesId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      regenciesId: json['regencyId'],
      name: json['name'],
    );
  }
}

//? Step 2: Fetch provinces from API
Future<List<District>> fetchDistrict() async {
  final response = await http.get(Uri.parse(
      'https://emsifa.github.io/api-wilayah-indonesia/api/districts/$idRegencyClicked.json'));

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => District.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load regencies: ${response.statusCode}');
  }
}

////////////////////////////////////////////////////////////

class DistrictListPage extends StatefulWidget {

  const DistrictListPage({super.key});

  @override
  districListPageState createState() => districListPageState();
}

class districListPageState extends State<DistrictListPage> {
  //? Step 6: Late demo using FutureBuilder
  late Future<List<District>> _districtFuture;

  @override
  void initState() {
    super.initState();
    _districtFuture = fetchDistrict();
  }

  @override
  Widget build(BuildContext context) {
    //? Step 5: Early demo using .then()
    fetchDistrict().then((district) {
      print('Fetched ${district.length} district');
      for (var district in district.take(5)) {
        print('${district.id}: ${district.name}');
      }
    }).catchError((error) {
      print('Error fetching district: $error');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('$nameRegencyClicked'),
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
            child: FutureBuilder<List<District>>(
              future: _districtFuture,
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
                          idDistricClicked = {snapshot.data![index].id}.join("");
                          nameDistricClicked = {snapshot.data![index].name}.join("");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VillageListPage(),
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
