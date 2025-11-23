// screens/productos/producto_add_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/producto.dart';
import 'package:frontend_soderia/services/producto_service.dart';
import 'package:frontend_soderia/widgets/common/choice_chips.dart';
import 'package:image_picker/image_picker.dart';

class ProductoAddScreen extends StatefulWidget {
  const ProductoAddScreen({super.key, this.initial});

  final Producto? initial;

  @override
  State<ProductoAddScreen> createState() => _ProductoAddScreenState();
}

class _ProductoAddScreenState extends State<ProductoAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipo = TextEditingController();
  final _precio = TextEditingController();
  final _stock = TextEditingController();
  final _sku = TextEditingController();
  double? _litros; // 12 o 20 o custom
  bool _activo = true;
  XFile? _image;

  final _service = ProductoService();
  bool _saving = false;

  bool get _isValid =>
      _formKey.currentState?.validate() == true && _litros != null && !_saving;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _tipo.text = p.nombre;
      _litros = p.litros;
      _activo = p.estado ?? true;
      // precio / stock / sku / imagen por ahora no se mapean al back
    }
  }

  @override
  void dispose() {
    _tipo.dispose();
    _precio.dispose();
    _stock.dispose();
    _sku.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar producto' : 'Agregar producto'),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isValid ? _submit : null,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tf('Tipo / Nombre', _tipo, validator: _req),
            const SizedBox(height: 12),
            Text(
              'Cantidad de litros',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SingleChoiceChips<double>(
              items: const [20, 12],
              selected: _litros,
              labelOf: (v) => '${v.toStringAsFixed(0)} Lts.',
              onChanged: (v) => setState(() => _litros = v),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Otro...'),
              onPressed: () async {
                final v = await _askNumber(context, title: 'Litros');
                if (v != null) setState(() => _litros = v);
              },
            ),
            const Divider(height: 32),
            _tf(
              'Precio (solo visual, aún no se guarda)',
              _precio,
              keyboard: TextInputType.number,
              validator: _money,
            ),
            _tf(
              'Stock inicial (solo visual, aún no se guarda)',
              _stock,
              keyboard: TextInputType.number,
              validator: _intPos,
            ),
            _tf('Código/SKU (solo visual, aún no se guarda)', _sku),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.attachment),
                    label: Text(
                      _image == null ? 'Adjuntar imagen' : 'Cambiar imagen',
                    ),
                    onPressed: _pickImage,
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v),
                ),
                const Text('Activo'),
              ],
            ),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_image!.path),
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _isValid ? _submit : null,
            icon: const Icon(Icons.save),
            label: Text(isEdit ? 'Guardar cambios' : 'Guardar'),
          ),
        ),
      ),
    );
  }

  // Helpers
  Widget _tf(
    String label,
    TextEditingController c, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) =>
      TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: validator,
        keyboardType: keyboard,
      );

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;

  String? _money(String? v) {
    if (_req(v) != null) return 'Obligatorio';
    return RegExp(r'^\d+([.,]\d{1,2})?$').hasMatch(v!.replaceAll(',', '.'))
        ? null
        : 'Formato: 1234.56';
  }

  String? _intPos(String? v) =>
      (RegExp(r'^[0-9]+$').hasMatch(v ?? '')) ? null : 'Entero ≥ 0';

  Future<double?> _askNumber(BuildContext ctx, {required String title}) async {
    final ctrl = TextEditingController();
    return showDialog<double>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ej: 8'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
              Navigator.pop(ctx, v);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img != null) setState(() => _image = img);
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _saving = true);

    try {
      final nombre = _tipo.text.trim();
      final litros = _litros;
      final activo = _activo;

      if (widget.initial == null) {
        // Alta
        await _service.crear(
          nombre: nombre,
          litros: litros,
          estado: activo,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto creado')),
          );
        }
      } else {
        // Edición
        await _service.actualizar(
          widget.initial!.idProducto,
          nombre: nombre,
          litros: litros,
          estado: activo,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto actualizado')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // true => se modificó algo
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
