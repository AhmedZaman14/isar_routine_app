import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:isar_routine_app/update_routine.dart';
import 'package:logger/logger.dart';

import 'Collections/product.dart';
import 'Collections/routine.dart';
import 'config.dart';
import 'create_routine.dart';
import 'http_service.dart';

class HomeScreen extends StatefulWidget {
  final Isar isar;
  const HomeScreen({Key? key, required this.isar}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Routine>? routines;

  final TextEditingController _searchController = TextEditingController();
  bool searching = false;

  HttpService httpService = HttpService();

  int? len;
  @override
  void initState() {
    super.initState();
  }

  _readRoutines() async {
    final routineCollection = widget.isar.routines;
    final getRotines = await routineCollection.where().findAll();

    setState(() {
      routines = getRotines;
    });
  }

  Future<List<Widget>> _builWidgets() async {
    if (!searching) {
      await _readRoutines();
    }
    List<Widget> x = [];
    var r = routines;
    len = 0;
    if (r != null) {
      len = r.length;
    }

    for (int i = 0; i < len!; i++) {
      x.add(
        Card(
          elevation: 10,
          child: ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateRoutine(
                      isar: widget.isar,
                      routine: routines![i],
                    ),
                  ));
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routines![i].title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const WidgetSpan(
                            child: Icon(
                          Icons.schedule,
                          size: 25,
                        )),
                        TextSpan(
                            text: '  ${routines![i].time}',
                            style: const TextStyle(fontSize: 20))
                      ],
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      const WidgetSpan(
                          child: Icon(
                        Icons.calendar_month,
                        size: 25,
                      )),
                      TextSpan(
                          text: '  ${routines![i].day}',
                          style: const TextStyle(fontSize: 20))
                    ],
                  ),
                )
              ],
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
      );
    }
    return x;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Rouitnes',
        backgroundColor: Colors.white,
        elevation: 20,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateRoutine(
                        isar: widget.isar,
                      )));
        },
      ),
      appBar: AppBar(
        title: const Text('Routines'),
        actions: [
          IconButton(
              onPressed: () {
                _apitoisar();
              },
              icon: const Icon(Icons.downloading_outlined, size: 30)),
          IconButton(
              onPressed: () {
                isarToApi();
              },
              icon: const Icon(Icons.upload_file_outlined, size: 30))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: searchRoutineByName,
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    suffixIcon: Icon(
                      Icons.search,
                      size: 40,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.solid)),
                  ),
                ),
              ),
              FutureBuilder(
                future: _builWidgets(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!,
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder<List<Product>>(
                  future: generateProducts(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isNotEmpty) {
                        return GridView.count(
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            children:
                                List.generate(snapshot.data!.length, (index) {
                              return Card(
                                elevation: 4.0,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 90,
                                        child: Image.network(
                                          snapshot.data![index].image!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          snapshot.data![index].title ?? 'Null',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: const Text("View"))
                                    ]),
                              );
                            }));
                      } else {
                        return const SizedBox();
                      }
                    } else {
                      return const SizedBox();
                    }
                  }))
            ],
          ),
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        child: const Text(
          'Clear All',
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete Routines'),
              content: const Text('Are you sure? I mean think about it!'),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)))),
                  onPressed: () async {
                    final routineCollecion = widget.isar.routines;
                    final getRoutines =
                        await routineCollecion.where().findAll();

                    await widget.isar.writeTxn(
                      () async {
                        for (var routine in getRoutines) {
                          routineCollecion.delete(routine.id);
                        }
                      },
                    ).then((value) => Navigator.pop(context));

                    setState(() {});
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  searchRoutineByName(String search) async {
    searching = true;
    final routineCollection = widget.isar.routines;
    final searchResult = await routineCollection
        .filter()
        .titleContains(search, caseSensitive: false)
        .findAll();

    setState(() {
      routines = searchResult;
    });
  }

  _apitoisar() async {
    httpService
        .init(BaseOptions(baseUrl: baseUrl, contentType: "application/json"));

    final response = await httpService.request(
        endpoint: "products?limit=7", method: Method.GET);

    List<Map<String, dynamic>>? products = (response.data as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    await widget.isar.writeTxn(() async {
      await widget.isar.products.clear();
      await widget.isar.products.importJson(products);
    });
  }

  Future<List<Product>> generateProducts() async {
    List<Product> getProducts = await widget.isar.products.where().findAll();
    return getProducts;
  }

  isarToApi() async {
    final prod = await widget.isar.products.where().findAll();

    List<Map<String, dynamic>>? listProducts =
        prod.map((e) => e.toJson()).toList();

    httpService.init(BaseOptions(baseUrl: serverUrl));

    Map<String, dynamic> params = {'products': listProducts};
    final response = await httpService.request(
        endpoint: "/products", method: Method.POST, params: params);
    Logger().i(response);
  }
}
