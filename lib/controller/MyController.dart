// controllers/home_screen_controller.dart
import 'package:contacts_buddy/model/contact.dart';
import 'package:contacts_buddy/model/sql_helper.dart';

class HomeScreenController {
  Future<List<Contact>> getAllContacts(String? orderBy) async {
    final data = await SQLHelper.getAllData(orderBy);
    return data.map((contactData) => Contact.fromMap(contactData)).toList();
  }

  Future<int> createContact(String name, String email, String? address, int? phone) async {
    final id = await SQLHelper.createData(name, email, address, phone);
    return id;
  }

  Future<int> updateContact(int id, String name, String email, String address, int? phone) async {
    final result = await SQLHelper.updateData(id, name, email, address, phone);
    return result;
  }

  Future<void> deleteContact(int id) async {
    await SQLHelper.deleteData(id);
  }
}
