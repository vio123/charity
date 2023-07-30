class CardFund extends StatelessWidget {
  const CardFund({
    Key? key,
    required this.raisedFunds,
    required this.targetFunds,
    required this.imageLink,
    required this.city,
    required this.causeName,
    required this.description,
  }) : super(key: key);

  final double raisedFunds;
  final double targetFunds;
  final String imageLink;
  final String city;
  final String causeName;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 10,
      child: Container(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Uint8List?>(
                future: _loadImageFromUrl(imageLink),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading image');
                  } else {
                    final imageBytes = snapshot.data;
                    if (imageBytes != null) {
                      return Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      );
                    } else {
                      return Text('Image not available');
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              Text(
                city,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                causeName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: raisedFunds / targetFunds,
              ),
              const SizedBox(height: 10),
              Text(
                '${raisedFunds.toStringAsFixed(2)} of ${targetFunds.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> _loadImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return null;
  }
}
