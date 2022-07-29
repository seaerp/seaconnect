import 'package:flutter/material.dart';
import 'package:tiengviet/tiengviet.dart';
import 'info_employee.dart';
import 'package:sea_connect/page/home.dart';
import 'package:url_launcher/url_launcher.dart';



class CustomSearch extends SearchDelegate {
  // ignore: non_constant_identifier_names
  final List? list_employees;

  // ignore: non_constant_identifier_names
  CustomSearch({Key? key, this.list_employees});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  Email(email, context) {
    if (email != 'false') {
      // ignore: deprecated_member_use
      launch('mailto:$email');
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Message"),
              content: Text("Người dùng chưa cung cấp email"),
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

  Call(mobile, phone, context) async {
    if (mobile != 'false') {
      // ignore: deprecated_member_use
      launch('tel://$mobile');
    } else if (phone != 'false') {
      // ignore: deprecated_member_use
      launch('tel://$phone');
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
  Message(mobile, phone, context) async {
    if (mobile != 'false') {
      // ignore: deprecated_member_use
      launch('sms:$mobile');
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
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List matchQuery = [];
    list_employees?.forEach((element) {
      if (element['name'].toLowerCase().contains(query.toLowerCase()) ||
          TiengViet.parse(element['name'])
              .toLowerCase()
              .contains(query.toLowerCase())) {
        matchQuery.add(element);
      }
    });
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < matchQuery.length; i++)
            Column(
              children: [
                ListTile(
                  title: Text(matchQuery[i]['name'].toString()),
                  trailing: Wrap(
                    // space between two icons
                    children: [
                      IconButton(
                          onPressed: () {
                            Call(
                                matchQuery[i]['mobile_phone'].toString(),
                                matchQuery[i]['work_phone'].toString(),
                                context);
                          },
                          icon: const Icon(Icons.call, color: Colors.green,)), // icon-1
                      IconButton(
                          onPressed: () {
                            Message(
                                matchQuery[i]['mobile_phone'].toString(),
                                matchQuery[i]['work_phone'].toString(),
                                context);
                          },
                          icon: const Icon(Icons.message, color: Colors.blue,)),
                      IconButton(
                          onPressed: () {
                            Email(matchQuery[i]['work_email'].toString(),
                                context);
                          },
                          icon: const Icon(Icons.email, color: Colors.brown,)), // icon-2
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InfoEmployee(
                              id: matchQuery[i]['id'],
                            )));
                  },
                )
              ],
            )
        ],
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List matchQuery = [];
    list_employees?.forEach((element) {
      if (element['name'].toLowerCase().contains(query.toLowerCase()) ||
          TiengViet.parse(element['name'])
              .toLowerCase()
              .contains(query.toLowerCase())) {
        matchQuery.add(element);
      }
    });
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < matchQuery.length; i++)
            Column(
              children: [
                ListTile(
                    title: Text(matchQuery[i]['name'].toString()),
                    trailing: Wrap(
                      // space between two icons
                      children: [
                        IconButton(
                            onPressed: () {
                              Call(
                                  matchQuery[i]['mobile_phone'].toString(),
                                  matchQuery[i]['work_phone'].toString(),
                                  context);
                            },
                            icon: const Icon(Icons.call, color: Colors.green,)), // icon-1
                        IconButton(
                            onPressed: () {
                              Message(
                                  matchQuery[i]['mobile_phone'].toString(),
                                  matchQuery[i]['work_phone'].toString(),
                                  context);
                            },
                            icon: const Icon(Icons.message, color: Colors.blue,)),
                        IconButton(
                            onPressed: () {
                              Email(matchQuery[i]['work_email'].toString(),
                                  context);
                            },
                            icon: const Icon(Icons.email, color: Colors.brown,)), // icon-2
                      ],
                    ))
              ],
            )
        ],
      ),
    );
  }
}
