// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // You need to import these 2 libraries besides another libraries to work with this code
  final TextEditingController linkcontroller = TextEditingController();
  final ReceivePort _port = ReceivePort();
  int progress = 0;
  bool flage = false;
  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'Downloading...');
    _port.listen((data) {
      setState(() {
        progress = data[2];
      });
      // ignore: avoid_print
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(id, status, progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('Downloading...');
    send!.send([id, status, progress]);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            height: 300,
            width: 200,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(progress.toStringAsFixed(0)),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter text',
                    ),
                    textAlign: TextAlign.center,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Text is empty';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (_formKey.currentState!.validate()) {
                        final status = await Permission.storage.request();

                        if (status.isGranted) {
                          final directory = await getExternalStorageDirectory();

                          String basename = path.basename(linkcontroller.text);

                          'Download';
                          await FlutterDownloader.enqueue(
                            url:
                                "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                            savedDir: directory!.path,
                            fileName: basename,
                            showNotification: true,
                            openFileFromNotification: false,
                          );
                        } else {
                          // ignore: avoid_print
                          print('Permission Denied');
                        }
                      }
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: const Text("Download"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
