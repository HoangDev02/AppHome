import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_home/screens/TemperatureChartPage.dart';

class TemperatureTile extends StatefulWidget {
  final String title;
  final String value;
  final String humb;
  final String humbValue;

  TemperatureTile({required this.title, required this.value, required this.humb, required this.humbValue});

  @override
  _TemperatureTileState createState() => _TemperatureTileState();
}

class _TemperatureTileState extends State<TemperatureTile> {
  String location ='Null, Press Button';
  String Address = '';

  @override
  void initState() {
    super.initState();
    // getCurrentLocation();
  }

  Future<void> showLocationPermissionToast() async {
    Fluttertoast.showToast(
      msg: "Please enable location services to access your location.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled. - Kiểm tra xem dịch vụ vị trí có được bật không.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address = '${place.country}';
    setState(()  {
    });
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedBuilder: (context, openContainer) {
        return _buildClosedTile();
      },
      openBuilder: (context, closeContainer) {
        return _buildOpenTile();
      },
    );
  }

  Widget _buildClosedTile() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now); // Định dạng ngày
    String formattedTime = DateFormat('HH:mm:ss').format(now); // Định dạng giờ
    return Container(
      width: 330,
      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3366FF), Color(0xFF66CCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('$formattedDate',style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),

              SizedBox(height: 10),
              Text(
                'CLOUDY',
                style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),

              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      Position position = await _getGeoLocationPosition();
                      GetAddressFromLatLong(position);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(Icons.cloud, color: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    Address,
                    style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Text(widget.title, style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '°C',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
              Text(widget.humb, style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.humbValue,
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '%',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpenTile() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildClosedTile(),
          SizedBox(height: 20),
          // Text(
          //   'Details about ${widget.title}',
          //   style: TextStyle(
          //     fontSize: 18,
          //     color: Colors.black,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          SizedBox(height: 10),
          Expanded(
            child: TemperatureChartPage(),
          ),
        ],
      ),
    );
  }
}
