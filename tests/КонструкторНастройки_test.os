#использовать "../"
#Использовать asserts
#Использовать logos
#Использовать tempfiles
#Использовать json
#Использовать yaml

Перем юТест;
Перем Лог;

Функция ПолучитьСписокТестов(Знач Тестирование) Экспорт

	юТест = Тестирование;

	ИменаТестов = Новый Массив;

	ИменаТестов.Добавить("ТестДолжен_ПроверитьЧтениеПараметровИзКонструктора");
	ИменаТестов.Добавить("ТестДолжен_ПроверитьУдалениеПоляИзКонструктора");
	ИменаТестов.Добавить("ТестДолжен_ПроверитьЧтениеПроизвольныхПолейКонструтора");
	ИменаТестов.Добавить("ТестДолжен_ПроверитьЗаполнениеОтсутствующихПараметров");
	ИменаТестов.Добавить("ТестДолжен_ПроверитьОтсутствиеДублированияПараметров");
	ИменаТестов.Добавить("ТестДолжен_ПроверитьНеСозданияПустыхПолей");
	// ИменаТестов.Добавить("ТестДолжен_ПроверитьПарсингМассивовОпций");

	Возврат ИменаТестов;

КонецФункции

Процедура ТестДолжен_ПроверитьЧтениеПараметровИзКонструктора() Экспорт
	
	МенеджерПараметров = Новый МенеджерПараметров();
	Конструктор = МенеджерПараметров.КонструкторПараметров();

	ПараметрОбъект = Конструктор.НовыеПараметры()
				.ПолеСтрока("Поле1")
				.ПолеСтрока("Поле2")
				;

	ДатаПроверки = ТекущаяДата();
	ПараметрСтруктура = Конструктор.НовыеПараметры()
				.ПолеСтрока("СтрокаСтруктуры")
				.ПолеДата("ДатаСтруктуры", ТекущаяДата())
				.ПолеДата("ТекущаяДата")
				.ПолеЧисло("ЧислоСтруктуры")
				.ПолеОбъект("Объект object", ПараметрОбъект)
				.ПолеМассив("МассивСтрок", Тип("Строка"))
				.ПолеМассив("МассивЧисел", Тип("Число"))
				.ПолеМассив("МассивДат", Тип("Дата"))
				.ПолеМассив("МассивОбъектов", ПараметрОбъект)
				;

	Конструктор.ПолеСтрока("Версия version")
				.ПолеСтрока("СтрокаНастройки")
				.ПолеДата("ДатаНастройки")
				.ПолеДата("ТекущаяДата", ДатаПроверки)
				.ПолеЧисло("ЧислоНастройки")
				.ПолеОбъект("ПараметрСтруктура struct", ПараметрСтруктура)
				.ПолеМассив("МассивОбъектов array-struct", ПараметрОбъект)
				.ПолеМассив("МассивСтрок", Тип("Строка"))
				.ПолеМассив("МассивЧисел", Тип("Число"))
				.ПолеМассив("МассивДат", Тип("Дата"))
				;
	
	СтруктураПараметров = Новый Структура("version, СтрокаНастройки, ДатаНастройки,
										 | ЧислоНастройки, МассивСтрок, МассивЧисел, ПараметрСтруктура, ПараметрСоответствие", 
		"1.0",
		"ПростоСтрока", 
		Дата(2017, 1, 1),
		10, 
		ПолучитьНовыйМассив("Элемент1,Элемент2,Элемент3"),
		ПолучитьНовыйМассив("1,2,3"),
		Новый Структура("СтрокаСтруктуры, ЧислоСтруктуры, МассивСтрок, Объект, Соответствие", 
			"ПростоСтрока", 
			10, 
			ПолучитьНовыйМассив("Элемент1,Элемент2,Элемент3"),
			Новый Структура("Поле1, Поле2", "ЗначениеСтруктуры", "ЗначениеСтруктуры2"),
			ПолучитьСоответствие("КлючВнутри1, КлючВнутри2", "Значение1, Значение2")
			), 
		ПолучитьСоответствие("Ключ1, Ключ2", "Значение1, Значение2")
	);

	ПарсерJSON = Новый ПарсерJSON;
	ТекстФайлаПроверки = ПарсерJSON.ЗаписатьJSON(СтруктураПараметров);

	ТестовыйФайл = ПодготовитьТестовыйФайл(ТекстФайлаПроверки);

	ТестовоеИмя = "config";
	ТестовоеРасширение = ".json";

	ВременныйКаталог = ВременныеФайлы.СоздатьКаталог();
	КопироватьФайл(ТестовыйФайл, ОбъединитьПути(ВременныйКаталог, ТестовоеИмя + ТестовоеРасширение));

	МенеджерПараметров.АвтоНастройка(ТестовоеИмя);
	НастройкаПоискаФайла = МенеджерПараметров.НастройкаПоискаФайла();
	НастройкаПоискаФайла.ДобавитьКаталогПоиска(ВременныйКаталог);
	МенеджерПараметров.Прочитать();

	ПроверитьРезультат(СтруктураПараметров.version, МенеджерПараметров.Параметр("Версия"));
	ПроверитьРезультат(СтруктураПараметров.СтрокаНастройки, МенеджерПараметров.Параметр("СтрокаНастройки"));
	ПроверитьРезультат(СтруктураПараметров.ДатаНастройки, МенеджерПараметров.Параметр("ДатаНастройки"));
	ПроверитьРезультат(ДатаПроверки, МенеджерПараметров.Параметр("ТекущаяДата"));
	ПроверитьРезультат(СтруктураПараметров.ЧислоНастройки, МенеджерПараметров.Параметр("ЧислоНастройки"));
	ПроверитьРезультат(СтруктураПараметров.ПараметрСтруктура.СтрокаСтруктуры, МенеджерПараметров.Параметр("ПараметрСтруктура.СтрокаСтруктуры"));
	ПроверитьРезультат(СтруктураПараметров.ПараметрСтруктура.ЧислоСтруктуры, МенеджерПараметров.Параметр("ПараметрСтруктура.ЧислоСтруктуры"));
	ПроверитьРезультат(СтруктураПараметров.ДатаНастройки, МенеджерПараметров.Параметр("ДатаНастройки"));
	ПроверитьРезультат(Тип("Массив"), ТипЗнч(МенеджерПараметров.Параметр("ПараметрСтруктура.МассивСтрок")));
	ПроверитьРезультат(3, МенеджерПараметров.Параметр("ПараметрСтруктура.МассивСтрок").Количество());
	ПроверитьРезультат("Элемент1", МенеджерПараметров.Параметр("ПараметрСтруктура.МассивСтрок")[0]);
	ПроверитьРезультат("Элемент2", МенеджерПараметров.Параметр("ПараметрСтруктура.МассивСтрок")[1]);
	ПроверитьРезультат("Элемент3", МенеджерПараметров.Параметр("ПараметрСтруктура.МассивСтрок")[2]);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьУдалениеПоляИзКонструктора() Экспорт

	КонструкторПараметров = Новый КонструкторПараметров();
	КонструкторПараметров.ПолеСтрока("Поле1 fiels-1")
				.ПолеСтрока("Поле2 fiels-2")
				;
	КонструкторПараметров.УдалитьПоле("Поле1")
				.УдалитьПоле("fiels-2")
				;

	ИндексПолей = КонструкторПараметров.ПолучитьИндексПолей();

	Ожидаем.Что(ИндексПолей.Количество(), "Индекс полей должен быть пустым").Равно(0);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЗаполнениеОтсутствующихПараметров() Экспорт


	СтруктураПараметров = Новый Соответствие();
	СтруктураПараметров.Вставить("--custom-feild", "ПроизвольноеПоле");
	СтруктураПараметров.Вставить("Поле", "ЗаданноеПоле");
	
	МенеджерПараметров = Новый МенеджерПараметров();
	Конструктор = МенеджерПараметров.КонструкторПараметров();
	Конструктор.ПолеСтрока("Поле");
	
	ПараметрСоответствие = Конструктор.НовыеПараметры();
	ПараметрСоответствие.ПолеСтрока("Ключ1")
				.ПолеСтрока("Ключ2")
				;

	Конструктор.ПолеОбъект("ОтсутствующееПоле", ПараметрСоответствие);

	Конструктор.ИзСоответствия(СтруктураПараметров);
	СтруктураПроверки = Конструктор.ВСтруктуру();
	Ожидаем.Что(СтруктураПроверки.Свойство("ОтсутствующееПоле"), "Поле должно присутствовать").Равно(Истина);
	ПроверитьРезультат(СтруктураПараметров["Поле"], СтруктураПроверки["Поле"]);

