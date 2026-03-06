// pages/admin_page.dart
import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import '../layouts/main_layout.dart';
import '../utils/constants.dart';

// ═══════════════════════════════════════════════════════════════════
// FLAT DATA MODELS (for independent Question / Option endpoints)
// ═══════════════════════════════════════════════════════════════════

class AdminQuestion {
  final int id, quizId, difficultyLevel, order;
  final String text;
  AdminQuestion({
    required this.id,
    required this.quizId,
    required this.text,
    required this.difficultyLevel,
    required this.order,
  });
  factory AdminQuestion.fromJson(Map<String, dynamic> j) => AdminQuestion(
        id: (j['id'] as num).toInt(),
        quizId: (j['quiz_id'] as num).toInt(),
        text: j['text'] as String,
        difficultyLevel: (j['difficulty_level'] as num?)?.toInt() ?? 50,
        order: (j['order'] as num?)?.toInt() ?? 0,
      );
}

class AdminOption {
  final int id, questionId;
  final String text;
  final bool isCorrect;
  AdminOption({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
  });
  factory AdminOption.fromJson(Map<String, dynamic> j) => AdminOption(
        id: (j['id'] as num).toInt(),
        questionId: (j['question_id'] as num).toInt(),
        text: j['text'] as String,
        isCorrect: (j['is_correct'] as bool?) ?? false,
      );
}

// ═══════════════════════════════════════════════════════════════════
// SHARED UI HELPERS
// ═══════════════════════════════════════════════════════════════════

PopupMenuItem<String> _menuItem(
        String value, IconData icon, String label, Color color) =>
    PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ]),
    );

Future<T?> _showPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T) getTitle,
  String? Function(T)? getSubtitle,
  T? selected,
}) {
  String q = '';
  return showDialog<T>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) {
        final filtered = q.isEmpty
            ? items
            : items
                .where((i) =>
                    getTitle(i).toLowerCase().contains(q.toLowerCase()))
                .toList();
        return AlertDialog(
          title: Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Хайх...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) => ss(() => q = v),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: filtered.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('Олдсонгүй')))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            final isSel = item == selected;
                            return ListTile(
                              title: Text(getTitle(item),
                                  style: TextStyle(
                                      fontWeight: isSel
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                              subtitle: getSubtitle != null &&
                                      getSubtitle(item) != null
                                  ? Text(getSubtitle(item)!,
                                      style: const TextStyle(fontSize: 12))
                                  : null,
                              trailing: isSel
                                  ? const Icon(Icons.check_circle,
                                      color: AppColors.primary, size: 20)
                                  : null,
                              selected: isSel,
                              selectedTileColor:
                                  AppColors.primary.withOpacity(0.06),
                              onTap: () => Navigator.pop(ctx, item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Болих')),
          ],
        );
      },
    ),
  );
}

// Styled form field
class _FF extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? inputType;
  const _FF(
      {required this.controller,
      required this.label,
      this.hint,
      this.maxLines = 1,
      this.inputType});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: inputType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
        ],
      );
}

// Styled dropdown field
class _DropField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) getLabel;
  final ValueChanged<T?> onChanged;
  const _DropField(
      {required this.label,
      required this.value,
      required this.items,
      required this.getLabel,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                items: items
                    .map((i) =>
                        DropdownMenuItem(value: i, child: Text(getLabel(i))))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );
}

