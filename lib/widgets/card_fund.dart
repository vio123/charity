import 'package:flutter/material.dart';

class CardFund extends StatelessWidget {
  const CardFund(
      {super.key,
      required this.raisedFunds,
      required this.targetFunds,
      required this.imageLink,
      required this.city,
      required this.causeName,
      required this.description,
      required this.onClick,
      required this.id});

  final double raisedFunds;
  final double targetFunds;
  final String imageLink;
  final String city;
  final String causeName;
  final String description;
  final Function() onClick;
  final String id;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 10,
        child: Container(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageLink != ''
                    ? Image.network(
                        imageLink,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      )
                    : Container(),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  city,
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Text(
                  causeName,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 10,
                ),
                LinearProgressIndicator(
                  value: raisedFunds /
                      targetFunds, // Progresul ca fracțiune din țintă
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${raisedFunds.toStringAsFixed(2)} of ${targetFunds.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
