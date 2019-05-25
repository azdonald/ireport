import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';



class MapApp extends StatefulWidget{
  double latitude;
  double longitude;

  MapApp({Key key, this.latitude, this.longitude}):super(key:key);
  @override
  MapState createState() => new MapState();
}

class MapState extends State<MapApp>{
  final _formKey = GlobalKey<FormState>();
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId markerId = MarkerId("qwertyuiop");

  bool pressed = false;
  bool _saving = false;

  List _reasons = ['Pot Hole', 'Defective House', 'Open Man Hole'];

  List<DropdownMenuItem<String>> _dropMenuItems;
  String _default;
  File _image;

  @override
  void initState() {
    _dropMenuItems = getMenuItems();
    super.initState();
  }

  List<DropdownMenuItem<String>> getMenuItems(){
    List<DropdownMenuItem<String>> items = new List();
    for(String reason in _reasons){
      items.add(new DropdownMenuItem(
          value: reason,
          child: new Text(reason)
      )
      );
    }

    return items;
  }


  CameraPosition getCameraPosition(){
    return CameraPosition(
      zoom: 16.0,
      target: LatLng(widget.latitude, widget.longitude)
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(widget.latitude, widget.longitude),
      infoWindow: InfoWindow(title: "You are here", snippet: '*')
    );
    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('Lagos iReport'),
      ),
      body: Stack(
        children: <Widget>[
           mapBuilder(),
          pressed ? ModalProgressHUD(child: formElements(), inAsyncCall: _saving): SizedBox(height: 1.0,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: pressed ? SizedBox(height: 1.0,) : addButton()
            ),
          ),
        ],
      ),
    );
  }


  Widget mapBuilder(){
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: getCameraPosition(),
      myLocationEnabled: true,
      markers: Set<Marker>.of(markers.values),
    );
  }

  Widget addButton(){
    return FloatingActionButton(
      onPressed: (){
        setState(() {
          pressed = true;
        });
      },
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.green,
      child: const Icon(Icons.add, size: 36.0),
    );
  }


  Widget formElements(){
    return Center(
      child: Container(
        color: Colors.white,
        child: new Form(
            key: _formKey,
            child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  new TextFormField(
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: "Provide a title"
                    ),

                  ),
                  SizedBox(height: 20.0,),
                  new TextField(
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.solid)),
                        hintText: 'Please enter a description of the problem'
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  new DropdownButton(
                    isExpanded: true,
                    value: _default,
                    items: _dropMenuItems,
                    onChanged: changedDropDownItem,
                    hint: Text('SELECT Category'),

                  ),
                  SizedBox(height: 20.0,),
                  new Row(
                    children: <Widget>[
                      Expanded(
                        child:  new TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              hintText: 'Your phone number'
                          ),
                        ),
                      ),
                      new FloatingActionButton(
                          child: Icon(Icons.add_a_photo),
                          tooltip: 'Pick Image',
                          onPressed: _optionsDialogBox,
                        ),
                    ],
                  ),
                  SizedBox(height: 12.0,),
                  new Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)
                      ),
                      onPressed: submit,
                      padding: EdgeInsets.all(12),
                      color: Colors.redAccent,
                      child: Text('Report', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ]
            )
        ),
      )
    );
  }


  void changedDropDownItem(String selectedItem) {
    print("Selected city $selectedItem, we are going to refresh the UI");
    setState(() {
      _default = selectedItem;
    });
  }

  // Get image
  Future getImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
      print(_image.path);
      Navigator.of(context).pop();
    });
  }

  Future openGallery() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print(_image.path);
      Navigator.of(context).pop();
    });
  }

  Future<void> _optionsDialogBox(){
    return showDialog(context: context,
      builder: (BuildContext context){
      return AlertDialog(
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              GestureDetector(
                child: new Text("Take a picture"),
                onTap: getImage,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
              ),
              GestureDetector(
                child: new Text("Select from gallery"),
                onTap: openGallery,
              )
            ],
          ),
        ),
      );
      }
    );
  }

  void submit(){
    setState(() {

      _saving = true;
    });

    //Simulate a service call
    print('submitting to backend...');
    new Future.delayed(new Duration(seconds: 4), () {
      Fluttertoast.showToast(msg: "Thanks for your report", toastLength: Toast.LENGTH_LONG);
      setState(() {
        _saving = false;
        pressed = false;
      });
    });

  }


}