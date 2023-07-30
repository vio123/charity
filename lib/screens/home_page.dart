import 'package:charity/models/charity_card_model.dart';
import 'package:charity/widgets/card_fund.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseReference databaseReference;

  @override
  void initState() {
    super.initState();
    databaseReference = FirebaseDatabase.instance.reference();
  }

  List<CharityCardModel> items = [];

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Center(child: Text("Fundraiser")),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            showSearch(context: context, delegate: DataSearch(items));
          },
          icon: const Icon(Icons.search),
        ),
        actions: [
          currentUser != null ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text("Profile"),
            ),
          ) : Container(),
          currentUser == null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text("Sign In"),
                  ),
                )
              : TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.popAndPushNamed(context, '/login');
                    } catch (e) {}
                  },
                  child: const Text("Log Out"),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/addCharity');
              },
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                    const BorderSide(color: Colors.green)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0))),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: const Text("Start a found"),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: databaseReference.child('charityFund').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('A apărut o eroare'));
            } else {
              items.clear();
              DataSnapshot data = snapshot.data!.snapshot;
              Iterable<DataSnapshot> snapshots = data.children;

              snapshots.forEach((snapshot) {
                CharityCardModel item = CharityCardModel.fromSnapshot(snapshot);
                items.add(item);
              });
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: 1),
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
                          Navigator.pushNamed(
                              context, '/details/${items[index].id}');
                        },
                        id: items[index].id,
                      ),
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String?> {
  final List<CharityCardModel> items;
  final List<String> filters = ["Charity", "Education", "Animals"];
  final List<bool> filtersSelected;

  DataSearch(this.items) : filtersSelected = List<bool>.filled(3, false);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var filteredCities = items.where((item) {
      if (filtersSelected[0] && item.type != filters[0]) return false;
      if (filtersSelected[1] && item.type != filters[1]) return false;
      if (filtersSelected[2] && item.type != filters[2]) return false;
      return item.causeName.toLowerCase().startsWith(query.toLowerCase());
    }).toList();

    return Column(
      children: [
        Wrap(
          children: List<Widget>.generate(filters.length, (int index) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: FilterChip(
                label: Text(filters[index]),
                selected: filtersSelected[index],
                onSelected: (bool value) {
                  for (int i = 0; i < filtersSelected.length; i++) {
                    if (i == index) {
                      filtersSelected[i] = value;
                    } else {
                      filtersSelected[i] = false;
                    }
                  }
                  // After changing filter selection, call setState to update the UI
                  (context as Element).markNeedsBuild();
                },
              ),
            );
          }),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredCities.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredCities[index].causeName),
                onTap: () {
                  Navigator.pushNamed(
                      context, '/details/${items[index].id}');
                  // Handle item tap
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
