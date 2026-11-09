import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/main.dart';

void main() {
  test('Task se serializa y deserializa', () {
    final t = Task.fromJson(Task('Comprar pan', done: true).toJson());
    expect(t.title, 'Comprar pan');
    expect(t.done, true);
  });

  testWidgets('agregar, completar, filtrar y borrar una tarea', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas aquí'), findsOneWidget);

    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Estudiar Flutter');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Estudiar Flutter'), findsOneWidget);
    expect(find.text('1 pendiente(s) de 1'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('0 pendiente(s) de 1'), findsOneWidget);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    expect(find.text('Estudiar Flutter'), findsNothing);

    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Estudiar Flutter'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas aquí'), findsOneWidget);
  });
}
