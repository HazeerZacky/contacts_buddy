import 'package:contacts_buddy/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addDate() async {
    await SQLHelper.createData(_nameController.text, _emailController.text, _addressController.text);
    _refreshData();
  }

  Future<void> _updateDate(int id) async {
    await SQLHelper.updateData(id, _nameController.text, _emailController.text, _addressController.text);
    _refreshData();
  }

  Future<void> _deleteDate(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Data deleted"),
    ));
    _refreshData();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _nameController.text = existingData['name'];
      _emailController.text = existingData['email'];
      _addressController.text = existingData['address'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Full Name",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Email",
              ),
            ),
            SizedBox(height: 20),TextField(
              controller: _addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Address",
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addDate();
                  }
                  if (id != null) {
                    await _updateDate(id);
                  }

                  _nameController.text = "";
                  _emailController.text = "";
                  _addressController.text = "";

                  Navigator.of(context).pop();
                  print("Data Added");
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Add Data" : "Update",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text("Contact Buddy!"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _allData[index]['name'],
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: Text(_allData[index]['address']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showBottomSheet(_allData[index]['id']);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.indigo,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteDate(_allData[index]['id']);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
