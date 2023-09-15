import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:isar_routine_app/Collections/category.dart';
import 'package:isar_routine_app/Collections/product.dart';
import 'package:isar_routine_app/Collections/routine.dart';
import 'package:path_provider/path_provider.dart';

import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open(
    [RoutineSchema, CategorySchema, ProductSchema],
    directory: dir.path,
  );

  runApp(MyApp(
    isar: isar,
  ));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routine App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(isar: isar),
    );
  }
}
