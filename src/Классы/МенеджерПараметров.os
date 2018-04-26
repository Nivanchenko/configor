#Использовать asserts
#Использовать logos
#Использовать tempfiles
#Использовать reflector
#Использовать fluent
#Использовать notify

Перем ЧтениеПараметровВыполнено; // булево - флаг, что чтение выполнено

Перем ИндексПараметров; // Соответствие - плоский индекс всех параметров
Перем ПрочитанныеПараметры; // Соответствие - результат чтения из провайдеров

Перем КлассПараметров; // Произвольный класс обеспечивающий: Функция Параметры() Экспорт, Процедура УстановитьПараметры(НовыеПараметры) Экспорт

Перем ПровайдерыПараметров; // Соответствие

Перем НастройкаФайловогоПровайдера; // Класс НастройкиФайловогоПровайдера

Перем ИнтерфейсПриемника; // Класс ИнтерфейсОбъекта

Перем ВнутреннийКонструкторПараметров; // Класс КонструкторПараметров
Перем ИспользуетсяКонструкторПараметров; // булево

Перем Лог;

#Область Экспортных_процедур

// Получает и возвращает значение из индекса параметров
//
// Параметры:
//   ИмяПараметра        - Строка - имя параметра
//                                  допустимо указание пути к параметру через точку (например, "config.server.protocol")
//   ЗначениеПоУмолчанию - Произвольный - возвращаемое значение в случае отсутствия параметра после чтения
//
// Возвращаемое значение:
//	Строка, Число, Булево, Массив, Соответствие, Неопределено - значение параметра
//
Функция Параметр(Знач ИмяПараметра, Знач ЗначениеПоУмолчанию = Неопределено) Экспорт

	ЗначениеИзИндекса = ИндексПараметров[ИмяПараметра];

	Если НЕ ЗначениеИзИндекса = Неопределено Тогда
		Возврат ЗначениеИзИндекса;
	КонецЕсли;

	Возврат ЗначениеПоУмолчанию;

КонецФункции

// Возвращает признак выполнения чтения параметров
//
// Возвращаемое значение:
//	Булево - признак выполнения чтения параметров
//
Функция ЧтениеВыполнено() Экспорт
	Возврат ЧтениеПараметровВыполнено;
КонецФункции

// Выполняет чтения параметров из доступных провайдеров
//
Процедура Прочитать() Экспорт

	ИндексПараметров.Очистить();
	ПрочитанныеПараметры.Очистить();
	ВыполнитьЧтениеПровайдеров();

	Лог.Отладка("ПрочитанныеПараметры количество <%1>", ПрочитанныеПараметры.Количество());

	Если ИспользуетсяКонструкторПараметров Тогда
	
		ВнутреннийКонструкторПараметров.ИзСоответствия(ПрочитанныеПараметры);

		ПараметрыДляИндекса = ВнутреннийКонструкторПараметров.ВСоответствие();

		Если Не КлассПараметров = Неопределено Тогда
			ВыгрузитьПараметрыВКлассПриемник();
		КонецЕсли;
	
	Иначе
		ПараметрыДляИндекса = ПрочитанныеПараметры;
	КонецЕсли;

	ОбновитьИндексПараметров(ПараметрыДляИндекса);

	ПоказатьПараметрыВРежимеОтладки(ПараметрыДляИндекса);

	ЧтениеПараметровВыполнено = ИндексПараметров.Количество() > 0;
	
КонецПроцедуры

// Устанавливает путь к файлу параметров
//
// Параметры:
//   ПутьКФайлу - Строка - полный путь к файлу параметров
//
Процедура УстановитьФайлПараметров(Знач ПутьКФайлу) Экспорт

	НастройкаФайловогоПровайдера = ПолучитьНастройкуФайловогоПровайдера();

	НастройкаФайловогоПровайдера.УстановитьФайлПараметров(ПутьКФайлу);
	
КонецПроцедуры

