import 'package:flutter/material.dart';
import 'package:rodis_service/components/align_center.dart';
import 'package:rodis_service/constants.dart';
import 'package:rodis_service/models/record.dart';
import 'package:rodis_service/models/record_view.dart';
import 'package:rodis_service/models/suggestions.dart';
import 'package:rodis_service/models/user.dart';
import 'package:rodis_service/screens/add_record_screen.dart';
import 'package:provider/provider.dart';

class RecordList extends StatefulWidget {
  const RecordList({super.key});

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  @override
  Widget build(BuildContext context) {
    final reverse = context.watch<RecordView>().reverse;
    final filtered = reverse
        ? context.watch<RecordView>().filtered.reversed.toList()
        : context.watch<RecordView>().filtered;
    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "Δε βρέθηκαν εντολές",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Scrollbar(
      child: ListView.builder(
        primary: true,
        itemCount: filtered.length,
        itemBuilder: (context, index) => ChangeNotifierProvider.value(
          value: filtered[index],
          builder: (context, child) => RecordRow(index: index),
        ),
      ),
    );
  }
}

class RecordRow extends StatefulWidget {
  const RecordRow({
    super.key,
    this.index = 0,
    this.initialExpanded = false,
  });

  final int index;
  final bool initialExpanded;
  @override
  State<RecordRow> createState() => _RecordRowState();
}

class _RecordRowState extends State<RecordRow> {
  late bool _expanded = widget.initialExpanded;

  Color statusToColor(int status) {
    return switch (status) {
      1 => Colors.lightBlue.shade100,
      2 => Colors.yellow.shade100,
      3 => Colors.green.shade100,
      _ => Colors.red.shade100,
    };
  }

  String makeCustomerString(Record record) {
    final fullAddress = [];
    if (record.address != null && record.address!.isNotEmpty) {
      fullAddress.add(record.address);
    }
    if (record.area != null && record.area!.isNotEmpty) {
      fullAddress.add(record.area);
    }
    if (record.city != null && record.city!.isNotEmpty) {
      fullAddress.add(record.city);
    }
    return "${record.name}\n${record.phoneMobile}${fullAddress.isEmpty ? "" : "\n${fullAddress.join(", ")}"}";
  }

  @override
  void didUpdateWidget(covariant RecordRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialExpanded != widget.initialExpanded) {
      _expanded = widget.initialExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = context.watch<Record>();
    final suggestions = context.watch<Suggestions>();
    final collapse = switch (MediaQuery.sizeOf(context).width) {
      > 760.0 => 0,
      > 650.0 => 1,
      _ => 2,
    };
    return Material(
      color: statusToColor(record.status),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            splashFactory: InkSparkle.splashFactory,
            onTap: () async {
              final records = context.read<Records>();
              final user = context.read<User>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: suggestions),
                      ChangeNotifierProvider.value(value: records),
                      Provider.value(value: user),
                    ],
                    builder: (context, child) =>
                        AddRecordScreen(record: record),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: IconButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        turns: _expanded ? 0.25 : 0,
                        child: const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  ),
                ),
                if (collapse < 2)
                  RecordCell(
                    text: record.id.toString(),
                    flex: 3,
                    align: TextAlign.center,
                  ),
                RecordCell(
                  text: dateTimeFormat.format(record.date),
                  flex: 6,
                ),
                RecordCell(
                  text: makeCustomerString(record),
                  flex: 8,
                ),
                RecordCell(
                  text: record.product,
                  flex: 6,
                ),
                RecordCell(
                  text: suggestions.stores[record.store]!,
                  flex: 6,
                ),
                RecordCell(
                  text: suggestions.statuses[record.status]!,
                  flex: 4,
                ),
              ],
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              alignment: Alignment.bottomCenter,
              heightFactor: _expanded ? 1 : 0,
              child:
                  Container(color: Colors.white24, child: const HistoryList()),
            ),
          ),
        ],
      ),
    );
  }
}

class RecordCell extends StatelessWidget {
  const RecordCell({
    super.key,
    required this.text,
    this.flex = 10,
    this.align = TextAlign.start,
  });

  final int flex;
  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
          textAlign: align,
        ),
      ),
    );
  }
}

class RecordListHeader extends StatelessWidget {
  const RecordListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final sorter = context.watch<RecordView>();
    final collapse = switch (MediaQuery.sizeOf(context).width) {
      > 760.0 => 0,
      > 650.0 => 1,
      _ => 2,
    };
    return Material(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              flex: 2,
              child: SizedBox(
                width: 48,
              ),
            ),
            if (collapse < 2)
              RecordListHeaderItem(
                title: "ID",
                onTap: () => context.read<RecordView>().setSort(COLUMN.id),
                visible: sorter.column == COLUMN.id,
                reverse: sorter.reverse,
                flex: 3,
              ),
            RecordListHeaderItem(
              title: "Ημερομηνία",
              onTap: () => context.read<RecordView>().setSort(COLUMN.date),
              visible: sorter.column == COLUMN.date,
              reverse: sorter.reverse,
              flex: 6,
            ),
            RecordListHeaderItem(
              title: "Πελάτης",
              onTap: () => context.read<RecordView>().setSort(COLUMN.name),
              visible: sorter.column == COLUMN.name,
              reverse: sorter.reverse,
              flex: 8,
            ),
            RecordListHeaderItem(
              title: "Είδος",
              onTap: () => context.read<RecordView>().setSort(COLUMN.product),
              visible: sorter.column == COLUMN.product,
              reverse: sorter.reverse,
              flex: 6,
            ),
            RecordListHeaderItem(
              title: "Κατάστημα",
              onTap: () => context.read<RecordView>().setSort(COLUMN.store),
              visible: sorter.column == COLUMN.store,
              reverse: sorter.reverse,
              flex: 6,
            ),
            RecordListHeaderItem(
              title: "Κατάσταση",
              onTap: () => context.read<RecordView>().setSort(COLUMN.status),
              visible: sorter.column == COLUMN.status,
              reverse: sorter.reverse,
              flex: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class RecordListHeaderItem extends StatelessWidget {
  const RecordListHeaderItem({
    super.key,
    required this.title,
    this.onTap,
    this.flex = 10,
    required this.visible,
    required this.reverse,
  });

  final String title;
  final int flex;
  final void Function()? onTap;
  final bool visible;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: InkWell(
        splashFactory: InkSparkle.splashFactory,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Visibility(
                visible: visible,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Icon(
                  reverse ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<Record>().history;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: history.isEmpty
            ? const Text(
                'Δε βρέθηκε ιστορικό',
                style: TextStyle(fontSize: 16.0),
              )
            : ListView(
                shrinkWrap: true,
                children: history.map((e) => HistoryRow(history: e)).toList(),
              ),
      ),
    );
  }
}

class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required this.history,
  });

  final History history;

  @override
  Widget build(BuildContext context) {
    final child = switch (MediaQuery.sizeOf(context).width) {
      > 650.0 => Stack(
          children: [
            AlignCenter(
              alignment: const Alignment(-1 / 3, 0),
              child: Text(
                dateTimeFormat.format(history.date),
              ),
            ),
            AlignCenter(
              alignment: const Alignment(1 / 3, 0),
              child: SizedBox(
                width: 300,
                child: Text(
                  history.notes,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ],
        ),
      _ => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateTimeFormat.format(history.date),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              child: Text(
                history.notes,
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        )
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: child,
    );
  }
}
