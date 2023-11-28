import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'sql_helper.dart';
import 'contact.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Contact>> contactsFuture;

  @override
  void initState() {
    super.initState();
    contactsFuture = _fetchContacts();
  }



  showAlertDialog(BuildContext context, String message) {
    Widget cancelButton = TextButton(onPressed: () {}, child: Text("Cancel"));
    Widget continueButton = TextButton(
        onPressed: () {}, child: Text("Continue"));
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(message),
      actions: [cancelButton, continueButton],
    );
    showDialog(context: context, builder: (BuildContext context) {
      return alert;
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Skandar ListView"),
      ),
      body: FutureBuilder<List<Contact>>(
        future: contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // or any loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Contact> listContact = snapshot.data!;

            return ListView.builder(
              itemBuilder: (BuildContext context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(listContact[index].photo),
                      backgroundColor: Colors.blue,
                    ),
                    title: Text("Mrr : " + listContact[index].nom),
                    subtitle: Text(listContact[index].tel),
                    onTap: () {
                      //showAlertDialog(context, listContact[index].nom);
                      FlutterPhoneDirectCaller.callNumber(listContact[index].tel);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showUpdateContactDialog(context, listContact[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteContactDialog(context, listContact[index]);
                          },
                        ),
                      ],
                    ),

                  ),
                );
              },
              itemCount: listContact.length,
              shrinkWrap: true,
              padding: EdgeInsets.all(5),
              scrollDirection: Axis.vertical,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddContactDialog(context);
        },
        tooltip: 'Add Contact',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddContactDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();
    String selectedImage = "assets/images/avatar1.jpg"; // Default image

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                Text('Select Image:'),
                DropdownButton<String>(
                  value: selectedImage,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedImage = newValue!;
                    });
                  },
                  items: [
                    // Default image
                    'assets/images/avatar1.jpg',
                    'assets/images/avatar2.jpg',
                    'assets/images/avatar3.jpg',
                    'assets/images/avatar4.jpg',
                    'assets/images/avatar5.jpg',
                    'assets/images/avatar6.jpg',
                    'assets/images/avatar7.gif',
                    'assets/images/avatar8.jpg',
                    // Add other image paths here
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addContact(
                  nameController.text,
                  phoneNumberController.text,
                  selectedImage,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addContact(String name, String phoneNumber, String selectedImage) async {
    await SQLHelper.createContact(name, phoneNumber, selectedImage);
    // Refresh the contact list
    setState(() {
      contactsFuture = _fetchContacts();
    });
  }

  Future<void> _showUpdateContactDialog(BuildContext context, Contact contact) async {
    TextEditingController nameController = TextEditingController(text: contact.nom);
    TextEditingController phoneNumberController = TextEditingController(text: contact.tel);
    String selectedImage = contact.photo;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                Text('Select Image:'),
                DropdownButton<String>(
                  value: selectedImage,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedImage = newValue!;
                    });
                  },
                  items: [
                    'assets/images/default_avatar.jpg', // Default image
                    'assets/images/avatar1.jpg',
                    'assets/images/avatar2.jpg',
                    // Add other image paths here
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                _updateContact(
                  contact.id, // Assuming you have an 'id' property in your Contact class
                  nameController.text,
                  phoneNumberController.text,
                  selectedImage,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Contact>> _fetchContacts() async {
    List<Map<String, dynamic>> contactsData = await SQLHelper.getContacts();

    List<Contact> contactsList = contactsData.map((contactData) =>
        Contact(
          contactData['id'] as int,
          contactData['nom'],
          contactData['tel'],
          contactData['image'],
        )
    ).toList();

    return contactsList;
  }

  Future<void> _updateContact(int id, String name, String phoneNumber, String selectedImage) async {
    await SQLHelper.updateContacts(id, name, phoneNumber, selectedImage);
    // Do not refresh contactsFuture here

    // Refresh the contact list
    setState(() {
      contactsFuture = _fetchContacts();
    });
  }

  Future<void> _showDeleteContactDialog(BuildContext context, Contact contact) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Contact'),
          content: Text('Are you sure you want to delete ${contact.nom}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteContact(contact.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(int id) async {
    await SQLHelper.deleteContact(id);
    // Refresh the contact list
    setState(() {
      contactsFuture = _fetchContacts();
    });
  }
}