// Добавляет в таблицу провайдеров произвольный класс-провайдер
//
// Параметры:
//   КлассОбъект             - Объект - класс провайдера или имя класса
//   Приоритет               - Число        - Числовой приоритет выполнения провайдеры (по умолчанию 99)
//
Процедура ДобавитьПровайдерПараметров(Знач КлассОбъект,
									Знач Приоритет = Неопределено) Экспорт

	ДобавляемыйПровайдерПараметров = Новый ПровайдерПараметров(КлассОбъект);

	Если Не Приоритет = Неопределено Тогда
		ДобавляемыйПровайдерПараметров.УстановитьПриоритет(Приоритет);
	КонецЕсли;

	ПровайдерыПараметров.Вставить(ДобавляемыйПровайдерПараметров.Идентификатор, ДобавляемыйПровайдерПараметров);

КонецПроцедуры

// Отключает и удаляет провайдера из таблицы провайдеров
//
// Параметры:
//   ИдентификаторПровайдера - Строка - короткий идентификатор провайдера (например, json)
//
Процедура ОтключитьПровайдер(Знач ИдентификаторПровайдера) Экспорт

	Провайдер = ПровайдерыПараметров[ИдентификаторПровайдера];

	Если Провайдер = Неопределено Тогда
		Лог.Отладка("Провайдер с идентификатором <%1> не найден", ИдентификаторПровайдера);
		Возврат;
	КонецЕсли;

	Провайдер.Отключить();

КонецПроцедуры

// Возвращает объект настройки поиска файлов
//
//  Возвращаемое значение:
//   Объект.НастройкаФайловогоПровайдера - внутренний класс по настройке файловых провайдеров
//
Функция НастройкаПоискаФайла() Экспорт
	Возврат ПолучитьНастройкуФайловогоПровайдера();
КонецФункции

// Добавляет встроенный провайдер JSON
//
// Параметры:
//   Приоритет               - Число  - Числовой приоритет выполнения провайдеры (по умолчанию 0)
//
Процедура ИспользоватьПровайдерJSON(Знач Приоритет = 0) Экспорт

	ДобавитьПровайдерПараметров(Новый ПровайдерПараметровJSON, Приоритет);

КонецПроцедуры

// Добавляет встроенный провайдер YAML
//
// Параметры:
//   Приоритет               - Число  - Числовой приоритет выполнения провайдеры (по умолчанию 0)
//
Процедура ИспользоватьПровайдерYAML(Знач Приоритет = 0) Экспорт

	ДобавитьПровайдерПараметров(Новый ПровайдерПараметровYAML, Приоритет);

КонецПроцедуры

// Производит автоматическую настройку провайдеров
//
// Параметры:
//   НаименованиеФайла - Строка - Наименование файла параметров
//   ВложенныйПодкаталог - Строка - Дополнительный каталог, для стандартных путей
//   ИдентификаторыПровайдеров - Строка - Идентификаторы встроенных параметров, по умолчанию <yaml json>
//
Процедура АвтоНастройка(Знач НаименованиеФайла,
	Знач ВложенныйПодкаталог = Неопределено,
	Знач ИдентификаторыПровайдеров = "yaml json") Экспорт

	НастройкаФайловогоПровайдера = ПолучитьНастройкуФайловогоПровайдера();

	НастройкаФайловогоПровайдера.УстановитьИмяФайла(НаименованиеФайла);
	НастройкаФайловогоПровайдера.УстановитьСтандартныеКаталогиПоиска(ВложенныйПодкаталог);

	МассивИдентификаторовПровайдеров = СтрРазделить(Врег(ИдентификаторыПровайдеров), " ");

	ПровайдерYAML = МассивИдентификаторовПровайдеров.Найти("YAML");
	Если НЕ ПровайдерYAML = Неопределено Тогда
		ИспользоватьПровайдерYAML(ПровайдерYAML);
	КонецЕсли;

	ПровайдерJSON = МассивИдентификаторовПровайдеров.Найти("JSON");
	Если НЕ ПровайдерJSON = Неопределено Тогда
		ИспользоватьПровайдерJSON(ПровайдерJSON);
	КонецЕсли;

КонецПроцедуры

// Устанавливает класс параметров для описания конструктора параметров и установки результатов чтения
//
// Параметры:
//   КлассОбъект - Объект - произвольный класс, реализующий ряд экспортных процедур
//
Процедура УстановитьКлассПараметров(КлассОбъект) Экспорт

	Если Не ИспользуетсяКонструкторПараметров Тогда
		Возврат;
	КонецЕсли;

	КлассПараметров = КлассОбъект;

	ИнтерфейсРеализован(ИнтерфейсПриемника, КлассОбъект, Истина);

	ВнутреннийКонструкторПараметров.ИзКласса(КлассОбъект);
	
