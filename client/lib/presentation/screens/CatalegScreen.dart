import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../widgets/seriesCategoria.dart';

class CatalegScreen extends StatefulWidget {
  final AppDatabase db;

  const CatalegScreen({super.key, required this.db});

  @override
  State<CatalegScreen> createState() => _CatalegScreenState();
}

class _CatalegScreenState extends State<CatalegScreen> {
  AppDatabase get db => widget.db;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,
      body: Column(
        children: [
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              children: [
                CategorySection(db: db),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