// Difficulty level chip
Widget _diffChip(int level) {
  Color c;
  String t;
  if (level < 30) {
    c = AppColors.success;
    t = 'Хялбар';
  } else if (level < 70) {
    c = AppColors.warning;
    t = 'Дунд';
  } else {
    c = AppColors.error;
    t = 'Хүнд';
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
    child: Text(t, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
  );
}

// ═══════════════════════════════════════════════════════════════════
// ADMIN PAGE
// ═══════════════════════════════════════════════════════════════════

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Topic> _topics = [];
  List<Quiz> _quizzes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final t = await ApiService.fetchTopics();
      final q = await ApiService.fetchQuizzes();
      if (mounted) {
        setState(() {
          _topics = t;
          _quizzes = q;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Админ самбар',
      currentNavIndex: 0,
      showDrawer: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 2,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelPadding: EdgeInsets.zero,
                    tabs: const [
                      Tab(icon: Icon(Icons.topic_outlined, size: 20), text: 'Сэдэв', iconMargin: EdgeInsets.only(bottom: 2)),
                      Tab(icon: Icon(Icons.quiz_outlined, size: 20), text: 'Тест', iconMargin: EdgeInsets.only(bottom: 2)),
                      Tab(icon: Icon(Icons.help_outline, size: 20), text: 'Асуулт', iconMargin: EdgeInsets.only(bottom: 2)),
                      Tab(icon: Icon(Icons.checklist_outlined, size: 20), text: 'Сонголт', iconMargin: EdgeInsets.only(bottom: 2)),
                      Tab(icon: Icon(Icons.menu_book_outlined, size: 20), text: 'Хичээл', iconMargin: EdgeInsets.only(bottom: 2)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _TopicTab(topics: _topics, onRefresh: _loadData),
                      _QuizTab(
                          topics: _topics,
                          quizzes: _quizzes,
                          onRefresh: _loadData),
                      _QuestionTab(
                          topics: _topics,
                          quizzes: _quizzes,
                          onRefresh: _loadData),
                      _OptionTab(
                          topics: _topics,
                          quizzes: _quizzes,
                          onRefresh: _loadData),
                      _LessonTab(
                          topics: _topics,
                          quizzes: _quizzes,
                          onRefresh: _loadData),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TOPIC TAB
// ═══════════════════════════════════════════════════════════════════

class _TopicTab extends StatefulWidget {
  final List<Topic> topics;
  final VoidCallback onRefresh;
  const _TopicTab({required this.topics, required this.onRefresh});
  @override
  State<_TopicTab> createState() => _TopicTabState();
}

class _TopicTabState extends State<_TopicTab> {
  String _search = '';

  List<Topic> get _filtered => _search.isEmpty
      ? widget.topics
      : widget.topics
          .where((t) =>
              t.title.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [_actionBar(), Expanded(child: _list())]);
  }

  Widget _actionBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Сэдэв хайх...',
                prefixIcon: const Icon(Icons.search, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Нэмэх'),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
        ]),
      );

  Widget _list() {
    final items = _filtered;
    if (items.isEmpty)
      return _emptyState(Icons.topic_outlined, 'Сэдэв олдсонгүй');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 56, endIndent: 0),
      itemBuilder: (ctx, i) {
        final t = items[i];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text(t.title[0].toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          title: Text(t.title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: (t.description != null && t.description!.isNotEmpty)
              ? Text(t.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[600]))
              : null,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('#${t.order}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              itemBuilder: (_) => [
                _menuItem('edit', Icons.edit_outlined, 'Засах', Colors.blue),
                _menuItem('delete', Icons.delete_outline, 'Устгах',
                    Colors.red),
              ],
              onSelected: (v) {
                if (v == 'edit') _openForm(ctx, topic: t);
                if (v == 'delete') _confirmDelete(ctx, t);
              },
            ),
          ]),
          onTap: () => _openForm(ctx, topic: t),
        );
      },
    );
  }

  void _openForm(BuildContext ctx, {Topic? topic}) {
    final titleC = TextEditingController(text: topic?.title ?? '');
    final descC = TextEditingController(text: topic?.description ?? '');
    final orderC =
        TextEditingController(text: (topic?.order ?? 0).toString());

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bsCtx) => _FormSheet(
        title: topic == null ? 'Сэдэв нэмэх' : 'Сэдэв засах',
        onDelete: topic != null ? () => _confirmDelete(bsCtx, topic) : null,
        onSave: () async {
          final ok = topic == null
              ? await ApiService.createTopic({
                  'title': titleC.text.trim(),
                  'description': descC.text.trim(),
                  'order': int.tryParse(orderC.text) ?? 0,
                })
              : await ApiService.updateTopic(topic.id, {
                  'title': titleC.text.trim(),
                  'description': descC.text.trim(),
                  'order': int.tryParse(orderC.text) ?? 0,
                });
          if (ok) {
            widget.onRefresh();
            if (bsCtx.mounted) Navigator.pop(bsCtx);
          }
        },
        fields: [
          _FF(controller: titleC, label: 'Гарчиг *', hint: 'Сэдвийн нэр'),
          const SizedBox(height: 12),
          _FF(
              controller: descC,
              label: 'Тайлбар',
              hint: 'Товч тайлбар',
              maxLines: 2),
          const SizedBox(height: 12),
          _FF(
              controller: orderC,
              label: 'Дараалал',
              hint: '0',
              inputType: TextInputType.number),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, Topic t) => showDialog(
        context: ctx,
        builder: (_) => _ConfirmDelete(
          name: t.title,
          onConfirm: () async {
            await ApiService.deleteTopic(t.id);
            widget.onRefresh();
            if (ctx.mounted) {
              Navigator.pop(ctx);
              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
            }
          },
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// QUIZ TAB
// ═══════════════════════════════════════════════════════════════════

class _QuizTab extends StatefulWidget {
  final List<Topic> topics;
  final List<Quiz> quizzes;
  final VoidCallback onRefresh;
  const _QuizTab(
      {required this.topics,
      required this.quizzes,
      required this.onRefresh});
  @override
  State<_QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<_QuizTab> {
  bool _filterOpen = false;
  Topic? _filterTopic;
  String _search = '';

  List<Quiz> get _filtered {
    var list = widget.quizzes;
    if (_filterTopic != null) {
      list = list.where((q) => q.topicId == _filterTopic!.id).toList();
    }
    if (_search.isNotEmpty) {
      list = list
          .where((q) =>
              q.title.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        _actionBar(),
        if (_filterTopic != null) _activeChips(),
        Expanded(child: _list()),
      ]),
      if (_filterOpen)
        GestureDetector(
          onTap: () => setState(() => _filterOpen = false),
          child: Container(color: Colors.black.withOpacity(0.35)),
        ),
      AnimatedPositioned(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        right: _filterOpen ? 0 : -290,
        top: 0,
        bottom: 0,
        width: 270,
        child: _filterPanel(),
      ),
    ]);
  }

  Widget _actionBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Тест хайх...',
                prefixIcon: const Icon(Icons.search, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(width: 8),
          _FilterIconBtn(
            active: _filterTopic != null,
            onTap: () => setState(() => _filterOpen = !_filterOpen),
          ),
          FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Нэмэх'),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
        ]),
      );

  Widget _activeChips() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Wrap(spacing: 8, children: [
          if (_filterTopic != null)
            Chip(
              label: Text(_filterTopic!.title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => setState(() => _filterTopic = null),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.primary),
              side: const BorderSide(color: AppColors.primary, width: 0.5),
            ),
        ]),
      );

  Widget _list() {
    final items = _filtered;
    if (items.isEmpty) return _emptyState(Icons.quiz_outlined, 'Тест олдсонгүй');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 56, endIndent: 0),
      itemBuilder: (ctx, i) {
        final q = items[i];
        final topic = widget.topics.firstWhere((t) => t.id == q.topicId,
            orElse: () => Topic(id: 0, title: '—', order: 0));
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.quiz_outlined,
                color: AppColors.secondary, size: 22),
          ),
          title: Text(q.title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Row(children: [
            const Icon(Icons.topic_outlined, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(topic.title,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primary)),
          ]),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (_) => [
              _menuItem('edit', Icons.edit_outlined, 'Засах', Colors.blue),
              _menuItem(
                  'delete', Icons.delete_outline, 'Устгах', Colors.red),
            ],
            onSelected: (v) {
              if (v == 'edit') _openForm(ctx, quiz: q);
              if (v == 'delete') _confirmDelete(ctx, q);
            },
          ),
          onTap: () => _openForm(ctx, quiz: q),
        );
      },
    );
  }

  Widget _filterPanel() => Material(
        elevation: 12,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Шүүлтүүр',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _filterOpen = false)),
                      ]),
                  const Divider(height: 24),
                  const Text('Сэдвээр шүүх',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _PickerTile(
                    value: _filterTopic?.title,
                    placeholder: 'Бүгд',
                    onTap: () async {
                      setState(() => _filterOpen = false);
                      final sel = await _showPicker<Topic>(
                        context,
                        title: 'Сэдэв сонгох',
                        items: widget.topics,
                        getTitle: (t) => t.title,
                        getSubtitle: (t) => t.description,
                        selected: _filterTopic,
                      );
                      if (sel != null) setState(() => _filterTopic = sel);
                    },
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() {
                          _filterTopic = null;
                        }),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Цэвэрлэх'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44)),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => setState(() => _filterOpen = false),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 44)),
                    child: const Text('Хэрэглэх'),
                  ),
                ]),
          ),
        ),
      );

  void _openForm(BuildContext ctx, {Quiz? quiz}) {
    Topic? selTopic = quiz != null
        ? widget.topics.firstWhere((t) => t.id == quiz.topicId,
            orElse: () =>
                widget.topics.isNotEmpty ? widget.topics.first : Topic(id: 0, title: '', order: 0))
        : (_filterTopic ??
            (widget.topics.isNotEmpty ? widget.topics.first : null));
    final titleC = TextEditingController(text: quiz?.title ?? '');
    final descC = TextEditingController(text: quiz?.description ?? '');
    final orderC =
        TextEditingController(text: (quiz?.order ?? 0).toString());

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bsCtx) => StatefulBuilder(
        builder: (bsCtx, ss) => _FormSheet(
          title: quiz == null ? 'Тест нэмэх' : 'Тест засах',
          onDelete: quiz != null ? () => _confirmDelete(bsCtx, quiz) : null,
          onSave: () async {
            final t = selTopic;
            if (t == null || t.id == 0) return;
            final ok = quiz == null
                ? await ApiService.createQuiz({
                    'title': titleC.text.trim(),
                    'description': descC.text.trim(),
                    'topic_id': t.id,
                    'order': int.tryParse(orderC.text) ?? 0,
                  })
                : await ApiService.updateQuiz(quiz.id, {
                    'title': titleC.text.trim(),
                    'description': descC.text.trim(),
                    'topic_id': t.id,
                    'order': int.tryParse(orderC.text) ?? 0,
                  });
            if (ok) {
              widget.onRefresh();
              if (bsCtx.mounted) Navigator.pop(bsCtx);
            }
          },
          fields: [
            _DropField<Topic>(
              label: 'Сэдэв *',
              value: selTopic?.id == 0 ? null : selTopic,
              items: widget.topics,
              getLabel: (t) => t.title,
              onChanged: (v) => ss(() => selTopic = v),
            ),
            const SizedBox(height: 12),
            _FF(controller: titleC, label: 'Гарчиг *', hint: 'Тестийн нэр'),
            const SizedBox(height: 12),
            _FF(
                controller: descC,
                label: 'Тайлбар',
                hint: 'Товч тайлбар',
                maxLines: 2),
            const SizedBox(height: 12),
            _FF(
                controller: orderC,
                label: 'Дараалал',
                hint: '0',
                inputType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, Quiz q) => showDialog(
        context: ctx,
        builder: (_) => _ConfirmDelete(
          name: q.title,
          onConfirm: () async {
            await ApiService.deleteQuiz(q.id);
            widget.onRefresh();
            if (ctx.mounted) {
              Navigator.pop(ctx);
              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
            }
          },
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// QUESTION TAB
// ═══════════════════════════════════════════════════════════════════

class _QuestionTab extends StatefulWidget {
  final List<Topic> topics;
  final List<Quiz> quizzes;
  final VoidCallback onRefresh;
  const _QuestionTab(
      {required this.topics,
      required this.quizzes,
      required this.onRefresh});
  @override
  State<_QuestionTab> createState() => _QuestionTabState();
}

class _QuestionTabState extends State<_QuestionTab> {
  List<AdminQuestion> _questions = [];
  bool _loading = true;
  bool _filterOpen = false;
  Topic? _filterTopic;
  Quiz? _filterQuiz;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchAllQuestions();
    if (mounted) {
      setState(() {
        _questions = data.map((j) => AdminQuestion.fromJson(j)).toList();
        _loading = false;
      });
    }
  }

  List<Quiz> get _topicQuizzes => _filterTopic == null
      ? widget.quizzes
      : widget.quizzes.where((q) => q.topicId == _filterTopic!.id).toList();

  List<AdminQuestion> get _filtered {
    var list = _questions;
    if (_filterQuiz != null) {
      list = list.where((q) => q.quizId == _filterQuiz!.id).toList();
    } else if (_filterTopic != null) {
      final qIds =
          _topicQuizzes.map((q) => q.id).toSet();
      list = list.where((q) => qIds.contains(q.quizId)).toList();
    }
    if (_search.isNotEmpty) {
      list = list
          .where((q) =>
              q.text.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Stack(children: [
      Column(children: [
        _actionBar(),
        if (_filterTopic != null || _filterQuiz != null) _activeChips(),
        Expanded(child: _list()),
      ]),
      if (_filterOpen)
        GestureDetector(
          onTap: () => setState(() => _filterOpen = false),
          child: Container(color: Colors.black.withOpacity(0.35)),
        ),
      AnimatedPositioned(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        right: _filterOpen ? 0 : -290,
        top: 0,
        bottom: 0,
        width: 270,
        child: _filterPanel(),
      ),
    ]);
  }

  Widget _actionBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Асуулт хайх...',
                prefixIcon: const Icon(Icons.search, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(width: 8),
          _FilterIconBtn(
            active: _filterTopic != null || _filterQuiz != null,
            onTap: () => setState(() => _filterOpen = !_filterOpen),
          ),
          FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Нэмэх'),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
        ]),
      );

  Widget _activeChips() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Wrap(spacing: 8, children: [
          if (_filterTopic != null)
            Chip(
              label: Text(_filterTopic!.title,
                  style: const TextStyle(fontSize: 12)),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => setState(() {
                _filterTopic = null;
                _filterQuiz = null;
              }),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.primary),
            ),
          if (_filterQuiz != null)
            Chip(
              label: Text(_filterQuiz!.title,
                  style: const TextStyle(fontSize: 12)),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => setState(() => _filterQuiz = null),
              backgroundColor: AppColors.secondary.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.secondary),
            ),
        ]),
      );

  Widget _list() {
    final items = _filtered;
    if (items.isEmpty)
      return _emptyState(Icons.help_outline, 'Асуулт олдсонгүй');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 56, endIndent: 0),
      itemBuilder: (ctx, i) {
        final q = items[i];
        final quiz = widget.quizzes.firstWhere((qz) => qz.id == q.quizId,
            orElse: () => Quiz(
                id: 0, title: '—', topicId: 0, order: 0, questions: []));
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.help_outline,
                color: AppColors.warning, size: 22),
          ),
          title: Text(q.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Row(children: [
            _diffChip(q.difficultyLevel),
            const SizedBox(width: 8),
            Flexible(
              child: Text(quiz.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[600])),
            ),
          ]),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (_) => [
              _menuItem('edit', Icons.edit_outlined, 'Засах', Colors.blue),
              _menuItem(
                  'delete', Icons.delete_outline, 'Устгах', Colors.red),
            ],
            onSelected: (v) {
              if (v == 'edit') _openForm(ctx, question: q);
              if (v == 'delete') _confirmDelete(ctx, q);
            },
          ),
          onTap: () => _openForm(ctx, question: q),
        );
      },
    );
  }

  Widget _filterPanel() => Material(
        elevation: 12,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Шүүлтүүр',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _filterOpen = false)),
                      ]),
                  const Divider(height: 24),
                  const Text('Сэдвээр шүүх',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _PickerTile(
                    value: _filterTopic?.title,
                    placeholder: 'Бүгд',
                    onTap: () async {
                      setState(() => _filterOpen = false);
                      final sel = await _showPicker<Topic>(context,
                          title: 'Сэдэв сонгох',
                          items: widget.topics,
                          getTitle: (t) => t.title,
                          getSubtitle: (t) => t.description,
                          selected: _filterTopic);
                      if (sel != null) {
                        setState(() {
                          _filterTopic = sel;
                          _filterQuiz = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Тестээр шүүх',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _PickerTile(
                    value: _filterQuiz?.title,
                    placeholder: 'Бүгд',
                    onTap: () async {
                      setState(() => _filterOpen = false);
                      final sel = await _showPicker<Quiz>(context,
                          title: 'Тест сонгох',
                          items: _topicQuizzes,
                          getTitle: (q) => q.title,
                          selected: _filterQuiz);
                      if (sel != null) setState(() => _filterQuiz = sel);
                    },
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _filterTopic = null;
                      _filterQuiz = null;
                    }),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Цэвэрлэх'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44)),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => setState(() => _filterOpen = false),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 44)),
                    child: const Text('Хэрэглэх'),
                  ),
                ]),
          ),
        ),
      );

  void _openForm(BuildContext ctx, {AdminQuestion? question}) {
    Quiz? selQuiz = question != null
        ? widget.quizzes
            .firstWhere((q) => q.id == question.quizId,
                orElse: () => widget.quizzes.isNotEmpty
                    ? widget.quizzes.first
                    : Quiz(id: 0, title: '', topicId: 0, order: 0, questions: []))
        : (_filterQuiz ??
            (widget.quizzes.isNotEmpty ? widget.quizzes.first : null));
    final textC = TextEditingController(text: question?.text ?? '');
    final diffC = TextEditingController(
        text: (question?.difficultyLevel ?? 50).toString());
    final orderC =
        TextEditingController(text: (question?.order ?? 0).toString());

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bsCtx) => StatefulBuilder(
        builder: (bsCtx, ss) => _FormSheet(
          title: question == null ? 'Асуулт нэмэх' : 'Асуулт засах',
          onDelete:
              question != null ? () => _confirmDelete(bsCtx, question) : null,
          onSave: () async {
            final q = selQuiz;
            if (q == null || q.id == 0) return;
            final ok = question == null
                ? await ApiService.createQuestion({
                    'quiz_id': q.id,
                    'text': textC.text.trim(),
                    'difficulty_level': int.tryParse(diffC.text) ?? 50,
                    'order': int.tryParse(orderC.text) ?? 0,
                  })
                : await ApiService.updateQuestion(question.id, {
                    'quiz_id': q.id,
                    'text': textC.text.trim(),
                    'difficulty_level': int.tryParse(diffC.text) ?? 50,
                    'order': int.tryParse(orderC.text) ?? 0,
                  });
            if (ok) {
              _load();
              widget.onRefresh();
              if (bsCtx.mounted) Navigator.pop(bsCtx);
            }
          },
          fields: [
            _DropField<Quiz>(
              label: 'Тест *',
              value: selQuiz?.id == 0 ? null : selQuiz,
              items: widget.quizzes,
              getLabel: (q) => q.title,
              onChanged: (v) => ss(() => selQuiz = v),
            ),
            const SizedBox(height: 12),
            _FF(
                controller: textC,
                label: 'Асуулт *',
                hint: 'Асуулт бичнэ үү',
                maxLines: 3),
            const SizedBox(height: 12),
            _FF(
                controller: diffC,
                label: 'Хүндрэлийн түвшин (1–100)',
                hint: '50',
                inputType: TextInputType.number),
            const SizedBox(height: 12),
            _FF(
                controller: orderC,
                label: 'Дараалал',
                hint: '0',
                inputType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AdminQuestion q) => showDialog(
        context: ctx,
        builder: (_) => _ConfirmDelete(
          name: q.text,
          onConfirm: () async {
            await ApiService.deleteQuestion(q.id);
            _load();
            widget.onRefresh();
            if (ctx.mounted) {
              Navigator.pop(ctx);
              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
            }
          },
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// OPTION TAB
// ═══════════════════════════════════════════════════════════════════

class _OptionTab extends StatefulWidget {
  final List<Topic> topics;
  final List<Quiz> quizzes;
  final VoidCallback onRefresh;
  const _OptionTab(
      {required this.topics,
      required this.quizzes,
      required this.onRefresh});
  @override
  State<_OptionTab> createState() => _OptionTabState();
}

class _OptionTabState extends State<_OptionTab> {
  List<AdminQuestion> _questions = [];
  List<AdminOption> _options = [];
  bool _loading = true;
  bool _filterOpen = false;
  Quiz? _filterQuiz;
  AdminQuestion? _filterQuestion;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final qData = await ApiService.fetchAllQuestions();
    final oData = await ApiService.fetchAllOptions();
    if (mounted) {
      setState(() {
        _questions = qData.map((j) => AdminQuestion.fromJson(j)).toList();
        _options = oData.map((j) => AdminOption.fromJson(j)).toList();
        _loading = false;
      });
    }
  }

  List<AdminQuestion> get _quizQuestions => _filterQuiz == null
      ? _questions
      : _questions.where((q) => q.quizId == _filterQuiz!.id).toList();

  List<AdminOption> get _filtered {
    var list = _options;
    if (_filterQuestion != null) {
      list = list.where((o) => o.questionId == _filterQuestion!.id).toList();
    } else if (_filterQuiz != null) {
      final qIds = _quizQuestions.map((q) => q.id).toSet();
      list = list.where((o) => qIds.contains(o.questionId)).toList();
    }
    if (_search.isNotEmpty) {
      list = list
          .where((o) =>
              o.text.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Stack(children: [
      Column(children: [
        _actionBar(),
        if (_filterQuiz != null || _filterQuestion != null) _activeChips(),
        Expanded(child: _list()),
      ]),
      if (_filterOpen)
        GestureDetector(
          onTap: () => setState(() => _filterOpen = false),
          child: Container(color: Colors.black.withOpacity(0.35)),
        ),
      AnimatedPositioned(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        right: _filterOpen ? 0 : -290,
        top: 0,
        bottom: 0,
        width: 270,
        child: _filterPanel(),
      ),
    ]);
  }

  Widget _actionBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Сонголт хайх...',
                prefixIcon: const Icon(Icons.search, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(width: 8),
          _FilterIconBtn(
            active: _filterQuiz != null || _filterQuestion != null,
            onTap: () => setState(() => _filterOpen = !_filterOpen),
          ),
          FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Нэмэх'),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
        ]),
      );

  Widget _activeChips() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Wrap(spacing: 8, children: [
          if (_filterQuiz != null)
            Chip(
              label: Text(_filterQuiz!.title,
                  style: const TextStyle(fontSize: 12)),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => setState(() {
                _filterQuiz = null;
                _filterQuestion = null;
              }),
              backgroundColor: AppColors.secondary.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.secondary),
            ),
          if (_filterQuestion != null)
            Chip(
              label: Text(_filterQuestion!.text,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => setState(() => _filterQuestion = null),
              backgroundColor: AppColors.warning.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.warning),
            ),
        ]),
      );

  Widget _list() {
    final items = _filtered;
    if (items.isEmpty)
      return _emptyState(Icons.checklist_outlined, 'Сонголт олдсонгүй');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (ctx, i) {
        final o = items[i];
        final question = _questions.firstWhere(
            (q) => q.id == o.questionId,
            orElse: () =>
                AdminQuestion(id: 0, quizId: 0, text: '—', difficultyLevel: 50, order: 0));
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: (o.isCorrect
                        ? AppColors.success
                        : Colors.grey)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(
              o.isCorrect ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              color: o.isCorrect ? AppColors.success : Colors.grey,
              size: 22,
            ),
          ),
          title: Text(o.text,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(question.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (_) => [
              _menuItem('edit', Icons.edit_outlined, 'Засах', Colors.blue),
              _menuItem(
                  'delete', Icons.delete_outline, 'Устгах', Colors.red),
            ],
            onSelected: (v) {
              if (v == 'edit') _openForm(ctx, option: o);
              if (v == 'delete') _confirmDelete(ctx, o);
            },
          ),
          onTap: () => _openForm(ctx, option: o),
        );
      },
    );
  }

  Widget _filterPanel() => Material(
        elevation: 12,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Шүүлтүүр',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _filterOpen = false)),
                      ]),
                  const Divider(height: 24),
                  const Text('Тестээр шүүх',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _PickerTile(
                    value: _filterQuiz?.title,
                    placeholder: 'Бүгд',
                    onTap: () async {
                      setState(() => _filterOpen = false);
                      final sel = await _showPicker<Quiz>(context,
                          title: 'Тест сонгох',
                          items: widget.quizzes,
                          getTitle: (q) => q.title,
                          selected: _filterQuiz);
                      if (sel != null) {
                        setState(() {
                          _filterQuiz = sel;
                          _filterQuestion = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Асуултаар шүүх',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _PickerTile(
                    value: _filterQuestion?.text,
                    placeholder: 'Бүгд',
                    onTap: () async {
                      setState(() => _filterOpen = false);
                      final sel = await _showPicker<AdminQuestion>(context,
                          title: 'Асуулт сонгох',
                          items: _quizQuestions,
                          getTitle: (q) => q.text,
                          selected: _filterQuestion);
                      if (sel != null) setState(() => _filterQuestion = sel);
                    },
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _filterQuiz = null;
                      _filterQuestion = null;
                    }),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Цэвэрлэх'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44)),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => setState(() => _filterOpen = false),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 44)),
                    child: const Text('Хэрэглэх'),
                  ),
                ]),
          ),
        ),
      );

  void _openForm(BuildContext ctx, {AdminOption? option}) {
    AdminQuestion? selQuestion = option != null
        ? _questions.firstWhere((q) => q.id == option.questionId,
            orElse: () => _questions.isNotEmpty
                ? _questions.first
                : AdminQuestion(id: 0, quizId: 0, text: '', difficultyLevel: 50, order: 0))
        : (_filterQuestion ??
            (_quizQuestions.isNotEmpty ? _quizQuestions.first : null));
    final textC = TextEditingController(text: option?.text ?? '');
    bool isCorrect = option?.isCorrect ?? false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bsCtx) => StatefulBuilder(
        builder: (bsCtx, ss) => _FormSheet(
          title: option == null ? 'Сонголт нэмэх' : 'Сонголт засах',
          onDelete:
              option != null ? () => _confirmDelete(bsCtx, option) : null,
          onSave: () async {
            final sq = selQuestion;
            if (sq == null || sq.id == 0) return;
            final ok = option == null
                ? await ApiService.createOption({
                    'question_id': sq.id,
                    'text': textC.text.trim(),
                    'is_correct': isCorrect,
                  })
                : await ApiService.updateOption(option.id, {
                    'question_id': sq.id,
                    'text': textC.text.trim(),
                    'is_correct': isCorrect,
                  });
            if (ok) {
              _load();
              widget.onRefresh();
              if (bsCtx.mounted) Navigator.pop(bsCtx);
            }
          },
          fields: [
            _DropField<AdminQuestion>(
              label: 'Асуулт *',
              value: selQuestion?.id == 0 ? null : selQuestion,
              items: _questions,
              getLabel: (q) => q.text.length > 50
                  ? '${q.text.substring(0, 50)}...'
                  : q.text,
              onChanged: (v) => ss(() => selQuestion = v),
            ),
            const SizedBox(height: 12),
            _FF(
                controller: textC,
                label: 'Сонголтын текст *',
                hint: 'Хариултын текст'),
            const SizedBox(height: 16),
            Row(children: [
              const Text('Зөв хариулт мөн үү?',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(
                value: isCorrect,
                activeColor: AppColors.success,
                onChanged: (v) => ss(() => isCorrect = v),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AdminOption o) => showDialog(
        context: ctx,
        builder: (_) => _ConfirmDelete(
          name: o.text,
          onConfirm: () async {
            await ApiService.deleteOption(o.id);
            _load();
            widget.onRefresh();
            if (ctx.mounted) {
              Navigator.pop(ctx);
              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
            }
          },
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _FilterIconBtn extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _FilterIconBtn({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(Icons.tune,
                color: active ? AppColors.primary : null),
            onPressed: onTap,
            tooltip: 'Шүүлтүүр',
          ),
          if (active)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle),
              ),
            ),
        ],
      );
}

class _PickerTile extends StatelessWidget {
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  const _PickerTile(
      {required this.value,
      required this.placeholder,
      required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
                color: value != null
                    ? AppColors.primary
                    : const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(8),
            color: value != null
                ? AppColors.primary.withOpacity(0.05)
                : null,
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                    color: value != null
                        ? AppColors.primary
                        : Colors.grey[500],
                    fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14,
                color: value != null ? AppColors.primary : Colors.grey[400]),
          ]),
        ),
      );
}