КонецПроцедуры

// Создает, определяет и возвращает новый внутренний конструктор параметров 
//
// Параметры:
//   КлассОбъект - Объект - Класс объект реализующий интерфейс конструктора параметров
//
//  Возвращаемое значение:
//   Объект.КонструкторПараметров - ссылка на новый элемент класса <КонструкторПараметров>
//
Функция КонструкторПараметров(КлассОбъект = Неопределено) Экспорт
	
	ВнутреннийКонструкторПараметров = ПолучитьКонструкторПараметров();

	ИспользуетсяКонструкторПараметров = Истина;

	Если ЗначениеЗаполнено(КлассОбъект) 
		И ИнтерфейсРеализован(ИнтерфейсПриемника, КлассОбъект, Истина) Тогда
		
		УстановитьКлассПараметров(КлассОбъект);
	
	КонецЕсли;

	Возврат ВнутреннийКонструкторПараметров;
	
КонецФункции

// Создает и возвращает новый конструктор параметров 
//
// Параметры:
//   КлассОбъект - Объект - Класс объект реализующий интерфейс конструктора параметров
//
//  Возвращаемое значение:
//   Объект.КонструкторПараметров - ссылка на новый элемент класса <КонструкторПараметров>
//
Функция НовыйКонструкторПараметров(КлассОбъект = Неопределено) Экспорт

	КонструкторПараметров = ПолучитьКонструкторПараметров();

	Если ЗначениеЗаполнено(КлассОбъект) Тогда
		
		КонструкторПараметров.ИзКласса(КлассОбъект);

	КонецЕсли;

	Возврат КонструкторПараметров;
	
КонецФункции

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

Функция ПолучитьКонструкторПараметров()
	
	ИндексПараметровКонструктора = Новый Соответствие;

	Конструктор = Новый КонструкторПараметров(ИндексПараметровКонструктора, "ОсновнаяНастройка");

	Возврат Конструктор;

КонецФункции

Процедура ВыполнитьЧтениеПровайдеров()

	КоллекцияПровайдеров = Новый ПроцессорКоллекций;
	КоллекцияПровайдеров.УстановитьКоллекцию(ПровайдерыПараметров);

	КоличествоПровайдеров = КоллекцияПровайдеров
			.Сортировать("Результат = Элемент1.Значение.Приоритет > Элемент2.Значение.Приоритет")
			.Фильтровать("Результат = Элемент.Значение.Включен")
			.Количество();

	Если КоличествоПровайдеров = 0 Тогда
		Возврат;
	Иначе

		ПроцедураЧтенияПровайдера = Новый ОписаниеОповещения("ОбработчикВыполненияЧтениеПровайдера", ЭтотОбъект);
		КоллекцияПровайдеров.ДляКаждого(ПроцедураЧтенияПровайдера);

	КонецЕсли;
	
КонецПроцедуры

// Обработчик выполнения чтения провайдера
//
// Параметры:
//   Результат - КлючЗначение - Элемент индекса провайдеров
//   ДополнительныеПараметры - Структура - дополнительная структура
//
Процедура ОбработчикВыполненияЧтениеПровайдера(Результат, ДополнительныеПараметры) Экспорт

	Провайдер = ДополнительныеПараметры.Элемент.Значение;

	ВыполнитьЧтениеДляПровайдера(Провайдер);

КонецПроцедуры

Процедура ВыполнитьЧтениеДляПровайдера(КлассПровайдера)

	ИдентификаторПровайдера = КлассПровайдера.Идентификатор;
	
	ПараметрыПровайдера = Новый Структура;
	Если КлассПровайдера.ЭтоФайловыйПровайдер() Тогда
		ПараметрыПровайдера = ПолучитьНастройкуФайловогоПровайдера().ПолучитьНастройки();
	КонецЕсли;

	Попытка
		ПрочитанныеПараметрыПровайдера = КлассПровайдера.ПрочитатьПараметры(ПараметрыПровайдера);
	Исключение
		Лог.КритичнаяОшибка("Не удалось прочитать параметры используя провайдер <%1>. По причине: %2",
							ИдентификаторПровайдера,
							ОписаниеОшибки());
		Возврат;
	КонецПопытки;

	Лог.Отладка("Провайдер <%1> вернул количество параметров <%2>", 
				ИдентификаторПровайдера,
				ПрочитанныеПараметрыПровайдера.Количество());
	
	ОбъединитьПрочитанныеПараметры(ПрочитанныеПараметрыПровайдера, ПрочитанныеПараметры);

