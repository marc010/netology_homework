# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   
1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
    * Какая максимальная длина имени? 
    * Какому регулярному выражению должно подчиняться имя? 

Ответ:
1. [`resource`](https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L943), 
[`data_source`](https://github.com/hashicorp/terraform-provider-aws/blob/fbc1c405d771b831dfad7a3e5ab7532341aa1d75/internal/provider/provider.go#L419)
2. `aws_sqs_queue`
   * [`name` конфликтует с `name_prefix`](https://github.com/hashicorp/terraform-provider-aws/blob/fbc1c405d771b831dfad7a3e5ab7532341aa1d75/internal/service/sqs/queue.go#L88)
   * [Максимальная длина имени равна 80](https://github.com/hashicorp/terraform-provider-aws/blob/fbc1c405d771b831dfad7a3e5ab7532341aa1d75/internal/service/sqs/queue.go#L433)
   * Регулярное выражение для имени: [`^[a-zA-Z0-9_-]{1,80}$`](https://github.com/hashicorp/terraform-provider-aws/blob/fbc1c405d771b831dfad7a3e5ab7532341aa1d75/internal/service/sqs/queue.go#L433). 
Регулярное выражение для FIFO очереди: [`^[a-zA-Z0-9_-]{1,75}\.fifo$`](https://github.com/hashicorp/terraform-provider-aws/blob/fbc1c405d771b831dfad7a3e5ab7532341aa1d75/internal/service/sqs/queue.go#L431)