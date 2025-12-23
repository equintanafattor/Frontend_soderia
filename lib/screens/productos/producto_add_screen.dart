// screens/productos/producto_add_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/producto.dart';
import 'package:frontend_soderia/services/producto_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';
import 'package:frontend_soderia/models/lista_precio_ref.dart';
import 'package:frontend_soderia/models/producto_precio_input.dart';
import 'package:frontend_soderia/widgets/productos/producto_listas_precio_editor.dart';

class ProductoAddScreen extends StatefulWidget {
  const ProductoAddScreen({super.key, this.initial});

  final Producto? initial;

  @override
  State<ProductoAddScreen> createState() => _ProductoAddScreenState();
}

class _ProductoAddScreenState extends State<ProductoAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  bool _activo = true;
  bool _saving = false;

  XFile? _image;

  final _service = ProductoService();

  bool get _isEdit => widget.initial != null;

  bool get _isValid => _formKey.currentState?.validate() == true && !_saving;

  final _listaPrecioService = ListaPrecioService();

  List<ListaPrecioRef> _listas = [];
  List<ProductoPrecioInput> _precios = [];

  bool _cargandoListas = true;

  Future<void> _loadListas() async {
    try {
      final raw = await _listaPrecioService.listarListas();
      setState(() {
        _listas = raw.map((e) {
          final id = e['id_lista'];

          if (id == null) {
            throw Exception('Lista de precio sin id_lista: $e');
          }

          return ListaPrecioRef(
            id: id as int,
            nombre: e['nombre'].toString().toLowerCase(),
          );
        }).toList();

        _cargandoListas = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar listas: $e')));
    }
  }

  @override
  void initState() {
    super.initState();

    final p = widget.initial;
    if (p != null) {
      _nombreCtrl.text = p.nombre;
      _activo = p.estado ?? true;
    }

    _loadListas();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar producto' : 'Nuevo producto'),
        actions: [
          TextButton.icon(
            onPressed: _isValid ? _submit : null,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== HEADER =====
              if (_isEdit)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                          label: 'ID producto',
                          value: widget.initial!.idProducto.toString(),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_isEdit) const SizedBox(height: 16),

              // ===== DATOS DEL PRODUCTO =====
              _SectionCard(
                title: 'Datos del producto',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'ej: bidon 20l retornable',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresá el nombre del producto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Stock inicial',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (int.tryParse(v) == null) {
                          return 'Debe ser un número entero';
                        }
                        if (int.parse(v) < 0) {
                          return 'No puede ser negativo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: _activo,
                      onChanged: (v) => setState(() => _activo = v),
                      title: const Text('Producto activo'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              // ===== IMAGEN =====
              _SectionCard(
                title: 'Imagen',
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image),
                      label: Text(
                        _image == null ? 'Adjuntar imagen' : 'Cambiar imagen',
                      ),
                      onPressed: _pickImage,
                    ),
                    if (_image != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_image!.path),
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ===== LISTAS DE PRECIOS =====
              _SectionCard(
                title: 'Listas de precios',
                child: _cargandoListas
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : ProductoListasPrecioEditor(
                        listasDisponibles: _listas,
                        initial: _precios,
                        onChanged: (values) {
                          _precios = values;
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() => _image = img);
    }
  }

  Future<void> _submit() async {
    if (!_isValid) return;

    final preciosPayload = _precios.map((p) => p.toJson()).toList();

    setState(() => _saving = true);
    try {
      final nombre = _nombreCtrl.text.trim().toLowerCase();
      final activo = _activo;

      if (_isEdit) {
        await _service.actualizar(
          widget.initial!.idProducto,
          nombre: nombre,
          estado: activo,
        );
      } else {
        await _service.crear(nombre: nombre, estado: activo);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Producto actualizado' : 'Producto creado'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ===== UI Helpers reutilizados (alineados a ClienteEdit) =====

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surface,
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
