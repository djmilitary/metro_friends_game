#!/bin/bash

PYTHON_EXECUTABLE="/Users/Tomasz/anaconda3/bin/python3"

$PYTHON_EXECUTABLE - <<END
import sys
import subprocess
import pandas as pd
import random
import time
import tkinter as tk
from tkinter import scrolledtext, simpledialog, font, messagebox

# Проверка существования библиотеки pandas
try:
    import pandas as pd
except ImportError:
    # Установка библиотеки pandas, если её нет
    subprocess.run(["$PYTHON_EXECUTABLE", "-m", "pip", "install", "pandas"])

# Ваш остальной Python-код
data = pd.read_csv('/Users/Tomasz/Documents/list_of_moscow_metro_stations.csv')
data['Line'] = data['Line'].replace({'Московское центральное кольцо':'МЦК'})

def game():
    root = tk.Tk()
    root.title("Полный Отметрос!")

    # Увеличиваем размер основного окна в 1.5 раза
    root.geometry("1200x800")

    root.columnconfigure(0, weight=1)
    root.rowconfigure(0, weight=1)

    result_frame = tk.Frame(root)
    result_frame.grid(column=0, row=0, sticky="nsew", padx=10, pady=10)

    result_text = tk.Text(result_frame, wrap=tk.WORD, width=80, height=20)
    result_text.grid(column=0, row=0, sticky="nsew")

    result_frame.columnconfigure(0, weight=1)
    result_frame.rowconfigure(0, weight=1)

    # Создаем тег для начального текста с использованием HTML-подобного форматирования
    result_text.tag_configure("initial_text", font=('Helvetica', 16, 'bold'), justify='center')
    # Создаем тег для текста раунда
    result_text.tag_configure("round_text", font=('Helvetica', 14, 'bold'), foreground='dark red', justify='center')
    # Создаем тег для подчеркивания значений станций
    result_text.tag_configure("underline", underline=True, justify='center')

    def print_result(text, tag=None):
        result_text.insert("insert", text + "\n", tag)
        result_text.yview(tk.END)
        root.update_idletasks()
        root.update()

    def end_game():
        root.destroy()

    def start_game():
        # Вывод начального текста с использованием заданного тега
        print_result('\n Начинаем веселую и весьма отхлестосную и лихую игру про прогулки от одной случайной станции метро к другой! \n', "initial_text")
        time.sleep(3)

        round = simpledialog.askinteger("Игра в метро", "Сколько раундов вы хотите сыграть?", minvalue=1)

        def run_round(i):
            if i < round:
                random_row = random.randint(0, len(data))
                data_full_r = data.iloc[random_row, :]

                # Вывод текста раунда с использованием соответствующего тега
                print_result(f"\n Раунд {i+1} \n", "round_text")
                time.sleep(2)

                # Подчеркивание значений станций
                station_name = data_full_r['Name']
                print_result(f"Едем на метро до станции {station_name}({data_full_r['Line']}) и двигаемся от нее пешком", "underline")
                if random.randint(0, 1) == 0:
                    next_station = data.loc[random_row+1, 'Name']
                    if next_station != station_name:
                        print_result(f"В начало линии к станции {next_station}({data_full_r['Line']})", "underline")
                    else:
                        print_result(f"В начало линии", "underline")
                else:
                    prev_station = data.loc[random_row-1, 'Name']
                    if prev_station != station_name:
                        print_result(f"В конец линии к станции {prev_station}({data_full_r['Line']})", "underline")
                    else:
                        print_result(f"В конец линии", "underline")
                time.sleep(3)

                root.after(1000, lambda: run_round(i+1))
            else:
                # Заменяем надпись "Игра завершена" на кнопку выхода
                exit_button = tk.Button(result_frame, text="Выход", command=end_game, font=('Helvetica', 14, 'bold'))
                exit_button.grid(column=0, row=1, pady=10)

        run_round(0)

    root.after(1000, start_game)
    root.mainloop()

game()
END
