# Домашнее задание к занятию «Введение в микросервисы»

## Задача 1: Интернет Магазин

Руководство крупного интернет-магазина, у которого постоянно растёт пользовательская база и количество заказов, рассматривает возможность переделки своей внутренней   ИТ-системы на основе микросервисов. 

Вас пригласили в качестве консультанта для оценки целесообразности перехода на микросервисную архитектуру. 

Опишите, какие выгоды может получить компания от перехода на микросервисную архитектуру и какие проблемы нужно решить в первую очередь.

### Ответ:

#### Преимущества:

* Возможность использовать разные технологии

```
Микросервисная архитектура позволяет использовать подходящий инструмент для каждого типа задач, не
ограничиваясь определенным стеком технологий.
```

* Устойчивость к ошибкам
* Масштабируемость

```
Микросервисную систему можно масштабировать частями, предоставляя необходимые ресурсы только там, где
необходимо. 
```

* Простота развертывания

```
Можно развертывать каждый сервис независимо. Развертывание становиться чаще и надежнее. При возникновении
проблем легко откатить систему к изначальному состоянию. При таком подходе новая функциональность
попадает к пользователям гораздо быстрее.
```

* Простота замены

```
В случае необходимости можно переписать сервис на другом языке программирования или с использованием
другого стека технологий.
```

#### Сопутствующие проблемы

1. Проблемы разработки

* Совместимость API

```
Из-за большого количества изменений и частоты выкладки следует много внимания уделять обратной и прямой
совместимости API. Нельзя допускать чтобы релиз одного сервиса зависил от релиза другого или требовал
обновления клиента.
```

* Версионирование артефактов

```
Важно понимать какие версии каких сервисов обробатывают запросы пользователей и какие библиотеки
используются.
```

* Автоматизация сборки и тестирования

```
Необходимо автоматизировать рутинные операции. Это поможет сократить количество ошибок. Пайплайн сборки
должен предотвращать публикацию непроверенных артефактов.
```

* Документация

```
Необходимо иметь актуальную документацию о возможностях каждого сервиса и доступных методах API и правилах
его использования.
```

2. Проблемы эксплуатации

* Мониторинг

```
Необходимо следить за состоянием систем. Необходимы стандартизированные правила мониторинга за показателями
сервисов и ресурсов.
```

* Сбор логов

```
Необходимо организовать сбор логов со всех сервисов для анализа анцидентов. Важно настроить синхронизацию
времени между всеми сервисами.
```

* Управлние настройками

```
При увеличении количества приложений в разных средах управление настройками требует большой внимательности.
```
