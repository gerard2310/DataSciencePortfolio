import tasks.tasks as task


def choose_task(value, task_1_is_executed):
    """
    System to choose the task to execute as a user input. Finally it calls continue_task() to decide what to do next.
    :param value: Number of the task previously introduced as a parameter by the user.
    :param task_1_is_executed: Indicates if task 1 has been executed as it is a parameter.
    :return: Nothing
    """
    if value == 1:
        print("Tarea 1:")
        task.execute_task_1()
        task_1_is_executed = True

    elif value == 2:
        if task_1_is_executed:
            print("Tarea 2:")
            task.execute_task_2()

        else:
            print("La tarea 1 se debe ejecutar para poder realizar cualquier otra tarea.")

    elif value == 3:
        if task_1_is_executed:
            print("\nTarea 3:")
            task.execute_task_3()

        else:
            print("La tarea 1 se debe ejecutar para poder realizar cualquier otra tarea.")

    elif value == 4:
        if task_1_is_executed:
            print("\nTarea 4:")
            task.execute_task_4()

        else:
            print("La tarea 1 se debe ejecutar para poder realizar cualquier otra tarea.")

    elif value == 5:
        if task_1_is_executed:
            print("\nTarea 5:")
            task.execute_task_5()

        else:
            print("La tarea 1 se debe ejecutar para poder realizar cualquier otra tarea.")

    elif value == 6:
        if task_1_is_executed:
            print("\nTarea 6:")
            task.execute_task_6()

        else:
            print("La tarea 1 se debe ejecutar para poder realizar cualquier otra tarea.")

    elif value == 7:
        if task_1_is_executed:
            print("\nTarea 7:")
            task.execute_task_7()

        else:
            print("La tarea 1 se debe ejecutar para poder realizar cualquier otra tarea.")

    elif value == 8:
        if task_1_is_executed:
            print("\nTarea 8:")
            task.execute_task_8()

        else:
            print("La tarea 1 se debe ejecutar para poder realizar cualquier otra tarea.")

    else:
        print("\nNot a valid number")

    continue_task(task_1_is_executed)


def continue_task(task_1_is_done):
    """
    Allows the user to decide if he wants to execute another exercise or finish the application.
    If he decides to execute another exercise he has to specify the exercise number and choose_task() will be called.
    :param task_1_is_done: Boolean indicating if task_1 has been executed
    :return: Nothing
    """
    print("¿Quieres ejecutar una tarea de la PEC4?")
    decision = input("Insertar [Yes] o [No]\n")

    if decision.lower() in ["yes", "y", "si", "s"]:
        value = int(input("¿Qué tarea deseas ejecutar?\n"))
        choose_task(value, task_1_is_done)

    else:
        pass

if __name__ == '__main__':
    continue_task(False)






