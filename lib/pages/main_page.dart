import 'package:flutter/material.dart';
// import 'package:sensors_app/pages/Compass.dart';
import 'package:sensors_app/pages/google_maps.dart';
import 'package:sensors_app/pages/motion_chart.dart';
import 'package:sensors_app/pages/smart_lights.dart';
// import 'package:sensors_app/pages/step_counter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  
  @override
  void initState() {
    super.initState();
  }

    


  int selectedTab = 0;

  final List<String> tabTitles = ['Motion Sensor','Current Location', 'Smart Lights'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(     
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF66BB6A),
              ),
              child: Center(child: Text('IPSUM-TAB', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            for (int index = 0; index < tabTitles.length; index++)
              ListTile(
                selectedTileColor: Colors.grey[300],
                selectedColor: Colors.green[400],
                title: Text(tabTitles[index]),
                trailing: icons[index],              
                selected: selectedTab == index,
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                  Navigator.pop(context);
                }
              ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, weight: 30.0),
        title: Text(tabTitles[selectedTab], style: const TextStyle(color: Colors.white)), 
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
      ),
      body: _buildBody(selectedTab),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green[400],
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        currentIndex: selectedTab,
        onTap: (index) {
            setState(() {
              selectedTab = index;
            });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.directions_walk), label: 'Motion Sensor'),
          // BottomNavigationBarItem(icon: Icon(Icons.compass_calibration), label: 'Compass'),
          BottomNavigationBarItem(icon: Icon(Icons.location_searching), label: 'Current Location'),
          BottomNavigationBarItem(icon: Icon(Icons.light), label: 'Smart Lights'),
        ],
      ),
    );
  }

  List<Icon> icons = [const Icon(Icons.directions_walk), const Icon(Icons.location_searching), const Icon(Icons.light)];
  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const MotionChart();
      // case 0:
      //   return const MyCompass();
      case 1:
        return const MyCurrentLocation(); 
      case 2:
        return const SmartLights();
      default:
        return Container();
    }
  }

}