import 'package:flutter/material.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/panel/ui/pages/perfil_page.dart';
import 'package:mocca_go/features/panel/ui/pages/proximamente_page.dart';
import 'package:mocca_go/features/panel/ui/widgets/panel_tab_bar.dart';

/// Panel del cliente con sus pestañas: Menú, Mis pedidos y Perfil.
///
/// Menú y Mis pedidos los construye Karen en este sprint; mientras tanto
/// muestran "Próximamente".
class ClientePanelScreen extends StatefulWidget {
  final Usuario usuario;

  const ClientePanelScreen({super.key, required this.usuario});

  @override
  State<ClientePanelScreen> createState() => _ClientePanelScreenState();
}

class _ClientePanelScreenState extends State<ClientePanelScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final nombre = widget.usuario.nombre.split(' ').first;
    final pages = [
      ProximamentePage(
        titulo: 'Hola, $nombre',
        subtitulo: '¿Qué se te antoja hoy?',
        icono: Icons.coffee_outlined,
      ),
      const ProximamentePage(titulo: 'Mis pedidos', icono: Icons.receipt_long_outlined),
      PerfilPage(usuario: widget.usuario),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: PanelTabBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.coffee_outlined), label: 'Menú'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Mis pedidos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
