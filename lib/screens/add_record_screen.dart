import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:rodis_service/api_handler.dart';
import 'package:rodis_service/components/form_field.dart';
import 'package:rodis_service/components/history.dart';
import 'package:rodis_service/components/photo_field.dart';
import 'package:rodis_service/constants.dart';
import 'package:rodis_service/models/record.dart';
import 'package:rodis_service/models/suggestions.dart';
import 'package:rodis_service/models/user.dart';
import 'package:provider/provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key, this.record});

  final Record? record;

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  late final apiHandler = context.read<ApiHandler>();
  final _node = FocusNode();
  final _productNode = FocusNode();
  final _manufacturerNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  int? id;
  final nameController = TextEditingController();
  final phoneHomeController = TextEditingController();
  final phoneMobileController = TextEditingController();
  final emailController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final addressController = TextEditingController();
  final notesReceivedController = TextEditingController();
  final notesRepairedController = TextEditingController();
  final feeController = TextEditingController();
  final advanceController = TextEditingController();
  final serialController = TextEditingController();
  final productController = TextEditingController();
  final manufacturerController = TextEditingController();
  final dateController = TextEditingController(
    text: dateFormat.format(DateTime.now()).toString(),
  );
  DateTime date = DateTime.now();
  final hasWarranty = ValueNotifier(false);
  DateTime? warrantyDate;
  late final warrantyController = TextEditingController(
    text: warrantyDate != null
        ? dateFormat.format(warrantyDate!).toString()
        : null,
  );
  List<History> newHistory = [];
  String? photoUrl;
  XFile? tempPhoto;
  bool removePhoto = false;
  int? status;
  final waiting = ValueNotifier(false);

  final photoErrorSnackbar = const SnackBar(
    content: Text(
      "Σφάλμα κατά το ανέβασμα της φωτογραφίας. Δοκιμάστε ξανά ή αφαιρέστε τη φωτογραφία.",
    ),
  );

  bool notEqualOrEmpty(String? a, String? b) {
    if (a == null && b == null) return false;
    if (a == null) return b!.isNotEmpty;
    return a != b;
  }

  bool hasChanges() {
    final record = widget.record;
    if (record == null) {
      return nameController.text.isNotEmpty ||
          phoneHomeController.text.isNotEmpty ||
          phoneMobileController.text.isNotEmpty ||
          emailController.text.isNotEmpty ||
          postalCodeController.text.isNotEmpty ||
          cityController.text.isNotEmpty ||
          areaController.text.isNotEmpty ||
          addressController.text.isNotEmpty ||
          notesReceivedController.text.isNotEmpty ||
          notesRepairedController.text.isNotEmpty ||
          feeController.text.isNotEmpty ||
          advanceController.text.isNotEmpty ||
          serialController.text.isNotEmpty ||
          productController.text.isNotEmpty ||
          manufacturerController.text.isNotEmpty ||
          status != null ||
          tempPhoto != null;
    }
    return notEqualOrEmpty(record.name, nameController.text) ||
        notEqualOrEmpty(record.phoneHome, phoneHomeController.text) ||
        notEqualOrEmpty(record.phoneMobile, phoneMobileController.text) ||
        notEqualOrEmpty(record.email, emailController.text) ||
        notEqualOrEmpty(record.postalCode, postalCodeController.text) ||
        notEqualOrEmpty(record.city, cityController.text) ||
        notEqualOrEmpty(record.area, areaController.text) ||
        notEqualOrEmpty(record.address, addressController.text) ||
        notEqualOrEmpty(record.notesReceived, notesReceivedController.text) ||
        notEqualOrEmpty(record.notesRepaired, notesRepairedController.text) ||
        notEqualOrEmpty(
          record.fee,
          feeController.text.replaceAll(r',', '.'),
        ) ||
        notEqualOrEmpty(
          record.advance,
          advanceController.text.replaceAll(r',', '.'),
        ) ||
        notEqualOrEmpty(record.serial, serialController.text) ||
        notEqualOrEmpty(record.product, productController.text) ||
        notEqualOrEmpty(record.manufacturer, manufacturerController.text) ||
        record.date != date ||
        record.hasWarranty != hasWarranty.value ||
        record.warrantyDate != warrantyDate ||
        record.status != status ||
        tempPhoto != null ||
        newHistory.isNotEmpty;
  }

  Future<bool> showDiscardDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Απόρριψη αλλαγών;"),
        content: const SizedBox(
          width: 350,
          child: Text(
            "Έχετε πραγματοποιήσει αλλαγές στη φόρμα οι οποίες θα χαθούν αν συνεχίσετε.",
            textAlign: TextAlign.justify,
          ),
        ),
        icon: const Icon(Icons.error_outline),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Απόρριψη αλλαγών",
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Ακύρωση"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void initState() {
    super.initState();
    if (widget.record == null) return;
    final record = widget.record!;
    id = record.id;
    nameController.text = record.name;
    phoneHomeController.text = record.phoneHome ?? "";
    phoneMobileController.text = record.phoneMobile;
    emailController.text = record.email ?? "";
    postalCodeController.text = record.postalCode;
    cityController.text = record.city;
    areaController.text = record.area;
    addressController.text = record.address;
    notesReceivedController.text = record.notesReceived ?? "";
    notesRepairedController.text = record.notesRepaired ?? "";
    feeController.text = record.fee?.replaceAll(r'.', ',') ?? "";
    advanceController.text = record.advance?.replaceAll(r'.', ',') ?? "";
    serialController.text = record.serial ?? "";
    dateController.text = dateFormat.format(record.date).toString();
    date = record.date;
    hasWarranty.value = record.hasWarranty;
    warrantyDate = record.warrantyDate;
    warrantyController.text = record.warrantyDate != null
        ? dateFormat.format(record.warrantyDate!).toString()
        : "";
    photoUrl = record.photo != null
        ? (record.photo!.isEmpty ? null : record.photo)
        : null;
    productController.text = record.product;
    manufacturerController.text = record.manufacturer;
    status = record.status;
  }

  @override
  void dispose() {
    _node.dispose();
    _productNode.dispose();
    _manufacturerNode.dispose();
    nameController.dispose();
    phoneHomeController.dispose();
    phoneMobileController.dispose();
    emailController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    areaController.dispose();
    addressController.dispose();
    notesReceivedController.dispose();
    notesRepairedController.dispose();
    feeController.dispose();
    advanceController.dispose();
    serialController.dispose();
    productController.dispose();
    warrantyController.dispose();
    hasWarranty.dispose();
    waiting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!hasChanges() || await showDiscardDialog()) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_node),
        child: Scaffold(
          appBar: AppBar(
            title: id != null
                ? const Text("Ενημέρωση επισκευής")
                : const Text("Νέα επισκευή"),
            actions: [
              if (widget.record != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    label: const Text(
                      "Ιστορικό",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    icon: const Icon(Icons.history_edu_rounded, size: 26),
                    style:
                        TextButton.styleFrom(fixedSize: const Size(150, 100)),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => HistoryDialog(
                          history: widget.record!.history,
                          newHistory: newHistory,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: const Text('Υποβολή'),
            icon: ValueListenableBuilder(
              valueListenable: waiting,
              builder: (context, value, child) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: value
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(strokeWidth: 3.0),
                      )
                    : const Icon(Icons.check),
              ),
            ),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Παρακαλώ συμπληρώστε όλα τα απαραίτητα στοιχεία"),
                  ),
                );
                return;
              }
              waiting.value = true;
              String? newPhotoUrl;
              if (tempPhoto != null) {
                XFile? compressed;
                try {
                  compressed = await FlutterImageCompress.compressAndGetFile(
                    tempPhoto!.path,
                    "${tempPhoto!.path}_compressed.jpg",
                  );
                } catch (error) {
                  if (kDebugMode) debugPrint("$error");
                }
                compressed ??= tempPhoto;
                newPhotoUrl = await apiHandler.postPhoto(compressed!);
                if (newPhotoUrl == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(photoErrorSnackbar);
                  waiting.value = false;
                  return;
                }
              }
              final record = {
                if (id != null) "id": id,
                "date": dateTimeFormatDB.format(date),
                "name":
                    nameController.text.isNotEmpty ? nameController.text : null,
                "phoneHome": phoneHomeController.text.isNotEmpty
                    ? phoneHomeController.text
                    : null,
                "phoneMobile": phoneMobileController.text.isNotEmpty
                    ? phoneMobileController.text
                    : null,
                "email": emailController.text.isNotEmpty
                    ? emailController.text
                    : null,
                "postalCode": postalCodeController.text.isNotEmpty
                    ? postalCodeController.text
                    : null,
                "city":
                    cityController.text.isNotEmpty ? cityController.text : null,
                "area":
                    areaController.text.isNotEmpty ? areaController.text : null,
                "address": addressController.text.isNotEmpty
                    ? addressController.text
                    : null,
                "notesReceived": notesReceivedController.text.isNotEmpty
                    ? notesReceivedController.text
                    : null,
                "notesRepaired": notesRepairedController.text.isNotEmpty
                    ? notesRepairedController.text
                    : null,
                "serial": serialController.text.isNotEmpty
                    ? serialController.text
                    : null,
                "product": productController.text.isNotEmpty
                    ? productController.text
                    : null,
                "manufacturer": manufacturerController.text.isNotEmpty
                    ? manufacturerController.text
                    : null,
                "fee": feeController.text.isNotEmpty
                    ? feeController.text.replaceAll(r',', '.')
                    : null,
                "advance": advanceController.text.isNotEmpty
                    ? advanceController.text.replaceAll(r',', '.')
                    : null,
                "photo": newPhotoUrl ?? (removePhoto ? null : photoUrl),
                "mechanic": context.read<User>().id,
                "hasWarranty": hasWarranty.value,
                "warrantyDate": hasWarranty.value && warrantyDate != null
                    ? dateTimeFormatDB.format(warrantyDate!)
                    : null,
                "status": status,
                "newHistory": newHistory.map((e) => e.toJSON()).toList(),
              };
              try {
                if (id == null) {
                  final response = await apiHandler.postRecord(record);
                  if (response != null) {
                    context.read<Records>().add(Record.fromJSON(response));
                    Navigator.pop(context);
                  }
                } else {
                  final response = await apiHandler.putRecord(record);
                  if (response != null) {
                    context
                        .read<Records>()
                        .setRecord(Record.fromJSON(response));
                    Navigator.pop(context);
                  }
                }
              } catch (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Προέκυψε σφάλμα κατά το ανέβασμα των στοιχείων στον σέρβερ",
                    ),
                  ),
                );
              } finally {
                waiting.value = false;
              }
            },
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Ημερομηνία",
                          controller: dateController,
                          textInputType: TextInputType.datetime,
                          required: true,
                          width: 150,
                          readOnly: true,
                          onTap: () async {
                            final newDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2099),
                            );
                            if (newDate == null) return;
                            date = newDate;
                            dateController.text =
                                dateFormat.format(date).toString();
                          },
                        ),
                        Selector<Suggestions, Map<int, String>>(
                          selector: (context, suggestions) =>
                              suggestions.statuses,
                          builder: (context, statuses, child) => FormComboItem(
                            label: "Κατάσταση",
                            initialSelection: status,
                            options: statuses,
                            onSelected: (value) => status = value,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Προκαταβολή",
                          controller: advanceController,
                          textInputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          format: FormFieldFormat.decimal,
                          width: 150,
                          prefixIcon: Icon(
                            Icons.euro_rounded,
                            size: 16.0,
                            color:
                                IconTheme.of(context).color!.withOpacity(0.6),
                          ),
                        ),
                        FormFieldItem(
                          label: "Πληρωμή",
                          controller: feeController,
                          textInputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          format: FormFieldFormat.decimal,
                          width: 150,
                          prefixIcon: Icon(
                            Icons.euro,
                            size: 16.0,
                            color:
                                IconTheme.of(context).color!.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Wrap(
                      children: [
                        FormFieldItem(
                          label: "Όνομα πελάτη",
                          controller: nameController,
                          textInputType: TextInputType.name,
                          width: 300,
                          required: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Σταθερό τηλέφωνο",
                          controller: phoneHomeController,
                          textInputType: TextInputType.phone,
                          format: FormFieldFormat.integer,
                        ),
                        FormFieldItem(
                          label: "Κινητό τηλέφωνο",
                          controller: phoneMobileController,
                          textInputType: TextInputType.phone,
                          format: FormFieldFormat.integer,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "Email",
                          controller: emailController,
                          textInputType: TextInputType.emailAddress,
                          width: 300,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Διεύθυνση",
                          controller: addressController,
                          textInputType: TextInputType.streetAddress,
                          width: 300,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "Πόλη",
                          controller: cityController,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "Περιοχή",
                          controller: areaController,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "ΤΚ",
                          controller: postalCodeController,
                          textInputType: TextInputType.number,
                          width: 100,
                          format: FormFieldFormat.integer,
                          required: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        Selector<Suggestions, Map<int, String>>(
                          selector: (context, suggestions) =>
                              suggestions.products,
                          builder: (context, products, child) =>
                              CustomAutocomplete(
                            label: 'Είδος',
                            textEditingController: productController,
                            suggestions: products.values,
                            required: true,
                            width: 250.0,
                            focusNode: _productNode,
                          ),
                        ),
                        Selector<Suggestions, Map<int, String>>(
                          selector: (context, suggestions) =>
                              suggestions.manufacturers,
                          builder: (context, manufacturers, child) =>
                              CustomAutocomplete(
                            label: 'Μάρκα',
                            textEditingController: manufacturerController,
                            suggestions: manufacturers.values,
                            required: true,
                            focusNode: _manufacturerNode,
                          ),
                        ),
                        FormFieldItem(
                          label: "Σειριακός αριθμός",
                          controller: serialController,
                          width: 250,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ValueListenableBuilder(
                      valueListenable: hasWarranty,
                      builder: (context, value, child) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Εγγύηση",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                child: Checkbox(
                                  value: value,
                                  onChanged: (newValue) =>
                                      hasWarranty.value = newValue ?? false,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 150,
                            child: TextFormField(
                              controller: warrantyController,
                              keyboardType: TextInputType.datetime,
                              enabled: value,
                              readOnly: true,
                              onTap: () async {
                                final newDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2099),
                                );
                                if (newDate == null) return;
                                warrantyDate = newDate;
                                warrantyController.text =
                                    dateFormat.format(newDate).toString();
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 32.0,
                      runSpacing: 16.0,
                      children: [
                        Column(
                          children: [
                            FormFieldItem(
                              label: "Παρατηρήσεις παραλαβής",
                              controller: notesReceivedController,
                              textInputType: TextInputType.multiline,
                              width: 500,
                              lines: 5,
                              maxLength: 500,
                            ),
                            FormFieldItem(
                              label: "Παρατηρήσεις επισκευής",
                              controller: notesRepairedController,
                              textInputType: TextInputType.multiline,
                              width: 500,
                              lines: 5,
                              maxLength: 500,
                            ),
                          ],
                        ),
                        PhotoField(
                          photoUrl: photoUrl,
                          onPhotoSet: (newImage, removePhoto) {
                            tempPhoto = newImage;
                            if (removePhoto) this.removePhoto = removePhoto;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
