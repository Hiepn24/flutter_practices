import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Personal Profile',
          debugShowCheckedModeBanner: false,

          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),

          themeMode: currentMode,

          home: ProfilePage(),
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Personal Profile'),
        actions: [
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              themeNotifier.value =
              themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 600;

            Widget cardsSection = isWide
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSkillsCard(context)),
                SizedBox(width: 16),
                Expanded(child: _buildSocialsCard(context)),
              ],
            )
                : Column(
              children: [
                _buildSkillsCard(context),
                SizedBox(height: 16),
                _buildSocialsCard(context),
              ],
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileInfo(context),
                  SizedBox(height: 24),
                  cardsSection,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 60,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Nguyen Hiep',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          'Flutter 2025',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildSkillsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kỹ Năng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.code, color: Colors.blue),
              title: Text('Unity & C#'),
            ),
            ListTile(
              leading: Icon(Icons.web, color: Colors.green),
              title: Text('NestJS & MySQL'),
            ),
            ListTile(
              leading: Icon(Icons.build, color: Colors.orange),
              title: Text('WordPress & PHP'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liên Kết',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.link),
              title: Text('GitHub'),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(Icons.link),
              title: Text('LinkedIn'),
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}