import 'package:charity/models/charity_card_model.dart';
import 'package:charity/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../widgets/card_fund.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DatabaseReference databaseReference;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final usernameController = TextEditingController();
  final _formField = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Reset password'),
            content: const Column(
              children: [
                Text(
                    "You will receive a link on your email for password reset.")
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Închide'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print("Link de resetare a parolei trimis pe email");
    } catch (e) {
      print("A aparut o eroare la trimiterea emailului: $e");
    }
  }

  void updateChildData(String childKey, Map<String, dynamic> data) {
    databaseReference.child("Users").child(childKey).update(data).then((_) {
      print('Transaction committed.');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Username changed")));
    }).catchError((e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    });
  }

  @override
  void initState() {
    super.initState();
    databaseReference = FirebaseDatabase.instance.reference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: databaseReference.child("Users").onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            return const Center(child: Text('A apărut o eroare'));
          } else {
            DataSnapshot data = snapshot.data!.snapshot;
            Iterable<DataSnapshot> snapshots = data.children;
            List<UserModel> items = [];
            snapshots.forEach((element) {
              UserModel item = UserModel.fromSnapshot(element);
              if (item.id == currentUser?.uid) {
                items.add(item);
              }
            });
            usernameController.text = items[0].username;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Form(
                    key: _formField,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            prefixIcon: const Icon(Icons.people),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value!.isEmpty) return "Enter username";
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1BAC4B)),
                          onPressed: () async {
                            sendPasswordResetEmail(
                                currentUser!.email.toString());
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Change password",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1BAC4B)),
                            onPressed: () async {
                              if (_formField.currentState!.validate()) {
                                updateChildData(items[0].key,
                                    {'username': usernameController.text});
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "Save",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "My Charities",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: databaseReference
                        .child("charityFund")
                        .orderByChild("userEmail")
                        .equalTo(FirebaseAuth.instance.currentUser!.email)
                        .onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return const Center(child: Text('A apărut o eroare'));
                        } else {
                          DataSnapshot data = snapshot.data!.snapshot;
                          Iterable<DataSnapshot> snapshots = data.children;
                          List<CharityCardModel> items = [];
                          snapshots.forEach((element) {
                            CharityCardModel item =
                                CharityCardModel.fromSnapshot(element);
                            items.add(item);
                          });
                          if (items.isNotEmpty) {
                            return Flexible(
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CardFund(
                                      raisedFunds: items[index].raisedFunds,
                                      targetFunds: items[index].targetFunds,
                                      imageLink: items[index].imageLink,
                                      city: items[index].city,
                                      causeName: items[index].causeName,
                                      description: items[index].description,
                                      onClick: () {
                                        Navigator.pushNamed(context, '/details/${items[index].id}');
                                      },
                                      id: items[index].id,
                                    ),
                                  );
                                },
                              ),
                            );

                      } else {
                            return const Text("");
                          }
                        }
                      }
                    },
                  )
                ],
              ),
            );
          }
        }
      },
    ));
  }
}
