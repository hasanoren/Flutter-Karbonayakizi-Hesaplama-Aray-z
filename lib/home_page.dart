import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String serverUrl = 'http://10.0.2.2:5000/predict';
  List<double> rams = [2, 3, 4, 6, 8, 12, 16];

  double? ram = 8;
  double screen = 5.5;
  double capacity = 5500;
  List<String> socialMedias = ["instagram", "twitter", "youtube"];
  String? currentSocialMedia = "instagram";
  Map<String, dynamic> responseData = {
    "buzdolabi": 0,
    "camasirmakinesi": 0,
    "araba": 0,
    "prediction": 0,
  };
  double? prediction;
  double? buzdolabi;
  double? camasirmakinesi;
  double? araba;

  double? predictToAraba;
  double? predictToBuzdolabi;
  double? predictToCamasirmakinesi;
  bool isCardVisible = false;
  bool isImageVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Karbon Ayak İzi Hesapla',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
              visible: isImageVisible,
              child: isImageVisible == false
                  ? SizedBox(
                      height: 0,
                    )
                  : Container(
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Image.asset(
                        "images/leaf2.jpg",
                      ),
                    ),
            ),
            Visibility(
              visible: isCardVisible,
              child: Card(
                elevation: 5, // Set the elevation for a shadow effect
                margin: EdgeInsets.all(
                    16), // Set margin to give some spacing around the card
                child: Padding(
                  padding: EdgeInsets.all(
                      16), // Set padding for the content inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction == null
                            ? ""
                            : "Bir saatlik $currentSocialMedia kullanımı:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        prediction == null
                            ? ""
                            : "${(prediction!).toString().substring(0, 8)} kg karbon salınımı yapar.",
                        style: TextStyle(
                            fontSize: 18), // Set the font size as needed
                      ),
                      SizedBox(height: 10),
                      Text(
                        prediction == null
                            ? ""
                            : "${predictToAraba.toString().substring(0, 5)} km otomobil yolculuğuna,",
                        style: TextStyle(
                            fontSize: 18), // Set the font size as needed
                      ),
                      SizedBox(height: 10),
                      Text(
                        prediction == null
                            ? ""
                            : "${predictToBuzdolabi.toString().substring(0, 5)} saat buzdolabı kullanımına,",
                        style: TextStyle(
                            fontSize: 18), // Set the font size as needed
                      ),
                      SizedBox(height: 10),
                      Text(
                        prediction == null
                            ? ""
                            : "${predictToCamasirmakinesi.toString().substring(0, 5)} saat çamaşır makinesi kullanımına denk gelir.",
                        style: TextStyle(
                            fontSize: 18), // Set the font size as needed
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !isCardVisible,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _ramInput(context),
                  const SizedBox(height: 10),
                  _screenSize(),
                  const SizedBox(height: 10),
                  _batteryCapacity(),
                  const SizedBox(height: 10),
                  const Text(
                    'Hesaplanacak Uygulamalar:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  RadioListTile<String>(
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: const Icon(FontAwesomeIcons.instagram),
                    title: const Text('Instagram'),
                    value: socialMedias[0],
                    groupValue: currentSocialMedia,
                    onChanged: (String? value) => {
                      setState(() {
                        currentSocialMedia = value;
                      })
                    },
                  ),
                  RadioListTile<String>(
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: const Icon(FontAwesomeIcons.twitter),
                    title: const Text('Twitter'),
                    value: socialMedias[1],
                    groupValue: currentSocialMedia,
                    onChanged: (String? value) => {
                      setState(() {
                        currentSocialMedia = value;
                      })
                    },
                  ),
                  RadioListTile<String>(
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: const Icon(FontAwesomeIcons.youtube),
                    title: const Text('Youtube'),
                    value: socialMedias[2],
                    groupValue: currentSocialMedia,
                    onChanged: (String? value) => {
                      setState(() {
                        currentSocialMedia = value;
                      })
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  {isImageVisible == false ? sendDataToServer() : reset()},
              child: Text(isImageVisible == false ? 'Hesapla' : "Temizle"),
            )
          ],
        ),
      ),
    );
  }

  void reset() {
    setState(() {
      isCardVisible = false;
      isImageVisible = false;
    });
  }

  void sendDataToServer() async {
    Map<String, dynamic> data = {
      'ram': ram,
      'screen': screen,
      'capacity': capacity,
      'currentSocialMedia': currentSocialMedia
    };

    String jsonData = jsonEncode(data);

    print(jsonData);

    try {
      var url = Uri.parse(serverUrl);

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Data sent successfully!');
        // print('Response: ${response.body}');
        setState(() {
          isCardVisible = true;
          isImageVisible = true;
          responseData = jsonDecode(response.body);
          prediction = responseData["prediction"];
          buzdolabi = responseData["buzdolabi"];
          camasirmakinesi = responseData["camasirmakinesi"];
          araba = responseData["araba"];

          prediction = prediction! / 1000000 * 0.21233 * 3.8;
          buzdolabi = buzdolabi! / 24 * 0.21233;
          camasirmakinesi = camasirmakinesi! * 0.21233;
          predictToAraba = prediction! / araba!;
          predictToBuzdolabi = prediction! / buzdolabi!;
          predictToCamasirmakinesi = prediction! / camasirmakinesi!;
        });
      } else {
        print('Failed to send data. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  Widget _batteryCapacity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pil Kapasitesi (mAh): ${capacity.toInt()}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Slider(
          divisions: 122,
          min: 800,
          max: 13000,
          value: capacity,
          onChanged: (value) => {
            setState(() {
              capacity = value;
            })
          },
        ),
      ],
    );
  }

  Widget _screenSize() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ekran Boyutu: $screen',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Slider(
          divisions: 20,
          min: 5,
          max: 7,
          value: screen,
          onChanged: (value) => {
            setState(() {
              screen = value;
            })
          },
        ),
      ],
    );
  }

  Widget _ramInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RAM:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(
          child: DropdownButtonFormField<double>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 1, color: Colors.black)),
            ),
            onChanged: (selectedValue) => {
              if (selectedValue is double)
                {
                  setState(() {
                    ram = selectedValue;
                  })
                }
            },
            value: ram,
            items: rams
                .map(
                  (item) => DropdownMenuItem<double>(
                    value: item,
                    child: Text("${item.toInt()} GB"),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
