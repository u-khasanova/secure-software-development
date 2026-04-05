### 1. Критерии сравнения библиотек с точки зрения защищенности

#### Сводная таблица критериев

| № | Критерий | Источник | Метрика проверки |
|---|----------|----------|-----------------|
| 1 | Гигиена уязвимостей | OpenSSF:  vulnerability_report_response, vulnerabilities_fixed_60_days [https://www.bestpractices.dev/criteria] | SLA исправления уязвимостей не более 14 дней, отсутствие открытых уязвимостей средней и высокой критичности старше 60 дней |
| 2 | Проактивный анализ кода | OpenSSF: static_analysis, dynamic_analysis_unsafe [https://www.bestpractices.dev/criteria] | Интеграция SAST в CI, наличие фаззинга или тестирования невалидными входными данными для парсеров |
| 3 | Безопасность цепочки поставок | OpenSSF: delivery_mitm, no_leaked_credentials [https://www.bestpractices.dev/criteria]; OWASP Software Component Verification Standard [https://csrc.nist.gov/projects/ssdf] | Подписанный NuGet-пакет, минимальное количество транзитивных зависимостей, наличие автоматического сканирования уязвимостей зависимостей |
| 4 | Безопасные настройки по умолчанию | OWASP Input Validation Cheat Sheet [https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html]; Microsoft SDL Practices [https://www.microsoft.com/en-us/securityengineering/sdl/practices] | Отключено выполнение кода и загрузка внешних ресурсов по умолчанию, использование потокового API вместо полной загрузки файла в память |
| 5 | Контроль ресурсов и защита от отказа в обслуживании | OWASP Input Validation [https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html]; NIST SSDF PW.4 [https://csrc.nist.gov/projects/ssdf] | Возможность задания лимитов на размер входных данных, время обработки и количество извлекаемых метаданных; отказ от чтения всего файла в память |
| 6 | Минимизация поверхности атаки | Microsoft SDL: Require use of proven security features [https://www.microsoft.com/en-us/securityengineering/sdl/practices]; NIST SSDF PS.2 | Отсутствие функционала рендеринга, если он не требуется, минимальное использование небезопасного кода, отсутствие избыточных зависимостей |
| 7 | Качество тестирования | OpenSSF: test, test_continuous_integration [https://www.bestpractices.dev/criteria] | Покрытие автоматическими тестами не менее 70 процентов, наличие тестов на регрессию известных уязвимостей, блокировка слияния кода при падении тестов в CI |
| 8 | Прозрачность и документация | OpenSSF: documentation_basics, release_notes [https://www.bestpractices.dev/criteria] | Наличие раздела по безопасности в документации, описание параметров конфигурации для безопасного использования, упоминание исправленных уязвимостей в примечаниях к релизам |

### 2. Оценка выбранных библиотек по критериям защищенности

Проведена оценка библиотек MetadataExtractor, PdfPig и AngleSharp по установленным восьми критериям.

#### Сводная матрица оцеи

| № критерия | MetadataExtractor | PdfPig | AngleSharp |
|---|---|---|---|
| 1. Гигиена уязвимостей | Частично [Issue Tracker](https://github.com/drewnoakes/metadata-extractor-dotnet/issues) | Частично [Issue Tracker](https://github.com/UglyToad/PdfPig/issues) | Соответствует [Security Policy](https://github.com/AngleSharp/AngleSharp/security) |
| 2. Проактивный анализ | Не соответствует | Не соответствует | Не соответствует |
| 3. Цепочка поставок | [Соответствует](https://www.nuget.org/packages/MetadataExtractor/) | [Соответствует](https://www.nuget.org/packages/PdfPig/) | [Соответствует](https://www.nuget.org/packages/AngleSharp/) |
| 4. Безопасные умолчания | [Соответствует](https://github.com/drewnoakes/metadata-extractor-dotnet#usage) | [Соответствует](https://github.com/UglyToad/PdfPig/wiki/Quick-Start) | [Частично](https://anglesharp.github.io/docs/core/02-Options) |
| 5. Контроль ресурсов | [Частично](https://github.com/drewnoakes/metadata-extractor-dotnet/blob/main/MetadataExtractor/ImageMetadataReader.cs) | [Частично](https://github.com/UglyToad/PdfPig/blob/master/src/UglyToad.PdfPig/PdfDocument.cs) | [Частично](https://anglesharp.github.io/docs/core/02-Options) |
| 6. Поверхность атаки | [Соответствует; только парсинг метаданных](https://github.com/drewnoakes/metadata-extractor-dotnet) | [Соответствует; отсутствие функционала рендеринга](https://github.com/UglyToad/PdfPig) | [Частично; избыточен для метаданных](https://anglesharp.github.io/) |
| 7. Качество тестов | [Соответствует](https://github.com/drewnoakes/metadata-extractor-dotnet/tree/main/MetadataExtractor.Tests) | [Соответствует](https://github.com/UglyToad/PdfPig/tree/master/src/UglyToad.PdfPig.Tests) | [Соответствует](https://github.com/AngleSharp/AngleSharp/tree/main/src/AngleSharp.Core.Tests) |
| 8. Прозрачность | [Соответствует](https://github.com/drewnoakes/metadata-extractor-dotnet/releases) | [Соответствует](https://github.com/UglyToad/PdfPig/releases) | [Соответствует](https://github.com/AngleSharp/AngleSharp/blob/main/README.md) |

### 3. Правила безопасного кодирования

#### Правила для MetadataExtractor (JPEG, PNG)

| № | Правило | Пример кода |
|---|---------|-------------|
| 1 | Проверка размера потока перед парсингом | `if (stream.Length > 10_000_000) throw new ArgumentException("File too large");` |
| 2 | Обработка исключений без вывода внутренних деталей | `catch (ImageMetadataException) { logger.LogWarning("Invalid image format"); return null; }` |
| 3 | Отказ от парсинга пользовательских тегов (XMP) | При работе с `XmpDirectory` валидировать содержимое тегов на наличие скриптов |

#### Правила для PdfPig (PDF)

| № | Правило | Пример кода |
|---|---------|-------------|
| 1 | Проверка сигнатуры PDF перед открытием | `if (!stream.StartsWith("%PDF-")) throw new SecurityException("Invalid PDF signature");` |
| 2 | Открытие документа через `PdfDocument.Open(Stream, ParsingOptions)` с отключением опасных функций | `var options = new ParsingOptions { AllowUnsafeParsing = false }; using var doc = PdfDocument.Open(stream, options);` |
| 3 | Ограничение количества страниц для анализа | `if (doc.NumberOfPages > 100) throw new ArgumentException("Too many pages");` |
| 4 | Извлечение метаданных только из `document.Information` и `XmpMetadata`, игнорирование контента страниц | `var title = document.Information.Title; var xmp = document.TryGetXmpMetadata(out var xmpMeta);` |
| 5 | Запрет на выполнение JavaScript и загрузку внешних ресурсов | Убедиться, что `ParsingOptions.AllowUnsafeParsing = false` (по умолчанию) |
| 6 | Обработка `PdfPigException` без раскрытия стека вызовов | `catch (PdfPigException ex) { logger.LogError("PDF parse error: {Code}", ex.HResult); }` |


#### Правила для AngleSharp (SVG)

| № | Правило | Пример кода |
|---|---------|-------------|
| 1 | Настройка безопасного `XmlReader` перед парсингом | `var settings = new XmlReaderSettings { DtdProcessing = DtdProcessing.Prohibit, XmlResolver = null, MaxCharactersFromEntities = 1_000_000 };` |
| 2 | Отключение выполнения скриптов и загрузки внешних ресурсов в AngleSharp | `var config = Configuration.Default.WithoutScripting().WithoutCss(); var context = BrowsingContext.New(config);` |
| 3 | Ограничение размера входного потока | `if (stream.Length > 5_000_000) throw new ArgumentException("SVG too large");` |
| 4 | Извлечение метаданных только из разрешённых тегов (`<title>`, `<desc>`, `<metadata>`) | `var metadata = doc.QuerySelectorAll("title, desc, metadata").Select(e => e.TextContent);` |
| 5 | Обработка `AngleSharpException` без утечки деталей парсинга | `catch (AngleSharpException) { logger.LogWarning("Invalid SVG structure"); }` |


