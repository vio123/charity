import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/charity_card_model.dart';
import '../services/paystack_integration.dart';

class DetailsCharityScreen extends StatefulWidget {
  final String id;

  const DetailsCharityScreen({super.key, required this.id});

  @override
  State<DetailsCharityScreen> createState() => _DetailsCharityScreenState();
}

class _DetailsCharityScreenState extends State<DetailsCharityScreen> {
  late DatabaseReference databaseReference;
  final amountController = TextEditingController();
  final _formField = GlobalKey<FormState>();
  

  @override
  void initState() {
    super.initState();
    databaseReference = FirebaseDatabase.instance.reference();
  }

  void updateChildData(String childKey, Map<String, dynamic> data) {
    databaseReference.child("charityFund").child(childKey).update(data).then((_) {
      print('Transaction committed.');
    }).catchError((e) {
      print(e);
    });
  }

  String generateRef(){
    final randomCode = Random().nextInt(3234234);
    return 'ref-$randomCode';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: databaseReference.child('charityFund').child(widget.id).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('A apărut o eroare'));
            } else {
              DataSnapshot data = snapshot.data!.snapshot;
              CharityCardModel item = CharityCardModel.fromSnapshot(data);
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        item.causeName,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      item.imageLink != ''
                          ? Image.network(
                              item.imageLink,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 400,
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      LinearProgressIndicator(
                        value: item.raisedFunds /
                            item.targetFunds, // Progresul ca fracțiune din țintă
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${item.raisedFunds.toStringAsFixed(2)} of ${item.targetFunds.toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1BAC4B)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Donate'),
                                content: Form(
                                  key: _formField,
                                  child: SingleChildScrollView(
                                      child: Column(
                                    children: [
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                        ],
                                        controller: amountController,
                                        decoration: InputDecoration(
                                          labelText: "Amount",
                                          labelStyle: const TextStyle(
                                              color: Colors.black),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                        ),
                                        style: const TextStyle(
                                            color: Colors.black),
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Enter amount";
                                          return null;
                                        },
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF1BAC4B)),
                                        onPressed: () async {
                                          if (_formField.currentState!
                                              .validate()) {
                                            Navigator.of(context).pop();
                                            final ref = generateRef();
                                            final amount = int.parse(amountController.text);

                                            await PaystackPopup.openPaystackPopup(
                                              email: "test@gmail.com",
                                              amount: (amount * 100).toString(),
                                              ref: ref,
                                              onClosed: (){
                                                debugPrint('Could\'nt finish payment');
                                              },
                                              onSuccess: () {
                                                debugPrint('successful payment');
                                                updateChildData(widget.id, {
                                                  'raisedFunds': amount
                                                });
                                              },
                                            );
                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            "Donate",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Închide'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Donate",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Description',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 20),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
