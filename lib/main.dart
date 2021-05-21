import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  late File _image;
  List data = [];
  List imagesUrl = [];
  String getEndPoint = "http://192.168.1.2:3000/photos";
  String uploadEndPoint = "http://192.168.1.2:3000/photos/upload";
  late File file;
  String status = '';
  String errMessage = 'Error Uploading Image';
  Future<String> fetchDataFromApi() async {
    imagesUrl = [];
    var jsonData = await http.get(Uri.parse(getEndPoint));
    var fetchData = jsonDecode(jsonData.body);
    setState(() {
      data = fetchData;
      data.forEach((element) {
        imagesUrl.add(element['photoURL']);
      });
    });
    return "Success";
  }
  Future getImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print("Image path: " + pickedFile.path);
        upload(_image);
        print("returned from upload");
      } else {
        print('No image selected.');
      }
    });
  }

  upload(File imageFile) async {
    var stream = imageFile.openRead();
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse(uploadEndPoint);

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: (imageFile.path).split('/').last);

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
    fetchDataFromApi();
  }

  @override
  Widget build(BuildContext context) {

    var title = 'Images from backend server';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: GridView.builder(
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: imagesUrl.length,
          itemBuilder: (BuildContext context, int index) {
            return Image.network(
              imagesUrl[index],
              fit: BoxFit.cover,
            );
          },
        ),
          floatingActionButton: FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Increment',
          child: Icon(Icons.photo_album),
        ),
      )
   );
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromApi();
  }
}
