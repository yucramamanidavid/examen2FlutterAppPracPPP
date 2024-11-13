import 'package:flutter/material.dart';
import '../models/practica.dart';
import '../services/api_service.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final ApiService apiService = ApiService();
  List<Practica> practicas = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  String query = ''; // Almacena el término de búsqueda
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPracticas();
  }

  Future<void> _fetchPracticas({bool isSearching = false}) async {
    if (isLoading || (!isSearching && !hasMore)) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.obtenerPracticas(currentPage, query: query);

      if (mounted) { // Verifica si el widget sigue montado antes de llamar a setState
        setState(() {
          if (isSearching) {
            practicas.clear();
            currentPage = 1;
            hasMore = true;
          }
          practicas.addAll(response);
          currentPage++;
          hasMore = response.length == 10; // Si se devuelven 10 resultados, puede haber más
        });
      }
    } catch (e) {
      if (mounted) { // Verifica si el widget sigue montado antes de llamar a setState
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar prácticas: $e')),
        );
      }
    } finally {
      if (mounted) { // Verifica si el widget sigue montado antes de llamar a setState
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prácticas Disponibles'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por título o empresa...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  query = value;
                  currentPage = 1;
                  hasMore = true;
                });
                _fetchPracticas(isSearching: true);
              },
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _fetchPracticas();
          }
          return true;
        },
        child: ListView.builder(
          itemCount: practicas.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == practicas.length) {
              return Center(child: CircularProgressIndicator());
            }

            final practica = practicas[index];
            return ListTile(
              title: Text(practica.titulo),
              subtitle: Text('Empresa: ${practica.empresa}'),
              onTap: () {
                // Aquí podrías abrir una pantalla de detalles o edición
              },
            );
          },
        ),
      ),
    );
  }
}
