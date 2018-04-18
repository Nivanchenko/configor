#Использовать asserts
#Использовать logos
#Использовать tempfiles
#Использовать reflector

Перем ЧтениеПараметровВыполнено; // булево - флаг, что чтение выполнено

Перем ИндексПараметров; // Соответствие - плоский индекс всех параметров
Перем ПрочитанныеПараметры; // Соответствие - результат чтения из провайдеров

Перем КлассПараметров; // Произвольный класс обеспечивающий: Функция Параметры() Экспорт, Процедура УстановитьПараметры(НовыеПараметры) Экспорт

Перем ТаблицаПровайдеровПараметров; // ТаблицаЗначений Колонки: Имя, Класс, Приоритет, Настройки

Перем ОбщаяНастройка;
Перем ВстроенныеПровайдеры;

Перем ИнтерфейсПровайдера;
Перем ИнтерфейсПриемника;
Перем ИнтерфейсКонвертацииВСтруктуру;

Перем ВнутреннийКонструкторПараметров;
Перем ИспользуетсяКонструкторПараметров;

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
	ВыполнитьЧтениеПоТаблицеПровайдеров();

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

	ОбщаяНастройка.Вставить("ФайлПараметров", ПутьКФайлу);

КонецПроцедуры

// Добавляет дополнительный путь к каталогу поиска файла параметров
//
// Параметры:
//   ПутьПоискаФайлов - Строка - полный путь к дополнительному каталогу для поиска файла параметров
//
Процедура ДобавитьКаталогПоиска(Знач ПутьПоискаФайлов) Экспорт

	КаталогиПоиска = ОбщаяНастройка.КаталогиПоиска;
	КаталогиПоиска.Добавить(ПутьПоискаФайлов);

КонецПроцедуры

// Выполняет очистку путей поиска
//
Процедура ОчиститьПутиПоиска() Экспорт

	ОбщаяНастройка.КаталогиПоиска.Очистить();

КонецПроцедуры

// Добавляет имя файла параметров
//
// Параметры:
//   ИмяФайла - Строка - имя файла параметров
//
Процедура УстановитьИмяФайла(Знач ИмяФайла) Экспорт

	ОбщаяНастройка.Вставить("ИмяФайлаПараметров", ИмяФайла);

КонецПроцедуры

// Устанавливает расширение файла параметров
//
// Параметры:
//   РасширениеФайла - Строка - расширение файла параметров (например, .json/json)
//
Процедура УстановитьРасширениеФайла(Знач РасширениеФайла) Экспорт

	Если Не СтрНачинаетсяС(РасширениеФайла, ".") Тогда
		РасширениеФайла = "." + РасширениеФайла;
	КонецЕсли;

	ОбщаяНастройка.Вставить("РасширениеФайла", РасширениеФайла);

КонецПроцедуры

// Устанавливает параметры для провайдера
//
// Параметры:
//   ИдентификаторПровайдера - Строка - короткий идентификатор провайдера (например, json)
//   Параметры               - Структура - произвольная структура для передачи в провайдера
//
Процедура УстановитьПараметрыПровайдера(Знач ИдентификаторПровайдера, Знач Параметры) Экспорт

	СтрокаПровайдера = НайтиПровайдераПоИдентификатору(ИдентификаторПровайдера);
	Если СтрокаПровайдера = Неопределено Тогда
		Лог.Отладка("Провайдер с идентификатором <%1> не найден", ИдентификаторПровайдера);
		Возврат;
	КонецЕсли;

	СтрокаПровайдера.Параметры = Параметры;

КонецПроцедуры

// Очищает таблицу провайдеров и устанавливает произвольный класс-провайдер
//
// Параметры:
//   ИдентификаторПровайдера - Строка        - короткий идентификатор провайдера (например, json)
//   Класс                   - Строка, Класс - класс провайдера или имя класса
//   Настройки               - Струтура      - произвольная структура передаваемая провайдеру в момент выполнения
//   Приоритет               - Число         - Числовой приоритет выполнения провайдеры (по умолчанию 99)
//
Процедура УстановитьПроизвольныйПровайдерПараметров(Знач ИдентификаторПровайдера, 
													Знач Класс,
													Знач Настройки = Неопределено,
													Знач Приоритет = 99) Экспорт

	ТаблицаПровайдеровПараметров.Очистить();

	ДобавитьПровайдерПараметров(ИдентификаторПровайдера, Класс, Настройки, Приоритет);

КонецПроцедуры

