import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'districPage.dart';


//? Step 1: Create a model class for Province
class Village{
  final String id;
  final regenciesId;
  final String name;

  Village({required this.id, required this.regenciesId, required this.name});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'],
      regenciesId: json['districId'],
      name: json['name'],
    );
  }
}

//? Step 2: Fetch provinces from API
Future<List<Village>> fetchVillage() async {
  final response = await http.get(Uri.parse(
      'https://emsifa.github.io/api-wilayah-indonesia/api/villages/$idDistricClicked.json'));

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => Village.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load regencies: ${response.statusCode}');
  }
}

////////////////////////////////////////////////////////////

class VillageListPage extends StatefulWidget {

  const VillageListPage({super.key});

  @override
  villageListPageState createState() => villageListPageState();
}

class villageListPageState extends State<VillageListPage> {
  //? Step 6: Late demo using FutureBuilder
  late Future<List<Village>> _villageFuture;

  @override
  void initState() {
    super.initState();
    _villageFuture = fetchVillage();
  }

  @override
  Widget build(BuildContext context) {
    //? Step 5: Early demo using .then()
    fetchVillage().then((village) {
      print('Fetched ${village.length} village');
      for (var district in village.take(5)) {
        print('${district.id}: ${district.name}');
      }
    }).catchError((error) {
      print('Error fetching village: $error');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Kecamatan $nameDistricClicked'),
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
            child: FutureBuilder<List<Village>>(
              future: _villageFuture,
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
                        onTap: () {},
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