КонецПроцедуры


Процедура ТестДолжен_ПроверитьЧтениеПроизвольныхПолейКонструтора() Экспорт
	
	СтруктураПараметров = Новый Соответствие();
	СтруктураПараметров.Вставить("--custom-feild", "ПроизвольноеПоле");
	СтруктураПараметров.Вставить("Поле", "ЗаданноеПоле");
	
	ПарсерJSON = Новый ПарсерJSON;
	ТекстФайлаПроверки = ПарсерJSON.ЗаписатьJSON(СтруктураПараметров);

	ТестовыйФайл = ПодготовитьТестовыйФайл(ТекстФайлаПроверки);

	ТестовоеИмя = "config";
	ТестовоеРасширение = ".json";

	ПарсерJSON = Новый ПарсерJSON;
	ТекстФайлаПроверки = ПарсерJSON.ЗаписатьJSON(СтруктураПараметров);

	ТестовыйФайл = ПодготовитьТестовыйФайл(ТекстФайлаПроверки);
	
	ВременныйКаталог = ВременныеФайлы.СоздатьКаталог();
	КопироватьФайл(ТестовыйФайл, ОбъединитьПути(ВременныйКаталог, ТестовоеИмя + ТестовоеРасширение));

	МенеджерПараметров = Новый МенеджерПараметров();
	Конструктор = МенеджерПараметров.КонструкторПараметров();
	Конструктор.ПолеСтрока("Поле")
				.ПроизвольныеПоля();
	
	МенеджерПараметров.АвтоНастройка(ТестовоеИмя);
	НастройкаПоискаФайла = МенеджерПараметров.НастройкаПоискаФайла();
	НастройкаПоискаФайла.ДобавитьКаталогПоиска(ВременныйКаталог);
	МенеджерПараметров.Прочитать();

	ПроверитьРезультат(СтруктураПараметров["--custom-feild"], МенеджерПараметров.Параметр("--custom-feild"));
	ПроверитьРезультат(СтруктураПараметров["Поле"], МенеджерПараметров.Параметр("Поле"));
	
	ВременныеФайлы.УдалитьФайл(ВременныйКаталог);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьНеСозданияПустыхПолей() Экспорт
	
	СтруктураПараметров = Новый Соответствие();
	СтруктураПараметров.Вставить("--custom-feild", "ПроизвольноеПоле");
	СтруктураПараметров.Вставить("Поле", "ЗаданноеПоле");
	СтруктураПараметров.Вставить("ПолеОбъект3", Новый Соответствие());
	
	МенеджерПараметров = Новый МенеджерПараметров();
	Конструктор = МенеджерПараметров.КонструкторПараметров();
	Конструктор.ПолеСтрока("Поле");
	
	ПараметрСоответствие = Конструктор.НовыеПараметры();
	ПараметрСоответствие.ПолеСтрока("Ключ1")
				.ПолеСтрока("Ключ2")
				;

	Конструктор.ПолеОбъект("ПолеОбъект1", ПараметрСоответствие, Ложь);
	Конструктор.ПолеОбъект("ПолеОбъект2", ПараметрСоответствие);
	Конструктор.ПолеОбъект("ПолеОбъект3", ПараметрСоответствие, Ложь);

	Конструктор.ИзСоответствия(СтруктураПараметров);
	СтруктураПроверки = Конструктор.ВСтруктуру();
	Ожидаем.Что(СтруктураПроверки.Свойство("ПолеОбъект1"), "Поле должно отсутствовать").Равно(Ложь);
	Ожидаем.Что(СтруктураПроверки.Свойство("ПолеОбъект2"), "Поле должно присутствовать").Равно(Истина);
	Ожидаем.Что(СтруктураПроверки.Свойство("ПолеОбъект3"), "Поле должно присутствовать").Равно(Истина);
	ПроверитьРезультат(СтруктураПараметров["Поле"], СтруктураПроверки["Поле"]);