// Добавляет в таблицу провайдеров произвольный класс-провайдер
//
// Параметры:
//   ИдентификаторПровайдера - Строка       - короткий идентификатор провайдера (например, json)
//   Класс                   - Строка, Класс - класс провайдера или имя класса
//   Настройки               - Струтура     - произвольная структура передаваемая провайдеру в момент выполнения
//   Приоритет               - Число        - Числовой приоритет выполнения провайдеры (по умолчанию 99)
//
Процедура ДобавитьПровайдерПараметров(Знач ИдентификаторПровайдера,
									Знач Класс,
									Знач Настройки = Неопределено,
									Знач Приоритет = 99) Экспорт

	НовыйПровайдер = ТаблицаПровайдеровПараметров.Добавить();
	НовыйПровайдер.Идентификатор = ИдентификаторПровайдера;
	НовыйПровайдер.Класс = Класс;
	Если Настройки = Неопределено Тогда
		Настройки = Новый Структура;
	КонецЕсли;
	НовыйПровайдер.Настройки = Настройки;
	НовыйПровайдер.Приоритет = Приоритет;

КонецПроцедуры

// Отключает и удаляет провайдера из таблицы провайдеров
//
// Параметры:
//   ИдентификаторПровайдера - Строка - короткий идентификатор провайдера (например, json)
//
Процедура ОтключитьПровайдер(Знач ИдентификаторПровайдера) Экспорт

	СтрокаПровайдера = НайтиПровайдераПоИдентификатору(ИдентификаторПровайдера);
	Если СтрокаПровайдера = Неопределено Тогда
		Лог.Отладка("Провайдер с идентификатором <%1> не найден", ИдентификаторПровайдера);
		Возврат;
	КонецЕсли;

	ТаблицаПровайдеровПараметров.Удалить(СтрокаПровайдера);

КонецПроцедуры

// Добавляет встроенный провайдер по идентификаторы и приоритету
//
// Параметры:
//   ИмяПровайдера - Строка - короткий идентификатор встроенных провайдеров (например, json)
//   Приоритет     - Число  - Числовой приоритет выполнения провайдеры
//
Процедура ДобавитьВстроенныйПровайдер(Знач ИмяПровайдера, Знач Приоритет) Экспорт

	КлассПровайдера = ВстроенныеПровайдеры[ИмяПровайдера];

	ДобавитьПровайдерПараметров(ИмяПровайдера, КлассПровайдера, Новый Структура, Приоритет);

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

Процедура ВыполнитьЧтениеПоТаблицеПровайдеров()

	ТаблицаПровайдеровПараметров.Сортировать("Приоритет ВОЗР");
	Лог.Отладка("Общее количество провайдеров <%1>", ТаблицаПровайдеровПараметров.Количество());
	Для каждого ПровайдерЧтения Из ТаблицаПровайдеровПараметров Цикл

		Если ТипЗнч(ПровайдерЧтения.Класс) = Тип("Строка") Тогда

			Попытка
				КлассПровайдера = Новый(ПровайдерЧтения.Класс);
			Исключение
				Лог.КритичнаяОшибка("Не удалось прочитать параметры используя провайдер <%1>. По причине: %2", 
									ПровайдерЧтения.Идентификатор,
									ОписаниеОшибки());
				Продолжить;
			КонецПопытки;

		Иначе
			КлассПровайдера = ПровайдерЧтения.Класс;
		КонецЕсли;

		Лог.Отладка("Класс провайдера <%1>", КлассПровайдера);
		Если Не ПроверитьКлассПровайдера(КлассПровайдера) Тогда
			Продолжить;
		КонецЕсли;

		ВыполнитьЧтениеДляПровайдера(ПровайдерЧтения.Идентификатор, КлассПровайдера, ПровайдерЧтения.Настройки);

	КонецЦикла;

КонецПроцедуры

Функция НайтиПровайдераПоИдентификатору(Знач ИдентификаторПровайдера)

	Отбор = Новый Структура("Идентификатор", ИдентификаторПровайдера);

	СтрокаПровайдера = ТаблицаПровайдеровПараметров.НайтиСтроки(Отбор);

	Если СтрокаПровайдера.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат СтрокаПровайдера[0];

КонецФункции

