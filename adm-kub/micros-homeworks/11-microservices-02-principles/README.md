
# Домашнее задание к занятию «Микросервисы: принципы»

Вы работаете в крупной компании, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps-специалисту необходимо выдвинуть предложение по организации инфраструктуры для разработки и эксплуатации.

## Задача 1: API Gateway 

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- маршрутизация запросов к нужному сервису на основе конфигурации,
- возможность проверки аутентификационной информации в запросах,
- обеспечение терминации HTTPS.

Обоснуйте свой выбор.

| Название                  | Маршрутизация | Аутентифмкация | Терминация HTTPS | 
|---------------------------|---------------|----------------|------------------|
| Azure API Management      | +             | +              | +                | 
| Amazon API Gateway        | +             | +              | +                |
| Oracle API Gateway        | +             | +              | +                |
| Google API Gateway        | +             | +              | +                |
| SberCloud API Gateway     | +             | +              | +                |
| Yandex API Gateway        | +             | +              | +                |
| F5 NGINX Plus             | +             | +              | +                |
| Kong API Gateway          | +             | +              | +                |
| Apache APISIX API Gateway | +             | +              | +                |
| Tyk API Gateway           | +             | +              | +                |
| KrakenD API Gateway       | +             | +              | +                |

В случае размещения проекта в облочной инфраструктуре имеет смысл использовать API Gateway предоставляемый
облочным провайдерам, где он будет размещен. Все расмотренные API Gateway сервисы обладают необходимым
функционалам. Из рассмотренных API Gateway я бы выбрал **KrakenD API Gateway**, поскольку он быстрее конкурентов
в работе, написан на GO, открытый и расширяемый.



## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:
- поддержка кластеризации для обеспечения надёжности,
- хранение сообщений на диске в процессе доставки,
- высокая скорость работы,
- поддержка различных форматов сообщений,
- разделение прав доступа к различным потокам сообщений,
- простота эксплуатации.

Обоснуйте свой выбор.

| Название     | Поддержка кластеризации | Хранение сообщений на диске | Скорость работы | Форматы сообщений           | Разделение прав доступа | Простота эксплуатации |
|--------------|-------------------------|-----------------------------|-----------------|-----------------------------|-------------------------|-----------------------|
| RabbitMQ     | +                       | +                           | высокая         | AMQP, MQTT, STOMP           | +                       | +                     |
| Apache Kafka | +                       | +                           | очень высокая   | бинарный                    | +                       | -                     |
| NATS         | +                       | -                           | высокая         | NATS                        | +                       | +                     |
| Redis        | +                       | -                           | очень высокая   | RESP                        | +                       | +                     |
| ActiveMQ     | +                       | +                           | средняя         | AMQP, MQTT, OpenWire, STOMP | +                       | +                     |
 
Выбор брокера сообщений будет зависеть от конкретных требований проекта, его масштаба и особенностей реализации.
Из рассмотренный брокеров сообщений я бы выбрал **RabbitMQ**, поскольку он имеет активное пользовательское
сообщество, что облегчает получение поддержки и решение проблем при эксплуатации, а также он обладает всем
необходимым функционалом.
