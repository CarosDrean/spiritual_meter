import 'package:flutter/material.dart';
import 'package:spiritual_meter/src/presentation/screen/record_screen.dart';
import 'package:spiritual_meter/src/presentation/screen/statistics_screen.dart';

import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const RecordScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Cambia la página sin animación
    // O para una animación suave:
    // _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Opcional: Puedes poner un único AppBar aquí si quieres que sea consistente en todas las páginas
      // y no manejarlo en cada pantalla individualmente.
      // appBar: AppBar(
      //   title: Text(_appBarTitles[_selectedIndex]), // Título dinámico
      // ),
      body: PageView(
        controller: _pageController,
        // Esto es importante para que el BottomNavigationBar se actualice
        // si el usuario desliza entre las páginas en lugar de tocar el icono
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens, // Las pantallas que se mostrarán
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Registro',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}