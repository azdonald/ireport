import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:ireport/api.dart';



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
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool pressed = false;
  bool _saving = false;
  bool showImage = false;
  bool showAddress = false;

  List _reasons = ['Pot Hole', 'Defective House', 'Open Man Hole'];
  List<DropdownMenuItem<String>> _categories;
  List<Address>_addresses;
  String _selectedCategory;
  String _selectedAddress;
  File _image;

  @override
  void initState() {
    _categories = getCategoryItems();
    super.initState();
    getAddresses();
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
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Provide a title"
                    ),

                  ),
                  SizedBox(height: 20.0,),
                  new TextField(
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    controller: descriptionController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.solid)),
                        hintText: 'Please enter a description of the problem'
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  new DropdownButton(
                    isExpanded: true,
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: changeSelectedCategory,
                    hint: Text('SELECT Category'),

                  ),
                  SizedBox(height: 20.0,),
                  new DropdownButton(
                    hint: new Text('Please select the closest Address'),
                    isExpanded: true,
                    items: _addresses.map((addy){
                      return new DropdownMenuItem(
                        child: new Text(addy.addressLine),
                        value: addy.addressLine
                      );
                    }).toList(),
                    onChanged: getSelectedAddress,
                    value: _selectedAddress,
                  ),
                  SizedBox(height: 20.0,),
                  new TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: 'Your phone number'
                    ),
                  ),
                  SizedBox(height: 12.0,),
                  new Row(
                    children: <Widget>[
                      Expanded(
                        child: showImage ? imageThumbNail() : SizedBox(height: 2.0,),
                      ),
                      new FloatingActionButton(
                        child: Icon(Icons.add_a_photo),
                        tooltip: 'Pick Image',
                        onPressed: _optionsDialogBox,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0,),
                  new Row(
                    children: <Widget>[
                      Expanded(
                        child: new Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)
                            ),
                            onPressed: submit,
                            padding: EdgeInsets.all(12),
                            color: Colors.green[900],
                            child: Text('Report', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ),
                      Expanded(
                        child: new Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)
                            ),
                            onPressed: cancel,
                            padding: EdgeInsets.all(12),
                            color: Colors.redAccent,
                            child: Text('Cancel', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      )
                    ],
                  ),
                ]
            )
        ),
      )
    );
  }

  Widget imageThumbNail(){
    return new Container(
      width: 720.0,
      height: 65.0,
      child: Image.file(
        _image,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  // Get selected Category
  void changeSelectedCategory(String selectedItem) {
    print("Selected city $selectedItem, we are going to refresh the UI");
    setState(() {
      _selectedCategory = selectedItem;
    });
  }

  // Get selected Address
  void getSelectedAddress(String selectedItem){
    setState(() {
      _selectedAddress = selectedItem;
    });
  }

  // Get image
  Future getImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
      print(_image.path);
      Navigator.of(context).pop();
      showImage = true;
    });
  }

  // Handle selecting picture from Gallery
  Future openGallery() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print(_image.path);
      Navigator.of(context).pop();
      showImage = true;
    });
  }

  // Dialog box for either taking a picture or selecting from gallery
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

  // Get addresses from latitude and longitude
  getAddresses () async{
    final coordinates = new Coordinates(widget.latitude, widget.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    if (addresses != null){
      setState(() {
        _addresses = addresses;
        showAddress = true;
      });
    }
  }


  // Submit report
  void submit() async{
    setState(() {
      _saving = true;
    });

    //Simulate a service call
    print('submitting to backend...');
    
    var message = await sendData(titleController.text, descriptionController.text, _selectedCategory, widget.latitude, widget.longitude);

      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
      setState(() {
        _saving = false;
        pressed = false;
      });

  }

  // Cancel
  void cancel(){
    setState(() {
      pressed = false;
      showImage = false;
    });
  }

  // Prep category for drop down box
  List<DropdownMenuItem<String>> getCategoryItems(){
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


}