КонецПроцедуры

Процедура ОбъединитьПрочитанныеПараметры(Источник, Приемник)

	Для каждого КлючЗначение Из Источник Цикл

		КлючИсточника = КлючЗначение.Ключ;
		ЗначениеИсточника = КлючЗначение.Значение;

		ЗначениеПриемника = Приемник[КлючИсточника];
		
		Если ЗначениеПриемника = Неопределено Тогда
			Приемник.Вставить(КлючИсточника, ЗначениеИсточника);
			Продолжить;
		КонецЕсли;

		Если Не ТипЗнч(ЗначениеИсточника) = ТипЗнч(ЗначениеПриемника) Тогда
			Продолжить;
		КонецЕсли;

		Если ТипЗнч(ЗначениеИсточника) = Тип("Соответствие") Тогда

			ОбъединитьПрочитанныеПараметры(ЗначениеИсточника, ЗначениеПриемника);

		ИначеЕсли ТипЗнч(ЗначениеИсточника) = Тип("Массив") Тогда

			Для каждого ЭлементМассива Из ЗначениеИсточника Цикл

				Если ТипЗнч(ЭлементМассива) = Тип("Строка") Тогда

					НайденныйЭлемент = ЗначениеПриемника.Найти(ЭлементМассива);

					Если НайденныйЭлемент = Неопределено Тогда
						ЗначениеПриемника.Добавить(ЭлементМассива);
						Продолжить;
					КонецЕсли;

				КонецЕсли;

				ЗначениеПриемника.Добавить(ЭлементМассива);

			КонецЦикла;

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура ОбновитьИндексПараметров(Знач ПараметрыДляИндекса)

	// Рекурсивный вызов для входящих параметров
	ДобавитьЗначениеПараметра("", ПараметрыДляИндекса);

КонецПроцедуры

Функция ЭтоМассив(Знач Значение)
	Возврат ТипЗнч(Значение) = Тип("Массив");
КонецФункции

Функция ЭтоСоответствие(Знач Значение)
	Возврат ТипЗнч(Значение) = Тип("Соответствие");
КонецФункции

Функция ЭтоСтруктура(Знач Значение)
	Возврат ТипЗнч(Значение) = Тип("Структура");
КонецФункции

Процедура ДобавитьПараметрВИндекс(Знач ИмяПараметра, Знач ЗначениеПараметра)

	// Вставляем все значение целиком
	// Для  массивов и соответствий сразу
	Если Не ПустаяСтрока(ИмяПараметра) Тогда
		Лог.Отладка("Добавляю параметр <%1> со значением <%2> в индекс", ИмяПараметра, ЗначениеПараметра);
		ИндексПараметров.Вставить(ИмяПараметра, ЗначениеПараметра);
	КонецЕсли;

	// Рекурсивное заполнение значения параметра
	ДобавитьЗначениеПараметра(ИмяПараметра, ЗначениеПараметра);

КонецПроцедуры

Процедура ДобавитьЗначениеПараметра(Знач ИмяПараметра, Знач ЗначениеПараметра)

	Если ЭтоМассив(ЗначениеПараметра) Тогда
		ДобавитьПараметрМассивВИндекс(ЗначениеПараметра, ИмяПараметра);
	ИначеЕсли ЭтоСоответствие(ЗначениеПараметра) Тогда
		ДобавитьСоответствиеВИндекс(ЗначениеПараметра, ИмяПараметра);
	ИначеЕсли ЭтоСтруктура(ЗначениеПараметра) Тогда
		ДобавитьСоответствиеВИндекс(ЗначениеПараметра, ИмяПараметра);
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьПараметрМассивВИндекс(Знач МассивЗначений, Знач ИмяРодителя = "")

	Лог.Отладка("Обрабатываю массив значений <%1> ", ИмяРодителя);

	ШаблонИмениПараметра = "%1";

	Если Не ПустаяСтрока(ИмяРодителя) Тогда
		ШаблонИмениПараметра = ИмяРодителя + ".%1";
	КонецЕсли;

	Для ИндексЗначения = 0 По МассивЗначений.ВГраница() Цикл

		ИмяПараметра = СтрШаблон(ШаблонИмениПараметра, ИндексЗначения);
		ДобавитьПараметрВИндекс(ИмяПараметра, МассивЗначений[ИндексЗначения]);

	КонецЦикла;

