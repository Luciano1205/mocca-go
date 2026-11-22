import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/app_input.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/editar_perfil/ui/bloc/editar_perfil_bloc.dart';
import 'package:mocca_go/features/editar_perfil/ui/bloc/editar_perfil_event.dart';
import 'package:mocca_go/features/editar_perfil/ui/bloc/editar_perfil_state.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// 13b · Editar perfil (cliente) y 20b · Editar perfil (domiciliario).
/// Al guardar vuelve al perfil con el Usuario actualizado.
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;

  @override
  void initState() {
    super.initState();
    final usuario = context.read<EditarPerfilBloc>().state.usuario;
    _nombre = TextEditingController(text: usuario.nombre);
    _descripcion = TextEditingController(text: usuario.descripcion ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditarPerfilBloc, EditarPerfilState>(
      listener: (context, state) {
        if (state.status == EditarPerfilStatus.guardado) {
          Navigator.pop(context, state.usuario);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                Text('Editar perfil', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                    child: Text(
                      iniciales(state.usuario.nombre),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Rol y calificación no se pueden editar',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 20),
                if (state.status == EditarPerfilStatus.failure) ...[
                  MessageBanner(title: state.errorMessage!, isError: true),
                  const SizedBox(height: 16),
                ],
                AppInput(label: 'Nombre', hint: 'Tu nombre', controller: _nombre),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Descripción (opcional)',
                  hint: 'Ej: casi siempre estoy en la biblioteca',
                  controller: _descripcion,
                  maxLength: 140,
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: PrimaryButton(
                label: 'Guardar cambios',
                isLoading: state.status == EditarPerfilStatus.guardando,
                onPressed: () => context.read<EditarPerfilBloc>().add(
                  GuardarPerfilPressed(
                    nombre: _nombre.text,
                    descripcion: _descripcion.text,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
