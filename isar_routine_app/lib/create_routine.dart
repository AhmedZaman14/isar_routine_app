import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:isar_routine_app/Collections/category.dart';
import 'package:isar_routine_app/Collections/routine.dart';

class CreateRoutine extends StatefulWidget {
  final Isar isar;
  const CreateRoutine({super.key, required this.isar});

  @override
  State<CreateRoutine> createState() => _CreateRoutineState();
}

class _CreateRoutineState extends State<CreateRoutine> {
  List<Category>? categories;
  Category? selectedCategory;

  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  String selectedDay = 'Monday';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();

  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _readCategories();
  }

  _addRoutine() async {
    final routineCollection = widget.isar.routines;
    final newRoutine = Routine()
      ..title = _titleController.text
      ..time = _startTimeController.text
      ..category.value = selectedCategory
      ..day = selectedDay;

    await widget.isar.writeTxn(() async {
      await routineCollection.put(newRoutine);
      newRoutine.category.save();
    });

    _titleController.clear();
    _startTimeController.clear();
    setState(() {
      selectedCategory = null;
      selectedDay = 'Monday';
    });
  }

  _addCategory(Isar isar) async {
    final categories = isar.categorys;

    final newCategory = Category()..name = _newCategoryController.text;

    await isar.writeTxn(() async {
      await categories.put(newCategory);
    });
    _readCategories();
    _newCategoryController.clear();
  }

  _readCategories() async {
    final categoryCollection = widget.isar.categorys;

    final getCategories = await categoryCollection.where().findAll();

    setState(() {
      categories = getCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    labelStyle() {
      return const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      );
    }

    selectTime(BuildContext context) async {
      final TimeOfDay? timeOfDay = await showTimePicker(
          context: context,
          initialTime: selectedTime,
          initialEntryMode: TimePickerEntryMode.dial);

      if (timeOfDay != null && timeOfDay != selectedTime) {
        selectedTime = timeOfDay;
        setState(() {
          _startTimeController.text =
              "${selectedTime.hour} : ${selectedTime.minute}  ${selectedTime.period.name}";
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Routine',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: labelStyle(),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: DropdownButton(
                    focusColor: Colors.white,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    onChanged: (newCat) {
                      setState(() {
                        selectedCategory = newCat;
                      });
                    },
                    value: selectedCategory,
                    items: categories
                        ?.map<DropdownMenuItem<Category>>((Category nvalue) {
                      return DropdownMenuItem<Category>(
                        value: nvalue,
                        child: Text(nvalue.name),
                      );
                    }).toList(),
                    icon: const Icon(Icons.keyboard_arrow_down_outlined),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: ((context) => AlertDialog(
                                title: const Text('New Category'),
                                content: TextField(
                                  controller: _newCategoryController,
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_newCategoryController
                                          .text.isNotEmpty) {
                                        _addCategory(widget.isar);
                                      }
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4))),
                                    child: const Text('Add'),
                                  ),
                                ],
                              )));
                    },
                    icon: const Icon(Icons.add))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text('Title', style: labelStyle()),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.token_sharp,
                  size: 40,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                enabled: true,
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Start Time',
              style: labelStyle(),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    controller: _startTimeController,
                    enabled: false,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      selectTime(context);
                    },
                    icon: const Icon(
                      Icons.timer,
                      size: 40,
                    ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Day',
              style: labelStyle(),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: DropdownButton(
                isExpanded: true,
                value: selectedDay,
                items: days.map<DropdownMenuItem<String>>((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value!;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  _addRoutine();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    elevation: 15,
                    shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Add',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