КонецПроцедуры


Процедура ТестДолжен_ПроверитьОтсутствиеДублированияПараметров() Экспорт
	
	Контакт = Новый КонструкторПараметров();
	Контакт.ПолеСтрока("email")
			.ПолеСтрока("tel")
	;
	
	Адрес = Новый КонструкторПараметров();
	Адрес.ПолеСтрока("address")
			.ПолеОбъект("contact", Контакт)
	;


	КонструкторПараметров = Новый КонструкторПараметров();
	КонструкторПараметров.ПолеОбъект("owner", Адрес)
					.ПолеОбъект("admin", Адрес)
					.ПолеОбъект("person", Адрес)
	;

	ТестовыйФайл = "./tests/fixtures/test-config.yaml";

	ЧтениеТекста = Новый ЧтениеТекста();
	ЧтениеТекста.Открыть(ТестовыйФайл);
	ТекстФайла = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();


	ПарсерYAML = Новый ПарсерYAML;
	РезультатЧтения = ПарсерYAML.ПрочитатьYaml(ТекстФайла);

	Сообщить(ТекстФайла);

	КонструкторПараметров.ИзСоответствия(РезультатЧтения);

	СтруктураРезультата = КонструкторПараметров.ВСтруктуру();

	Утверждения.ПроверитьРавенство(СтруктураРезультата.owner.contact.email, "mail.ru", "Результат должен совпадать с ожиданиями.");
	Утверждения.ПроверитьРавенство(СтруктураРезультата.owner.contact.tel, "77777777", "Результат должен совпадать с ожиданиями.");
	Утверждения.ПроверитьРавенство(СтруктураРезультата.owner.address, "", "Результат должен совпадать с ожиданиями.");
	Утверждения.ПроверитьНеРавенство(СтруктураРезультата.owner.address, "home", "Результат не должен совпадать с ожиданиями.");
	
	Утверждения.ПроверитьРавенство(СтруктураРезультата.admin.contact.email, "admin.ru", "Результат должен совпадать с ожиданиями.");
	Утверждения.ПроверитьНеРавенство(СтруктураРезультата.person.contact.email, "mail.ru", "Результат должен совпадать с ожиданиями.");
	Утверждения.ПроверитьНеРавенство(СтруктураРезультата.person.contact.email, "admin.ru", "Результат должен совпадать с ожиданиями.");
	Утверждения.ПроверитьРавенство(СтруктураРезультата.person.contact.email, "", "Результат должен совпадать с ожиданиями.");
	Утверждения.ПроверитьРавенство(СтруктураРезультата.owner.contact.email, "mail.ru", "Результат должен совпадать с ожиданиями.");