КонецПроцедуры

Процедура ДобавитьСоответствиеВИндекс(Знач ВходящиеПараметры, Знач ИмяРодителя = "")

	Лог.Отладка("Обрабатываю соответствие значений <%1> ", ИмяРодителя);

	ШаблонИмениПараметра = "%1";

	Если Не ПустаяСтрока(ИмяРодителя) Тогда
		ШаблонИмениПараметра = ИмяРодителя + ".%1";
	КонецЕсли;

	Для каждого КлючЗначение Из ВходящиеПараметры Цикл

		Лог.Отладка("Обрабатываю соответствие ключ <%1> ", КлючЗначение.Ключ);

		ИмяПараметра = СтрШаблон(ШаблонИмениПараметра, КлючЗначение.Ключ);
		ЗначениеПараметра = КлючЗначение.Значение;

		ДобавитьПараметрВИндекс(ИмяПараметра, ЗначениеПараметра);

	КонецЦикла;

КонецПроцедуры

Процедура ВыгрузитьПараметрыВКлассПриемник()

	СтруктураПараметров = ВнутреннийКонструкторПараметров.ВСтруктуру();
	КлассПараметров.УстановитьПараметры(СтруктураПараметров);

КонецПроцедуры

Процедура ПоказатьПараметрыВРежимеОтладки(ЗначенияПараметров, Знач Родитель = "")
	Если Родитель = "" Тогда
		Лог.Отладка("	Тип параметров %1", ТипЗнч(ЗначенияПараметров));
	КонецЕсли;
	Если ЗначенияПараметров.Количество() = 0 Тогда
		Лог.Отладка("	Коллекция параметров пуста!");
	КонецЕсли;
	Для каждого Элемент Из ЗначенияПараметров Цикл
		ПредставлениеКлюча = Элемент.Ключ;
		Если Не ПустаяСтрока(Родитель) Тогда
			ПредставлениеКлюча  = СтрШаблон("%1.%2", Родитель, ПредставлениеКлюча);
		КонецЕсли;
		Лог.Отладка("	Получен параметр <%1> = <%2>", ПредставлениеКлюча, Элемент.Значение);
		Если ТипЗнч(Элемент.Значение) = Тип("Соответствие")
			ИЛИ ТипЗнч(Элемент.Значение) = Тип("Структура")  Тогда
			ПоказатьПараметрыВРежимеОтладки(Элемент.Значение, ПредставлениеКлюча);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьНастройкуФайловогоПровайдера()

	Если НастройкаФайловогоПровайдера = Неопределено Тогда
		 НастройкаФайловогоПровайдера = Новый НастройкиФайловогоПровайдера;
	КонецЕсли;

	Возврат НастройкаФайловогоПровайдера;

КонецФункции

#КонецОбласти

#Область Инициализация

Процедура ПриСозданииОбъекта()

	ИндексПараметров = Новый Соответствие;
	ПрочитанныеПараметры = Новый Соответствие;
	ПровайдерыПараметров = Новый Соответствие;
	ЧтениеПараметровВыполнено = Ложь;

	ИнтерфейсПриемника = Новый ИнтерфейсОбъекта;
	ИнтерфейсПриемника.П("УстановитьПараметры", 1);
	ИнтерфейсПриемника.Ф("ОписаниеПараметров", 1);

	ВнутреннийКонструкторПараметров = Неопределено;
	ИспользуетсяКонструкторПараметров = Ложь;

КонецПроцедуры

Функция ИнтерфейсРеализован(Интерфейс, КлассОбъект, ВыдатьОшибку = Ложь)

	РефлекторОбъекта = Новый РефлекторОбъекта(КлассОбъект);
	Возврат РефлекторОбъекта.РеализуетИнтерфейс(Интерфейс, ВыдатьОшибку);

КонецФункции

#КонецОбласти

Лог = Логирование.ПолучитьЛог("oscript.lib.configor");