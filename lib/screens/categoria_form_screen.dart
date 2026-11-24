import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/categoria.dart';
import '../providers/categoria_provider.dart';
import '../widgets/mensajes.dart';

class CategoriaFormScreen extends StatefulWidget {
  final Categoria? categoria;

  const CategoriaFormScreen({
    super.key,
    this.categoria,
  });

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  bool _guardando = false;

  bool get _esEdicion => widget.categoria != null;

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      nombreController.text = widget.categoria!.nombre;
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final categoria = Categoria(
      id: widget.categoria?.id,
      nombre: nombreController.text.trim(),
    );

    final provider = context.read<CategoriaProvider>();
    final error = _esEdicion
        ? await provider.actualizarCategoria(categoria)
        : await provider.agregarCategoria(categoria);

    if (!mounted) return;

    setState(() => _guardando = false);

    mostrarSnack(
      context,
      error ?? (_esEdicion ? 'Categoría actualizada' : 'Categoría guardada'),
    );

    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar categoría' : 'Nueva categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Mínimo 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_esEdicion ? 'Actualizar' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
