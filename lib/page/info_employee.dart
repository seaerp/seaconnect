import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
//final orpc = OdooClient('https://home.seacorp.vn/');

class InfoEmployee extends StatefulWidget {
  final int? id;
  final String? mobile_phone;
  final int? company_id;
  const InfoEmployee({Key? key, this.id, this.mobile_phone, this.company_id})
      : super(key: key);

  @override
  State<InfoEmployee> createState() => _InfoEmployeeState();
}

class _InfoEmployeeState extends State<InfoEmployee> {
  late String? mobile_phone = widget.mobile_phone;
  final double coverHeight = 280;
  // ignore: non_constant_identifier_names
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

  /*UpdateMobile() async {
    HttpOverrides.global = MyHttpOverrides();
    await orpc.authenticate('opensea12pro', 'appconnect', 'xMNgdAQM');
    await orpc.callKw({
      'model': 'hr.employee',
      'method': 'write',
      'args': [
         widget.id,
        {
          'mobile_phone': mobile_phone,
        },
      ],
      'kwargs': {},
    });
    print("odoo updated !");
    await FirebaseFirestore.instance.collection('employees').doc(widget.id.toString()).update({'mobile_phone': mobile_phone});
    print("firebase updated !");
    Navigator.pop(context);

  }*/

  @override
  Widget build(BuildContext context) {
    double _deviceHeight = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin nhân viên"),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/images/background_white.png"),
          fit: BoxFit.cover,
        )),
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('employees')
                .where('id', isEqualTo: widget.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Container(
                  child: Column(
                    children: [
                      ...snapshot.data!.docs.map((e) {
                        return Container(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('companies')
                                .where('id', isEqualTo: widget.company_id)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  padding: EdgeInsets.all(10),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else {
                                return Column(
                                  children: [
                                    ...snapshot.data!.docs.map((item) {
                                      return Column(
                                        children: [
                                          Container(
                                            height:_deviceHeight*0.7,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              ),
                                            child:SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Stack(
                                                    clipBehavior: Clip.none,
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets.only(bottom: 50),
                                                        child: item['logo_web'].toString() == 'false'
                                                            ? Container(
                                                              decoration:BoxDecoration(
                                                                  border: Border.all(
                                                                      width: 0.4,
                                                                      color: Colors.blue
                                                                          .shade900),
                                                                ),
                                                                height: 145,
                                                                padding:const EdgeInsets.all(35),
                                                                width: MediaQuery.of(context).size.width,
                                                                child: Image.asset("assets/images/logo_seacorp.png",
                                                                  width: 50,
                                                                  height: 50,
                                                                  fit: BoxFit.fill,
                                                                )
                                                              )
                                                            : Container(
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width: 0.4,
                                                                        color: Colors.blue.shade900)),
                                                                height: 145,
                                                                padding:const EdgeInsets.all(35),
                                                                width: MediaQuery.of(context).size.width,
                                                                child: Image.memory(base64Decode(item['logo_web'].replaceAll("\n","")),
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              ),
                                                      ),
                                                      Positioned(
                                                        top: 90,
                                                        child: e['image'].toString() == 'false'
                                                            ? Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:BorderRadius.circular(60),
                                                                    color:Colors.white),
                                                                child: ClipOval(
                                                                    child: Image.asset("assets/images/user.png",
                                                                            width: 100,
                                                                            height: 100,
                                                                            fit: BoxFit.cover,
                                                                )),
                                                              )
                                                            : Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:BorderRadius.circular(60),
                                                                    color:Colors.white),
                                                                child: ClipOval(
                                                                  child: Image.memory(base64Decode(e['image'].toString()),
                                                                    width: 100,
                                                                    height: 100,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                      )
                                                    ],
                                                  ),
                                                  Column(children: [
                                                    if(e['name'].toString() != 'false')
                                                      Text(e['name'],
                                                        style: const TextStyle(
                                                            fontSize: 19,
                                                            fontWeight: FontWeight.bold,),
                                                      ),
                                                    if(e['s_identification_id'].toString() != 'false')
                                                    Container(
                                                      padding: const EdgeInsets.all(7),
                                                      child: Text(
                                                        e['s_identification_id'].toString(),
                                                        style: const TextStyle(
                                                            color: Colors.blueGrey,
                                                            fontWeight: FontWeight.bold
                                                          ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.all(7),
                                                      child: Text(
                                                        e['job_title'].toString(),
                                                        style: TextStyle(
                                                            color: Colors.deepOrange.shade700,
                                                            fontWeight: FontWeight.bold
                                                          ),
                                                      ),
                                                    ),
                                                  ]),
                                                  Container(
                                                    margin: const EdgeInsets.all(10),
                                                    child: Wrap(
                                                      spacing: 20,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 20,
                                                          child: IconButton(
                                                            icon: const Icon(Icons.call),
                                                            onPressed: () {
                                                                Call(
                                                                    e['mobile_phone'].toString(),
                                                                    e['work_phone'].toString()
                                                                  );
                                                            },
                                                          ),
                                                        ),
                                                        CircleAvatar(
                                                          radius: 20,
                                                          child: IconButton(
                                                            icon: const Icon(Icons.message),
                                                            onPressed: () {
                                                            Message(
                                                                e['mobile_phone'].toString(),
                                                                e['work_phone'].toString());
                                                            },
                                                          ),
                                                        ),
                                                        CircleAvatar(
                                                          radius: 20,
                                                          child: IconButton(
                                                            icon: const Icon(Icons.email),
                                                            onPressed: () {
                                                              Email(e['work_email'].toString());
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if(e['mobile_phone'].toString() != 'false')
                                                      Container(
                                                        child:Wrap(
                                                                children: [
                                                                  const Icon( Icons.phone,size: 25,color: Colors.deepOrange,),
                                                                  Container(
                                                                    margin: const EdgeInsets.only(top: 3,left: 10),
                                                                    child: Text(
                                                                      e['mobile_phone'],
                                                                      style: const TextStyle(fontSize: 17,),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                      ),
                                                      if(e['work_phone'].toString() != 'false')
                                                      Container(
                                                        padding: const EdgeInsets.only(top: 15),
                                                        child: Wrap(
                                                                children: [
                                                                  const Icon(Icons.call,size: 25,color: Colors.deepOrange,),
                                                                  Container(
                                                                    margin:const EdgeInsets.only(top: 3,left: 10),
                                                                    child: Text(
                                                                      e['work_phone'],
                                                                      style: const TextStyle(fontSize: 17),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                      ),
                                                      if (e['work_email'].toString() != 'false')
                                                        Container(
                                                          padding: const EdgeInsets.only(top: 15),
                                                          child: Wrap(
                                                                  children: [
                                                                    const Icon(Icons.email,size: 25,color: Colors.deepOrange,),
                                                                    Container(
                                                                      margin:const EdgeInsets.only(top: 3,left: 10),
                                                                      child: Text(
                                                                        e['work_email'],
                                                                        style: const TextStyle(fontSize: 17),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                        ),
                                                      if(e['address_id'].toString() != 'false')
                                                        Container(
                                                            padding: const EdgeInsets.only(top: 15),
                                                            child: StreamBuilder<QuerySnapshot>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection('address')
                                                                  .where('id',
                                                                  isEqualTo:  e['address_id'][0])
                                                                  .snapshots(),
                                                              builder: (context, snapshot){
                                                                if (!snapshot.hasData) {
                                                                  return Container(
                                                                    child: const Center(
                                                                      child:CircularProgressIndicator(),
                                                                    ),
                                                                  );
                                                                } else{
                                                                  return Column(
                                                                    children: [
                                                                      ...snapshot.data!.docs.map((address){
                                                                        if(address['street'].toString() == 'false' && address['street2'].toString() == 'false' && address['city'].toString() == 'false'){
                                                                          return Text("");
                                                                        }  else{
                                                                          return Wrap(
                                                                            children: [
                                                                              const Icon(Icons.location_pin,size: 25,color: Colors.deepOrange,),
                                                                              Container(
                                                                                margin:const EdgeInsets.only(top: 5,left: 10),
                                                                                child: Wrap(
                                                                                  children: [
                                                                                    address['street'].toString() == 'false' ? const Text('') :
                                                                                    Text(address['street'],style: const TextStyle(fontSize: 16)),

                                                                                    address['street2'].toString() == 'false' ? const Text('') :
                                                                                    Text(', ' + address['street2'],style: const TextStyle(fontSize: 16)),

                                                                                    address['city'].toString() == 'false' ? const Text('') :
                                                                                    Text(', ' + address['city'],style: const TextStyle(fontSize: 16)),
                                                                                  ],),
                                                                              )
                                                                            ],
                                                                          );
                                                                        }
                                                                      })
                                                                    ],
                                                                  );
                                                                }
                                                              },
                                                            )
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(top: 40),
                                            child: Center(
                                                child: QrImage(
                                                  data: e['mobile_phone'].toString() == 'false' ? e['name'] + "\n\n" + e['s_identification_id'].toString() : e['name'] + "\n\n" + e['s_identification_id'].toString() + "\n\n" + e['mobile_phone'].toString(),
                                                  version: QrVersions.auto,
                                                  size: 100,
                                                  gapless: false,
                                                ),
                                            ),
                                          ),
                                        ],
                                      );
                                    })
                                  ],
                                );
                              }
                            },
                          ),
                        );
                      })
                    ],
                  ),
                );
              }
            },
          ),
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
