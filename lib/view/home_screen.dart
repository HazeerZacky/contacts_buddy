import 'package:android_intent_plus/android_intent.dart';
import 'package:contacts_buddy/model/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "/HomeScreeen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;
  String orderby = 'name ASC';
  String name = '';
  String email = '';
  String address = '';
  String phone = '';
  List<Map<String, dynamic>> filteredData = [];

  void filterData(String query) {
    setState(() {
      // searchTerm = query;
      if (query == null || query == '') {
        _refreshData(orderby);
      } else {
        filteredData = _allData
            .where((item) => item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();

        _allData = filteredData;
      }
    });
  }

  void _refreshData(String orderby2) async {
    print('order by ${orderby}');
    final data = await SQLHelper.getAllData(orderby2);
    setState(() {
      _allData = data;
      _isLoading = false;
      print('all data ${data}');
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData(orderby);
  }

  Future<void> _addData() async {
    await SQLHelper.createData(
      _nameController.text,
      _emailController.text,
      _addressController.text,
      int.parse(_phoneController.text),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Color.fromARGB(255, 10, 112, 13),
      content: Text("Contact Details Saved."),
    ));
    _refreshData(orderby);
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
      backgroundColor: Color.fromARGB(255, 202, 183, 6),
      content: Text("Contact Details Updated."),
    ));
    _refreshData(orderby);
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
                Navigator.of(context)
                    .pop(false); // User does not want to delete
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
          backgroundColor: Colors.red,
          content: Text("Contact Details Deleted."),
        ),
      );
      _refreshData(orderby);
    }
  }

  void _openGmail() {
    const intent = AndroidIntent(
      action: 'android.intent.action.SEND',
      arguments: {'android.intent.extra.SUBJECT': 'I am the subject'},
      arrayArguments: {
        'android.intent.extra.GMAIL': ['eidac@me.com', 'overbom@mac.com'],
        // 'android.intent.extra.CC': ['john@app.com', 'user@app.com'],
        // 'android.intent.extra.BCC': ['liam@me.abc', 'abel@me.com'],
      },
      package: 'com.google.android.gm',
      type: 'message/rfc822',
    );
    intent.launch();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildContainer(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value),
                  TextButton(
                    onPressed: () async {
                      title == 'Phone'
                          ? {await FlutterPhoneDirectCaller.callNumber(phone)}
                          : title == 'Email'
                              ? {_openGmail}
                              : {};
                    },
                    child: Icon(title == 'Phone'
                        ? Icons.call
                        : title == 'Email'
                            ? Icons.email_outlined
                            : null),
                  )
                ],
              )),
        ],
      ),
    );
  }

  void showBottomSheetfor_listviewbuilder(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      setState(() {
        name = existingData['name'];
        email = existingData['email'];
        address = existingData['address'];
        phone = existingData['phone'].toString();
        print('name ${name}');
      });
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildContainer('Name', name),
                _buildContainer('Email', email),
                _buildContainer('Addres', address),
                _buildContainer('Phone', phone),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
        title: Text("Contacts Buddy! "),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          onChanged: (value) {
                            filterData(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Contact',
                            contentPadding: EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .indigo), // Customize the border color
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Text(
                    //   'Filter by',
                    //   style: TextStyle(fontWeight: FontWeight.w600),
                    // ),
                    // SizedBox(
                    //   width: 20,
                    // ),
                    TextButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColorLight),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5)),
                          textStyle: MaterialStateProperty.all(TextStyle(
                            color: Colors.black,
                          )),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                      onPressed: () {
                        setState(() {
                          orderby = 'name ASC';
                          _refreshData(orderby);
                        });
                      },
                      child: Text(
                        "A to Z",
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColorLight),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5)),
                          textStyle: MaterialStateProperty.all(TextStyle(
                            color: Colors.black,
                          )),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                      onPressed: () {
                        setState(() {
                          orderby = 'name DESC';
                          _refreshData(orderby);
                        });
                      },
                      child: Text(
                        "Z to A",
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allData.length,
                  itemBuilder: (context, index) => Card(
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                      focusColor: Colors.black,
                      onTap: () {
                        showBottomSheetfor_listviewbuilder(
                            _allData[index]['id']);
                      },
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
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