КонецПроцедуры

Процедура ПроверитьРезультат(Значение1, Значение2)
	Утверждения.ПроверитьРавенство(Значение1, Значение2, "Результат должен совпадать с ожиданиями.");
КонецПроцедуры

Функция ПодготовитьТестовыйФайл(Знач ТестФайла)

	ТестовыйФайл = ВременныеФайлы.НовоеИмяФайла("json");
	
	ЗаписьТекста = Новый ЗаписьТекста;
	ЗаписьТекста.Открыть(ТестовыйФайл);
	ЗаписьТекста.ЗаписатьСтроку(ТестФайла);
	ЗаписьТекста.Закрыть();

	Возврат ТестовыйФайл;

КонецФункции

Функция ПолучитьНовыйМассив(ЗначенияМассив)

	Массив = Новый Массив();

	МассивЗначений = СтрРазделить(ЗначенияМассив, ", ");

	Для ИндексКлюча = 0 По МассивЗначений.ВГраница() Цикл
		
		Массив.Добавить(МассивЗначений[ИндексКлюча]);

	КонецЦикла;

	Возврат Массив;

КонецФункции

Функция ПолучитьСоответствие(Ключи, Значения)

	Соответствие = Новый Соответствие();

	МассивКлючей = СтрРазделить(Ключи, ", ");
	МассивЗначений = СтрРазделить(Значения, ", ");

	Для ИндексКлюча = 0 По МассивКлючей.ВГраница() Цикл
		
		Соответствие.Вставить(МассивКлючей[ИндексКлюча], МассивЗначений[ИндексКлюча]);

	КонецЦикла;

	Возврат Соответствие;

КонецФункции

Лог = Логирование.ПолучитьЛог("oscript.lib.configor.constructor");
Лог.УстановитьУровень(УровниЛога.Отладка);

ЛогПровайдера = Логирование.ПолучитьЛог("oscript.lib.configor.provider-json");
// ЛогПровайдера.УстановитьУровень(УровниЛога.Отладка);

ТестДолжен_ПроверитьЧтениеПараметровИзКонструктора();