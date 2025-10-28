import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'events_page.dart';
import 'home_page.dart';
import 'ngos_page.dart';
import 'profile_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

class Events extends StatelessWidget {
  const Events({super.key});
  @override
  Widget build(BuildContext context) {
    return const EventsPage();
  }
}

class Ngos extends StatelessWidget {
  const Ngos({super.key});
  @override
  Widget build(BuildContext context) {
    return const NgosPage();
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // O an hangi sayfanın seçili olduğunu tutar

  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    Events(),
    Ngos(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // index'i günceller body o indexe göre değişir
    });
  }

  final List<String> _pageTitles = [
    'Anasayfa',
    'Etkinlikler',
    'STK\'lar',
    'Profil'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[
            _selectedIndex]), // Başlığı seçili sayfaya göre değiştir
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
