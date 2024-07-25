import 'package:flutter/material.dart';


class CitySelectionDialog extends StatefulWidget {
  final List<String> cities;
  final Function(String) onSelectedCity;

  String _selectedCity = "";

  CitySelectionDialog({required this.cities, required this.onSelectedCity});

  @override
  _CitySelectionDialogState createState() => _CitySelectionDialogState();
}

class _CitySelectionDialogState extends State<CitySelectionDialog> {
  final TextEditingController _controller = TextEditingController();
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
  }

  void _filterCities(String query) {
    final filteredCities = widget.cities.where((city) {
      final cityLower = city.toLowerCase();
      final queryLower = query.toLowerCase();
      return cityLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredCities = filteredCities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                onChanged: _filterCities,
                decoration: InputDecoration(
                  hintText: "Search city",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCities.length,
                itemBuilder: (context, index) {
                  final city = _filteredCities[index];
                  return ListTile(
                    title: Text(city),
                    onTap: () {
                      Navigator.of(context).pop(city);
                      widget.onSelectedCity(city);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}