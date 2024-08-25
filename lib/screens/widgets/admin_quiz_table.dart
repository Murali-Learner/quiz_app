import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/models/user_model.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AdminQuizTable extends StatefulWidget {
  const AdminQuizTable({super.key});

  @override
  AdminQuizTableState createState() => AdminQuizTableState();
}

class AdminQuizTableState extends State<AdminQuizTable> {
  List<UserModel> _users = [];
  List<QuestionModel> _questions = [];

  StreamSubscription? _usersSubscription;
  StreamSubscription? _questionsSubscription;
  UsersDataSource? _usersDataSource;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    // Fetch users
    final quizProvider = context.read<QuizProvider>();
    final authProvider = context.read<AuthProvider>();

    _usersSubscription = authProvider.getUsersStream().listen(
      (users) {
        debugPrint("uses stream ${users.length}");
        if (mounted) {
          setState(
            () {
              _users = users;
              _initializeDataSource();
            },
          );
        }
      },
    );

    // Fetch questions
    _questionsSubscription = quizProvider.getQuestionsStream().listen(
      (questions) {
        if (mounted) {
          setState(
            () {
              _questions = questions;
              _initializeDataSource();
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _questionsSubscription?.cancel();
    super.dispose();
  }

  void _initializeDataSource() {
    if (_users.isNotEmpty && _questions.isNotEmpty) {
      _usersDataSource = UsersDataSource(
        users: _users,
        questions: _questions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height(50),
      child: _usersDataSource == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SfDataGrid(
              source: _usersDataSource!,
              columns: _getColumns(),
            ),
    );
  }

  List<GridColumn> _getColumns() {
    List<GridColumn> columns = [
      GridColumn(
        columnName: 'User',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text(
            'User',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    columns.addAll(
      _questions.map(
        (question) {
          return GridColumn(
            columnName: question.id.toString(),
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                question.id.toString(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ).toList(),
    );

    return columns;
  }
}

class UsersDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];

  UsersDataSource({
    required List<UserModel> users,
    required List<QuestionModel> questions,
  }) {
    _dataGridRows = users.map<DataGridRow>(
      (user) {
        return DataGridRow(
          cells: [
            DataGridCell<String>(columnName: 'User', value: user.name),
            ...questions.map(
              (question) {
                return DataGridCell<String>(
                  columnName: (question.id).toString(),
                  value: (question.hasAnswered) &&
                          (question.answeredUser) == user.uid
                      ? 'A'
                      : 'NA',
                );
              },
            ),
          ],
        );
      },
    ).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: [
        ...row.getCells().map(
          (cell) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell.value.toString(),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
    );
  }
}
