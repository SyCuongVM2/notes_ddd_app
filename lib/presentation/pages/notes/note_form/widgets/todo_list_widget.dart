import 'dart:ui';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:kt_dart/collection.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/notes/value_objects.dart';
import '../../../../../domain/notes/todo_item_primitive.dart';
import '../../../../../application/notes/note_form/note_form_bloc.dart';
import '../../../../../infrastructure/core/build_context_x.dart';

class TodoList extends StatelessWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NoteFormBloc, NoteFormState>(
          listenWhen: (p, c) => p.isEditing != c.isEditing,
          listener: (context, state) {
            context.formTodos = state.note.todos.value.fold(
              (_) => mutableListOf<TodoItemPrimitive>(), 
              (todoItemList) => todoItemList.map(
                (_) =>  TodoItemPrimitive.fromDomain(_)
              ).toMutableList(),
            );
          },
        ),
        BlocListener<NoteFormBloc, NoteFormState>(
          listenWhen: (p, c) => p.note.todos.length != 0 && 
                                p.note.todos.isFull != c.note.todos.isFull,
          listener: (context, state) {
            if (state.note.todos.isFull) {
              FlushbarHelper.createAction(
                message: 'Want longer lists? Activate premium 🤩',
                button: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'BUY NOW',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
                duration: const Duration(seconds: 5),
              ).show(context);
            }
          },
        ),
      ],
      child: Consumer<FormTodos>(
        builder: (context, formTodos, child) {
          return ImplicitlyAnimatedReorderableList<TodoItemPrimitive>(
            shrinkWrap: true,
            updateDuration: const Duration(milliseconds: 50),
            removeDuration: const Duration(milliseconds: 250),
            items: formTodos.value.asList(),
            areItemsTheSame: (oldItem, newItem) => oldItem.id == newItem.id,
            onReorderFinished: (item, from, to, newItems) {
              context.formTodos = newItems.toImmutableList();
              context.read<NoteFormBloc>()
                .add(NoteFormEvent.todosChanged(context.formTodos));
            },
            itemBuilder: (context, itemAnimation, item, index) {
              return Reorderable(
                key: ValueKey(item.id),
                builder: (context, dragAnimation, inDrag) {
                  final elevation = lerpDouble(0, 8, dragAnimation.value);
                  return ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 0.95).animate(dragAnimation),
                    child: TodoTile(
                      index: index,
                      elevation: elevation,
                    ),
                  );
                },
              );
            },
            updateItemBuilder: (context, itemAnimation, item) {
              return Reorderable(
                key: ValueKey(item.id),
                builder: (context, dragAnimation, inDrag) {
                  return StaticTodoTile(
                    todo: item,
                  );
                },
              );
            },
            removeItemBuilder: (context, itemAnimation, item) {
              return Reorderable(
                key: ValueKey(item.id),
                builder: (context, dragAnimation, inDrag) {
                  return FadeTransition(
                    opacity: itemAnimation,
                    child: StaticTodoTile(
                      todo: item,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class StaticTodoTile extends StatelessWidget {
  final TodoItemPrimitive todo;
  final double elevation;

  const StaticTodoTile({
    Key? key,
    required this.todo,
    double? elevation,
  })  : elevation = elevation ?? 0,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      secondaryActions: const [
        IconSlideAction(
          caption: 'Delete',
          icon: Icons.delete,
          color: Colors.red,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          elevation: elevation,
          animationDuration: const Duration(milliseconds: 100),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Checkbox(
                value: todo.done,
                onChanged: (_) {},
              ),
              trailing: const Handle(
                child: Icon(
                  Icons.list,
                ),
              ),
              title: TextFormField(
                initialValue: todo.name,
                enabled: false,
                decoration: const InputDecoration(
                  hintText: 'Todo',
                  counterText: '',
                  border: InputBorder.none,
                ),
                maxLength: TodoName.maxLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TodoTile extends HookWidget {
  final int index;
  final double elevation;

  const TodoTile({
    required this.index,
    double? elevation,
    Key? key,
  }) : elevation = elevation ?? 0,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final todo = context.formTodos.getOrElse(index, (_) => TodoItemPrimitive.empty());
    final textEditingController = useTextEditingController(text: todo.name);

    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      secondaryActions: [
        IconSlideAction(
          caption: 'Delete',
          icon: Icons.delete,
          color: Colors.red,
          onTap: () {
            context.formTodos = context.formTodos.minusElement(todo);
            context.read<NoteFormBloc>()
              .add(NoteFormEvent.todosChanged(context.formTodos));
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          elevation: elevation,
          animationDuration: const Duration(milliseconds: 50),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Checkbox(
                value: todo.done, 
                onChanged: (value) {
                  context.formTodos = context.formTodos.map(
                    (listTodo) => listTodo == todo
                      ? todo.copyWith(done: value!)
                      : listTodo,
                  );
                  context.read<NoteFormBloc>()
                    .add(NoteFormEvent.todosChanged(context.formTodos));
                },
              ),
              trailing: const Handle(
                child: Icon(Icons.list),
              ),
              title: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Todo',
                  counterText: '',
                  border: InputBorder.none,
                ),
                maxLength: TodoName.maxLength,
                maxLines: 1,
                onChanged: (value) {
                  context.formTodos = context.formTodos.map(
                    (listTodo) => listTodo == todo
                      ? todo.copyWith(name: value)
                      : listTodo,
                  );
                  context.read<NoteFormBloc>()
                    .add(NoteFormEvent.todosChanged(context.formTodos));
                },
                validator: (_) {
                  return context
                    .read<NoteFormBloc>()
                    .state
                    .note
                    .todos
                    .value
                    .fold(
                      // Failure stemming from the TodoList length should NOT be displayed by the individual TextFormFields
                      (f) => null,
                      (todoList) => todoList[index].name.value.fold(
                        (f) => f.maybeMap(
                          empty: (_) => 'Cannot be empty',
                          exceedingLength: (_) => 'Too long',
                          multiline: (_) => 'Has to be in a single line',
                          orElse: () => null,
                        ),
                        (_) => null,
                      ),
                    );
                },
              )
            ),
          ),
        ),
      ),
    );
  }
}