class _FormSheet extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final Future<void> Function() onSave;
  final VoidCallback? onDelete;

  const _FormSheet({
    required this.title,
    required this.fields,
    required this.onSave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 20),
            ...fields,
            const SizedBox(height: 24),
            if (onDelete != null) ...[
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.red),
                label: const Text('Устгах',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
            ],
            FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text(
                  onDelete != null ? 'Хадгалах' : 'Нэмэх',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDelete extends StatelessWidget {
  final String name;
  final Future<void> Function() onConfirm;
  const _ConfirmDelete({required this.name, required this.onConfirm});

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
          SizedBox(width: 8),
          Text('Устгах уу?'),
        ]),
        content: Text(
            '"${name.length > 50 ? '${name.substring(0, 50)}...' : name}"\n\nЭнэ үйлдлийг буцаах боломжгүй.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Болих')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Устгах'),
          ),
        ],
      );
}

Widget _emptyState(IconData icon, String msg) => Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 72, color: Colors.grey[200]),
        const SizedBox(height: 16),
        Text(msg,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      ]),
    );

// ═══════════════════════════════════════════════════════════════════
// LESSON TAB  — Topic-уудыг хичээлийн картаар харуулж CRUD хийнэ
// ═══════════════════════════════════════════════════════════════════

// Хичээлийн лого өнгийг topic.id-оор тодорхойлно
Color _lessonColor(int id) {
  return [
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFF3B82F6),
    const Color(0xFFEF4444),
    const Color(0xFF14B8A6),
  ][id % 8];
}