Функция ПроверитьКлассПровайдера(КлассЧтенияПараметров)
	
	НеобходимыйИнтерфейсЕсть = ИнтерфейсРеализован(ИнтерфейсПровайдера, КлассЧтенияПараметров);

	Если НЕ НеобходимыйИнтерфейсЕсть Тогда
		Лог.КритичнаяОшибка("Класс <%1> не реализует необходимых функций/процедур интерфейса <ИнтерфейсПровайдера>",
							КлассЧтенияПараметров);
	КонецЕсли;

	Возврат НеобходимыйИнтерфейсЕсть;
КонецФункции

Процедура ВыполнитьЧтениеДляПровайдера(ИдентификаторПровайдера, КлассПровайдера, ПараметрыПровайдера)

	Попытка
		ДополнитьПараметрыПровайдера(ПараметрыПровайдера, ОбщаяНастройка);
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

Процедура ДополнитьПараметрыПровайдера(ПараметрыПровайдера, ДополнительныеПараметры)

	Лог.Отладка("Дополняю параметры провайдера общими параметрами");
	Для каждого КлючЗначение Из ДополнительныеПараметры Цикл

		КлючИсточника = КлючЗначение.Ключ;
		ЗначениеИсточника = КлючЗначение.Значение;

		ПараметрыПровайдера.Вставить(КлючИсточника, ЗначениеИсточника);
		
	КонецЦикла;

	Лог.Отладка("Всего параметров провайдера <%1>", ПараметрыПровайдера.Количество());

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

Процедура ДобавитьСтандартныеПутиПоиска()

	СистемнаяИнформация = Новый СистемнаяИнформация;

	ДобавитьКаталогПоиска(ТекущийКаталог());
	ДобавитьКаталогПоиска(СистемнаяИнформация.ПолучитьПутьПапки(СпециальнаяПапка.ЛокальныйКаталогДанныхПриложений));
	ДобавитьКаталогПоиска(СистемнаяИнформация.ПолучитьПутьПапки(СпециальнаяПапка.ПрофильПользователя));

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

#КонецОбласти

#Область Инициализация

Процедура ПриСозданииОбъекта(Знач Провайдеры = "json")

	ИндексПараметров = Новый Соответствие;
	ПрочитанныеПараметры = Новый Соответствие;

	ВстроенныеПровайдеры = Новый ВстроенныеПровайдеры();

	ТаблицаПровайдеровПараметров = Новый ТаблицаЗначений;
	ТаблицаПровайдеровПараметров.Колонки.Добавить("Идентификатор"); // Представление
	ТаблицаПровайдеровПараметров.Колонки.Добавить("Класс"); // ИмяКласса или Инстанс Класс
	ТаблицаПровайдеровПараметров.Колонки.Добавить("Приоритет"); // Число от 0 до 10
	ТаблицаПровайдеровПараметров.Колонки.Добавить("Настройки"); // Структура

	Лог.Отладка("Провайдеры при создании менеджера <%1>", Провайдеры);

	Если НЕ ЗначениеЗаполнено(Провайдеры) Тогда
		Провайдеры = "json";
	КонецЕсли;

	МассивПровайдеров = СтрРазделить(Провайдеры, ";", Ложь);

	ДоступныеПровайдеры = ВстроенныеПровайдеры.ДоступныеПровайдеры;

	ИндексПриоритета = 0;

	Для каждого ИмяПровайдера Из МассивПровайдеров Цикл

		Лог.Отладка("Добавляю встроенный провайдер <%1>", ИмяПровайдера);

		Если ДоступныеПровайдеры.Свойство(ИмяПровайдера) Тогда

			ДобавитьВстроенныйПровайдер(ИмяПровайдера, ИндексПриоритета);

		КонецЕсли;

		ИндексПриоритета = ИндексПриоритета + 1;

	КонецЦикла;

	ОбщаяНастройка = Новый Структура();
	ОбщаяНастройка.Вставить("ФайлПараметров", Неопределено);
	ОбщаяНастройка.Вставить("КаталогиПоиска", Новый Массив);
	ОбщаяНастройка.Вставить("ИмяФайлаПараметров", "config");
	ОбщаяНастройка.Вставить("РасширениеФайла", ""); // Дополнительные ограничение для провайдеров
	ОбщаяНастройка.Вставить("КлючЗначениеПараметров", Новый Массив); // Пути к файлам параметров или другая информация от провайдеров

	ДобавитьСтандартныеПутиПоиска();

	ЧтениеПараметровВыполнено = Ложь;

	ИнтерфейсПровайдера = Новый ИнтерфейсОбъекта;
	ИнтерфейсПровайдера.Ф("ПрочитатьПараметры", 1);

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