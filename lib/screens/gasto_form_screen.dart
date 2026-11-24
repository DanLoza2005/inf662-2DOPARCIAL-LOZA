import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/gasto.dart';
import '../providers/categoria_provider.dart';
import '../providers/gasto_provider.dart';
import '../widgets/mensajes.dart';

class GastoFormScreen extends StatefulWidget {
  final Gasto? gasto;

  // Para preseleccionar la categoria cuando se entra desde su detalle
  final int? categoriaInicial;

  const GastoFormScreen({
    super.key,
    this.gasto,
    this.categoriaInicial,
  });

  @override
  State<GastoFormScreen> createState() => _GastoFormScreenState();
}

class _GastoFormScreenState extends State<GastoFormScreen> {
  final formKey = GlobalKey<FormState>();

  final descripcionController = TextEditingController();

  final montoController = TextEditingController();

  DateTime _fecha = DateTime.now();
  int? _categoriaId;
  bool _guardando = false;

  bool get _esEdicion => widget.gasto != null;

  @override
  void initState() {
    super.initState();

    if (widget.gasto != null) {
      descripcionController.text = widget.gasto!.descripcion;

      montoController.text = widget.gasto!.monto.toString();

      _fecha = DateTime.tryParse(widget.gasto!.fecha) ?? DateTime.now();
      _categoriaId = widget.gasto!.categoriaId;
    } else {
      _categoriaId = widget.categoriaInicial;
    }
  }

  @override
  void dispose() {
    descripcionController.dispose();
    montoController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!context.mounted || elegida == null) return;

    setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final gasto = Gasto(
      id: widget.gasto?.id,
      descripcion: descripcionController.text.trim(),
      monto: double.parse(montoController.text.replaceAll(',', '.')),
      categoriaId: _categoriaId!,
      fecha: Gasto.fechaIso(_fecha),
    );

    final provider = context.read<GastoProvider>();
    final error = _esEdicion
        ? await provider.actualizarGasto(gasto)
        : await provider.agregarGasto(gasto);

    if (!context.mounted) return;

    setState(() => _guardando = false);

    mostrarSnack(
      context,
      error ?? (_esEdicion ? 'Gasto actualizado' : 'Gasto guardado'),
    );

    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<CategoriaProvider>().categorias;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gasto == null ? 'Nuevo gasto' : 'Editar gasto',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: descripcionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Ingrese una descripción (mínimo 3 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: montoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Monto (Bs)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final monto = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  if (monto == null) return 'Ingrese un monto válido';
                  if (monto <= 0) return 'El monto debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                initialValue: _categoriaId,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final categoria in categorias)
                    DropdownMenuItem(
                      value: categoria.id,
                      child: Text(categoria.nombre),
                    ),
                ],
                onChanged: (valor) => _categoriaId = valor,
                validator: (valor) {
                  if (valor == null) return 'Elija una categoría';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _elegirFecha,
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Fecha: ${Gasto.formatearFecha(_fecha)}'),
                ),
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
                  label: Text(
                    widget.gasto == null ? 'Guardar' : 'Actualizar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
