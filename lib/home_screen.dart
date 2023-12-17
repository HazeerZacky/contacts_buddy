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

  Future<void> _addData() async {
    await SQLHelper.createData(
      _nameController.text,
      _emailController.text,
      _addressController.text,
      int.parse(_phoneController.text),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.greenAccent,
      content: Text("Contact Details Saved."),
    ));
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(
      id,
      _nameController.text,
      _emailController.text,
      _addressController.text,
      int.parse(_phoneController.text),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.yellowAccent,
      content: Text("Contact Details Updated."),
    ));
    _refreshData();
  }

Future<void> _deleteData(int id) async {
  // Show a confirmation dialog
  bool confirmed = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this contact?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User does not want to delete
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirmed deletion
            },
            child: Text("Delete"),
          ),
        ],
      );
    },
  );

  // Check the user's confirmation
  if (confirmed == true) {
    // User confirmed deletion
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Contact Details Deleted."),
      ),
    );
    _refreshData();
  }
}


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _nameController.text = existingData['name'];
      _emailController.text = existingData['email'];
      _addressController.text = existingData['address'];
      _phoneController.text = existingData['phone'].toString();
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Full Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Address",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Phone",
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^[0-9]+$').hasMatch(value) ||
                      value.length != 10) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (id == null) {
                        await _addData();
                      }
                      if (id != null) {
                        await _updateData(id);
                      }

                      _nameController.text = "";
                      _emailController.text = "";
                      _addressController.text = "";
                      _phoneController.text = "";

                      Navigator.of(context).pop();
                      print("Data Added");
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      id == null ? "Add Data" : "Update",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text(
                    _allData[index]['name'][0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
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
                        _deleteData(_allData[index]['id']);
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
