## 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.
   ### `git show aefea`
     hash: aefead2207ef7e2aa5dc81a34aedf0cad4c32545
     Коментарий: Update CHANGELOG.md

## 2. Какому тегу соответствует коммит `85024d3`?
   ### `git show 85024d3`
    commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
### `git show-ref --tags`
    Покажет соответствия всех тегов и коммитов
## 3. Сколько родителей у коммита `b8d720`? Напишите их хеши.
### `git show b8d720 --pretty=format:"%P"`
    56cd7859e05c36c06b56d013b55a252d0bb7e158
    9ea88f22fc6269854151c571162c5bcf958bee2b
## 4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.
### `git log  v0.12.23..v0.12.24 --pretty=format:"%H %s"`
    33ff1c03bb960b332be3af2e333462dde88b279e v0.12.24
    b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
    3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
    6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
    5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
    06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
    d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
    4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
    dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
    225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release
## 5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит так `func providerSource(...)` (вместо троеточего перечислены аргументы).
### `git log -S "func providerSource" --oneline`
#### Показывает коммиты, в которых указанная строка была добавлена или изменена

    5af1e6234a main: Honor explicit provider_installation CLI config when present
    8c928e8358 main: Consult local directories as potential mirrors of providers
#### Далее с помощью `git show <hash>` можно посмотреть в каком из этих коммитов файл был добавлен, а в каком изменен
    В коммите 5af1e6234a функция была изменена, а вот в коммите 8c928e8358 она была впревые добавлена 
## 6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.
### `git grep 'globalPluginDirs'`
#### Показывает файлы где встречается указаная строка
### `git log --oneline -L:'globalPluginDirs':plugins.go`
#### Показывает все коммиты для файла plugins.go, где функция `globalPluginDirs` была изменена
    commit 78b12205587fe839f10d946ea3fdc06719decb05
    commit 52dbf94834cb970b510f2fba853a5b49ad9b1a46
    commit 41ab0aef7a0fe030e84018973a64135b11abcd70
    commit 66ebff90cdfaa6938f26f908c7ebad8d547fea17
    commit 8364383c359a6b738a436d1b7745ccdce178df47
## 7. Кто автор функции `synchronizedWriters`?
### `git log -S 'func synchronizedWriters' --oneline --pretty=format:"%h %an %ae"`
    bdfea50cc8 James Bardin j.bardin@gmail.com
    5ac311e2a9 Martin Atkins mart@degeneration.co.uk
#### Показывает кто создал илм вносил изменения в эту функуию
#### Далее с помощью `git show <hash>` можно посмотреть кто создатель функции
### `git show 5ac311e2a9`
#### Здесь видно, что функция `synchronizedWriters` была добавлена Martin Atkins