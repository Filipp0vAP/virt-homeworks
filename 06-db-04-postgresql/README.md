# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

## Ответ
- \q
- \c
- \d
- \d+ tablename
- \q

---

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

## Ответ
```sql

test_database=#
test_database=# SELECT attname
test_database-# FROM pg_stats
test_database-# WHERE avg_width=(
test_database(#     SELECT max(avg_width)
test_database(#     FROM pg_stats
test_database(#     WHERE tablename='orders'
test_database(#     );
 attname
---------
 title
(1 row)
```

---

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

## Ответ

При изначальном проектировании таблиц можно было сделать ее секционированной, 
```sql
partition by range(price);
```
тогда не пришлось бы переименовывать исходную таблицу и переносить данные в новую.

Транзакция для разделения:
```sql
begin;
    CREATE TABLE orders_new (
            id integer NOT NULL,
            title varchar(80) NOT NULL,
            price integer);

    CREATE TABLE orders_new_1 (
        CHECK ( price > 499 )
    ) INHERITS (orders_new);

    CREATE TABLE orders_new_2 (
        CHECK ( price <= 499 )
    ) INHERITS (orders_new);


    CREATE RULE orders_insert_to_1 AS ON INSERT TO orders_new
    WHERE ( price > 499 )
    DO INSTEAD INSERT INTO orders_new_1 VALUES (NEW.*);

    CREATE RULE orders_insert_to_2 AS ON INSERT TO orders_new
    WHERE ( price <= 499 )
    DO INSTEAD INSERT INTO orders_new_2 VALUES (NEW.*);

    INSERT INTO orders_new (id, title, price) SELECT * FROM orders;
commit;

```

---

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

## Ответ

```bash
pg_dump -d test_database > ./dump.sql
```

Уникальность можно добавить, дописав в файл дампа запрос:
```sql
CREATE INDEX orders_new_lower_idx ON public.orders_new USING btree (lower((title)::text));

```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
