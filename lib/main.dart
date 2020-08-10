import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

void main() async {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => new _State();
}

class _State extends State<MyApp> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // try asking for contacts permission on first app launch
      _wrapContactsAction((){ });
    });
  }

  Future<void> _wrapContactsAction(Function action) async {
    final isGranted = await Permission.contacts.isGranted;
    if (isGranted) {
      action();
    } else {
      final permStatus = await Permission.contacts.request();
      if (permStatus.isGranted) {
        action();
      }
    }
  }

  void _create() async {
    _wrapContactsAction(() async {
      Contact contact = new Contact(familyName: 'Cairns', givenName: 'Bryan',
          emails: [new Item(label: 'work', value: 'bcairns@voidrealms.com')]);
      await ContactsService.addContact(contact);
      showInSnackbar('Created contact');
    });
  }

  void _find() async {
    _wrapContactsAction(() async {
      Iterable<Contact> people = await ContactsService.getContacts(query: 'Bryan');
      showInSnackbar('There are ${people.length} people named Bryan');
    });
  }

  void _read() async {
    _wrapContactsAction(() async {
      Iterable<Contact> people = await ContactsService.getContacts(query: 'Bryan');
      if (people.isNotEmpty) {
        Contact contact = people.first;
        showInSnackbar('Bryan email is ${contact.emails.first.value}');
      } else {
        showInSnackbar('Bryan not found');
      }
    });
  }

  void _delete() async {
    _wrapContactsAction(() async {
      Iterable<Contact> people = await ContactsService.getContacts(query: 'Bryan');
      if (people.isNotEmpty) {
        Contact contact = people.first;
        await ContactsService.deleteContact(contact);
        showInSnackbar('Bryan deleted');
      } else {
        showInSnackbar('Bryan not found');
      }
    });
  }

  void showInSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Name here'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text('Contacts'),
              new RaisedButton(onPressed: _create,child: new Text('Create'),),
              new RaisedButton(onPressed: _find,child: new Text('Find'),),
              new RaisedButton(onPressed: _read,child: new Text('Read'),),
              new RaisedButton(onPressed: _delete,child: new Text('Delete'),),
              new RaisedButton(onPressed: openAppSettings, child: new Text('Permissions'),),
            ],
          ),
        )
      ),
    );
  }
}