IconData _lessonIcon(int index) {
  const icons = [
    Icons.menu_book,
    Icons.calculate,
    Icons.science,
    Icons.history_edu,
    Icons.language,
    Icons.palette,
    Icons.music_note,
    Icons.sports_soccer,
  ];
  return icons[index % icons.length];
}

class _LessonTab extends StatefulWidget {
  final List<Topic> topics;
  final List<Quiz> quizzes;
  final VoidCallback onRefresh;
  const _LessonTab(
      {required this.topics,
      required this.quizzes,
      required this.onRefresh});
  @override
  State<_LessonTab> createState() => _LessonTabState();
}

class _LessonTabState extends State<_LessonTab> {
  String _search = '';

  List<Topic> get _filtered => _search.isEmpty
      ? widget.topics
      : widget.topics
          .where((t) =>
              t.title.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _actionBar(),
      Expanded(child: _grid()),
    ]);
  }

  Widget _actionBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Хичээл хайх...',
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Нэмэх'),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
        ]),
      );

  Widget _grid() {
    final items = _filtered;
    if (items.isEmpty) {
      return _emptyState(Icons.menu_book_outlined, 'Хичээл олдсонгүй');
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final topic = items[i];
        final color = _lessonColor(topic.id);
        final icon = _lessonIcon(i);
        final quizCount = widget.quizzes
            .where((q) => q.topicId == topic.id)
            .length;

        return _LessonCard(
          topic: topic,
          color: color,
          icon: icon,
          quizCount: quizCount,
          onTap: () => _openDetail(ctx, topic, color, icon),
          onEdit: () => _openForm(ctx, topic: topic),
          onDelete: () => _confirmDelete(ctx, topic),
        );
      },
    );
  }

  void _openDetail(
      BuildContext ctx, Topic topic, Color color, IconData icon) {
    final quizzes = widget.quizzes
        .where((q) => q.topicId == topic.id)
        .toList();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header gradient
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 52,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openForm(ctx, topic: topic);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirmDelete(ctx, topic);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(topic.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            if (topic.description != null &&
                                topic.description!.isNotEmpty)
                              Text(topic.description!,
                                  style: TextStyle(
                                      color:
                                          Colors.white.withOpacity(0.8),
                                      fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    _InfoPill(
                        icon: Icons.quiz_outlined,
                        label: 'quizCount тест'),
                    const SizedBox(width: 10),
                    _InfoPill(
                        icon: Icons.sort,
                        label: 'Дараалал: ${topic.order}'),
                  ]),
                ],
              ),
            ),

            // ── Quiz list
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Тестүүд ()',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Тест нэмэх'),
                      onPressed: () =>
                          _showAddQuizSheet(ctx, topic.id),
                    )
                  ]),
            ),
            Expanded(
              child: quizzes.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Icon(Icons.quiz_outlined,
                              size: 48, color: Colors.grey[200]),
                          const SizedBox(height: 8),
                          Text('Тест байхгүй',
                              style: TextStyle(
                                  color: Colors.grey[400])),
                        ]))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: quizzes.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final quiz = quizzes[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          title: Text(quiz.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          subtitle: quiz.description != null &&
                                  quiz.description!.isNotEmpty
                              ? Text(quiz.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12))
                              : null,
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            itemBuilder: (_) => [
                              _menuItem('delete', Icons.delete_outline,
                                  'Устгах', Colors.red),
                            ],
                            onSelected: (v) async {
                              if (v == 'delete') {
                                await ApiService.deleteQuiz(quiz.id);
                                widget.onRefresh();
                                if (ctx.mounted) Navigator.pop(ctx);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuizSheet(BuildContext ctx, int topicId) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bsCtx) => _FormSheet(
        title: 'Тест нэмэх',
        onSave: () async {
          final ok = await ApiService.createQuiz({
            'title': titleC.text.trim(),
            'description': descC.text.trim(),
            'topic_id': topicId,
            'order': 0,
          });
          if (ok) {
            widget.onRefresh();
            if (bsCtx.mounted) Navigator.pop(bsCtx);
          }
        },
        fields: [
          _FF(controller: titleC, label: 'Гарчиг *', hint: 'Тестийн нэр'),
          const SizedBox(height: 12),
          _FF(
              controller: descC,
              label: 'Тайлбар',
              hint: 'Товч тайлбар',
              maxLines: 2),
        ],
      ),
    );
  }

  void _openForm(BuildContext ctx, {Topic? topic}) {
    final titleC = TextEditingController(text: topic?.title ?? '');
    final descC = TextEditingController(text: topic?.description ?? '');
    final orderC =
        TextEditingController(text: (topic?.order ?? 0).toString());

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bsCtx) => _FormSheet(
        title: topic == null ? 'Хичээл нэмэх' : 'Хичээл засах',
        onDelete: topic != null ? () => _confirmDelete(bsCtx, topic) : null,
        onSave: () async {
          final ok = topic == null
              ? await ApiService.createTopic({
                  'title': titleC.text.trim(),
                  'description': descC.text.trim(),
                  'order': int.tryParse(orderC.text) ?? 0,
                })
              : await ApiService.updateTopic(topic.id, {
                  'title': titleC.text.trim(),
                  'description': descC.text.trim(),
                  'order': int.tryParse(orderC.text) ?? 0,
                });
          if (ok) {
            widget.onRefresh();
            if (bsCtx.mounted) Navigator.pop(bsCtx);
          }
        },
        fields: [
          _FF(controller: titleC, label: 'Хичээлийн нэр *', hint: 'Жишээ: Математик'),
          const SizedBox(height: 12),
          _FF(
              controller: descC,
              label: 'Тайлбар',
              hint: 'Товч тайлбар',
              maxLines: 2),
          const SizedBox(height: 12),
          _FF(
              controller: orderC,
              label: 'Дараалал',
              hint: '0',
              inputType: TextInputType.number),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, Topic t) => showDialog(
        context: ctx,
        builder: (_) => _ConfirmDelete(
          name: t.title,
          onConfirm: () async {
            await ApiService.deleteTopic(t.id);
            widget.onRefresh();
            if (ctx.mounted) {
              Navigator.pop(ctx);
              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
            }
          },
        ),
      );
}

// ── Lesson card
class _LessonCard extends StatelessWidget {
  final Topic topic;
  final Color color;
  final IconData icon;
  final int quizCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LessonCard({
    required this.topic,
    required this.color,
    required this.icon,
    required this.quizCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Bg decoration circle
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon box
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white, size: 26),
                      ),
                      // 3-dot menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white, size: 18),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        itemBuilder: (_) => [
                          _menuItem('edit', Icons.edit_outlined, 'Засах',
                              Colors.blue),
                          _menuItem('delete', Icons.delete_outline,
                              'Устгах', Colors.red),
                        ],
                        onSelected: (v) {
                          if (v == 'edit') onEdit();
                          if (v == 'delete') onDelete();
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    topic.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        const Icon(Icons.quiz_outlined,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text('$quizCount тест',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small pill badge inside detail sheet header
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}