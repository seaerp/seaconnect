import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom_search.dart';
import 'info_employee.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DocumentSnapshot> employees = [];
  bool _loading = true;
  int per_page = 20;
  late DocumentSnapshot _lastDocument;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreEmployees = false;
  bool _moreEmployees = true;
  int company_id = 1;
  List list_employees = [];

  getEmployees() async {
    List list_emp = [];
    if (company_id == 1) {
      var snapshot = await FirebaseFirestore.instance
          .collection("employees")
          .orderBy('name')
          .get();
      if (snapshot.docs.isNotEmpty) {
        for (int i = 0; i < snapshot.docs.length; i++) {
          var element = jsonDecode(jsonEncode(snapshot.docs[i].data()));
          list_emp.add(element);
        }
      }
    } else {
      var snapshot = await FirebaseFirestore.instance
          .collection("employees")
          .where('company_id', arrayContains: company_id)
          .get();
      if (snapshot.docs.isNotEmpty) {
        for (int i = 0; i < snapshot.docs.length; i++) {
          var element = jsonDecode(jsonEncode(snapshot.docs[i].data()));
          list_emp.add(element);
        }
      }
    }
    setState(() {
      list_employees = list_emp;
    });
  }

  _getEmployees() async {
    Query q = FirebaseFirestore.instance
        .collection('employees')
        .orderBy('name')
        .limit(per_page);
    setState(() {
      _loading = true;
    });
    QuerySnapshot querySnapshot = await q.get();
    employees = querySnapshot.docs;
    _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    setState(() {
      _loading = false;
    });
  }

  _getMoreEmployees() async {
    print("Called");

    if (_moreEmployees == false) {
      print("No more data");
      return;
    }
    if (_gettingMoreEmployees == true) {
      return;
    }

    _gettingMoreEmployees = true;

    Query q = FirebaseFirestore.instance
        .collection('employees')
        .orderBy('name')
        .startAfter([_lastDocument['name']]).limit(per_page);
    QuerySnapshot querySnapshot = await q.get();

    if (querySnapshot.docs.length < per_page) {
      _moreEmployees = false;
    }

    _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    employees.addAll(querySnapshot.docs);

    setState(() {});
    _gettingMoreEmployees = false;
  }

  @override
  void initState() {
    super.initState();
    getEmployees();
    _getEmployees();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _getMoreEmployees();
      }
    });
  }

  Email(email) {
    if (email != 'false') {
      String url = Platform.isIOS ? 'mailto://$email' : 'mailto:$email';
      launch(url);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Message"),
              content: const Text("Người dùng chưa cung cấp email"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        MaterialPageRoute(
                          builder: (ctx) => const Home(),
                        ),
                      );
                    },
                    child: const Text("Ok"))
              ],
            );
          });
    }
  }

  Call(mobile, phone) async {
    if (mobile != 'false') {
      String url = Platform.isIOS ? 'tel://$mobile' : 'tel:$mobile';
      launch(url);
    } else if (phone != 'false') {
      String url = Platform.isIOS ? 'tel://$phone' : 'tel:$phone';
      launch(url);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Message"),
              content: Text("Không có số liên lạc !"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        MaterialPageRoute(
                          builder: (ctx) => const Home(),
                        ),
                      );
                    },
                    child: const Text("Ok"))
              ],
            );
          });
    }
  }

  // ignore: non_constant_identifier_names
  Message(mobile, phone) async {
    if (mobile != 'false') {
     String url = Platform.isIOS ? 'sms://$mobile' : 'sms:$mobile';
      launch(url);
    } else if (phone != 'false') {
      // ignore: deprecated_member_use
      launch('sms:$phone');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Message"),
              content: const Text("Không có số liên lạc !"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        MaterialPageRoute(
                          builder: (ctx) => const Home(),
                        ),
                      );
                    },
                    child: const Text("Ok"))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Employees"),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: CustomSearch(
                        list_employees: list_employees,
                      ));
                },
                icon: const Icon(Icons.search))
          ],
        ),
        body: SingleChildScrollView(
          primary: false,
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('companies')
                      .orderBy('id')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.data!.docs.length == 0) {
                      return Container(
                          child: Container(
                        margin: EdgeInsets.all(13),
                        child: Center(
                          child: Column(children: [
                            const Text(
                              "Nothing to see",
                              style: TextStyle(
                                  fontSize: 20, color: Colors.blueAccent),
                            ),
                            Image.asset("assets/images/nothing.gif")
                          ]),
                        ),
                      ));
                    } else {
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple
                                        .shade50, //background color of dropdown button
                                    border: Border.all(
                                        color: Colors.black38,
                                        width: 1), //border of dropdown button
                                    borderRadius: BorderRadius.circular(
                                        10), //border raiuds of dropdown button
                                    boxShadow: const <BoxShadow>[
                                      //apply shadow on Dropdown button
                                      BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0,
                                              0.57), //shadow for button
                                          blurRadius: 5) //blur radius of shadow
                                    ]),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  child: DropdownButton(
                                    dropdownColor: Colors.blueGrey.shade100,
                                    menuMaxHeight: 400,
                                    value: company_id,
                                    isExpanded: true,
                                    underline: Container(),
                                    elevation: 16,
                                    onChanged: (value) {
                                      setState(() {
                                        getEmployees();
                                        company_id = value as int;
                                        print(company_id);
                                        getEmployees();
                                      });
                                    },
                                    items: [
                                      ...snapshot.data!.docs
                                          .map((e) => DropdownMenuItem(
                                              value: e['id'],
                                              child: Container(
                                                child: Text(e['name']),
                                              )))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              Container(
                  child: company_id == 1
                      ? Container(
                          child: _loading == true
                              ? Container(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: employees.length == 0
                                      ? const Center(
                                          child: Text("Waiting..."),
                                        )
                                      : Container(
                                          child: ListView(
                                          shrinkWrap: true,
                                          primary: false,
                                          children: [
                                            ...employees.map((e) {
                                              return ListTile(
                                                leading: e['image']
                                                            .toString() ==
                                                        'false'
                                                    ? ClipOval(
                                                        child: Image.asset(
                                                          "assets/images/user.png",
                                                          width: 50,
                                                          height: 50,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : ClipOval(
                                                        child: Image.memory(
                                                          base64Decode(
                                                              e['image']
                                                                  .toString()),
                                                          width: 50,
                                                          height: 50,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                title: Text(e['name']),
                                                subtitle: Text(
                                                    e['s_identification_id']
                                                        .toString()),
                                                trailing: Wrap(
                                                  spacing: 0,
                                                  // space between two icons
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          Call(
                                                              e['mobile_phone']
                                                                  .toString(),
                                                              e['work_phone']
                                                                  .toString());
                                                        },
                                                        icon: const Icon(
                                                          Icons.call,
                                                          color: Colors.green,
                                                        )), // icon-1
                                                    IconButton(
                                                        onPressed: () {
                                                          Message(
                                                              e['mobile_phone']
                                                                  .toString(),
                                                              e['work_phone']
                                                                  .toString());
                                                        },
                                                        icon: const Icon(
                                                          Icons.message,
                                                          color: Colors.blue,
                                                        )),
                                                    IconButton(
                                                        onPressed: () {
                                                          Email(e['work_email']
                                                              .toString());
                                                        },
                                                        icon: const Icon(
                                                          Icons.email,
                                                          color: Colors.brown,
                                                        )), // icon-2
                                                  ],
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            InfoEmployee(
                                                          id: e['id'],
                                                          mobile_phone:
                                                              e['mobile_phone']
                                                                  .toString(),
                                                          company_id:
                                                              company_id,
                                                        ),
                                                      ));
                                                },
                                              );
                                            })
                                          ],
                                        )),
                                ),
                        )
                      : Container(
                          child: Container(
                            child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('employees')
                                    .where("company_id",
                                        arrayContains: company_id)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container(
                                      padding: EdgeInsets.all(10),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else if (snapshot.data!.docs.length == 0) {
                                    return Container(
                                      margin: EdgeInsets.all(13),
                                      child: Center(
                                        child: Column(children: [
                                          const Text(
                                            "Nothing to see",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.blueAccent),
                                          ),
                                          Image.asset(
                                              "assets/images/nothing.gif")
                                        ]),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      child: Column(children: [
                                        ...snapshot.data!.docs.map((e) {
                                          return Column(
                                            children: [
                                              Card(
                                                child: ListTile(
                                                  leading: e['image']
                                                              .toString() ==
                                                          'false'
                                                      ? ClipOval(
                                                          child: Image.asset(
                                                            "assets/images/user.png",
                                                            width: 50,
                                                            height: 50,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : ClipOval(
                                                          child: Image.memory(
                                                            base64Decode(e[
                                                                    'image']
                                                                .toString()),
                                                            width: 50,
                                                            height: 50,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                  title: Text(e['name']),
                                                  subtitle: Text(
                                                      e['s_identification_id']
                                                          .toString()),
                                                  trailing: Wrap(
                                                    // space between two icons
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            Call(
                                                                e['mobile_phone']
                                                                    .toString(),
                                                                e['work_phone']
                                                                    .toString());
                                                          },
                                                          icon: const Icon(
                                                            Icons.call,
                                                            color: Colors.green,
                                                          )), // icon-1
                                                      IconButton(
                                                          onPressed: () {
                                                            Message(
                                                                e['mobile_phone']
                                                                    .toString(),
                                                                e['work_phone']
                                                                    .toString());
                                                          },
                                                          icon: const Icon(
                                                            Icons.message,
                                                            color: Colors.blue,
                                                          )),
                                                      IconButton(
                                                          onPressed: () {
                                                            Email(e['work_email']
                                                                .toString());
                                                          },
                                                          icon: const Icon(
                                                            Icons.email,
                                                            color: Colors.brown,
                                                          )), // icon-2
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                InfoEmployee(
                                                                  id: e['id'],
                                                                  mobile_phone:
                                                                      e['mobile_phone']
                                                                          .toString(),
                                                                  company_id:
                                                                      company_id,
                                                                )));
                                                  },
                                                ),
                                              )
                                            ],
                                          );
                                        })
                                      ]),
                                    );
                                  }
                                }),
                          ),
                        ))
            ],
          ),
        ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
              child: Container(
                margin: const EdgeInsets.only(bottom: 3, right: 4),
                child: const Text(
                  "Designed by Seatek",
                  style: TextStyle(
                      color: Colors.blueGrey, fontStyle: FontStyle.italic),
                ),
              ))
        ],
      ),
    );
  }
}
