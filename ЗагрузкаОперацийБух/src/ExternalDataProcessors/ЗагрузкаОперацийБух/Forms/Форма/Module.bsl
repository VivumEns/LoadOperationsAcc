
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ЗадатьФормеЗаголовок();
	
	ЗаполнитьНачальныеЗначения();
	
    Элемент = Элементы.Добавить("Таблица", Тип("ТаблицаФормы"), Элементы.Страница_Данные_ГруппаТаблицы);
    Элемент.ПутьКДанным = "Таблица";

КонецПроцедуры

&НаСервере
Процедура ЗадатьФормеЗаголовок()
	МетаданныеОбъекта = РеквизитФормыВЗначение("Объект").Метаданные();
	Синоним = МетаданныеОбъекта.Синоним;
	Версия = МетаданныеОбъекта.Комментарий;
	//@skip-check module-self-reference
	ЭтотОбъект.Заголовок = СтрШаблон("%1 (вер. %2)", Синоним, Версия);
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНачальныеЗначения()
	
	ВыборкаОрганизации = Справочники.Организации.Выбрать();
	
	Пока ВыборкаОрганизации.Следующий() Цикл
		Если НЕ ВыборкаОрганизации.ПометкаУдаления Тогда
			Объект.Организация = ВыборкаОрганизации.Ссылка;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	//Объект.УказыватьОтветственногоЕслиНеНайден = Пользователи.ТекущийПользователь();
	
	Объект.ОтбиратьСтрокиПоФильтруПоКомментарию = Ложь;
	Объект.ФильтрПоКомментарию = "%Загрузка из ОУ%";
	
	Объект.ОтключитьКонтрольОшибок = Ложь;
	
КонецПроцедуры

#КонецОбласти


#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИмяФайлаДляЗагрузкиНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	Диалог.Фильтр = "Excel (*.xls;*.xlsx)|*.xls;*.xlsx|";
	Диалог.МножественныйВыбор = Ложь;
	Диалог.Заголовок = НСтр("ru='Выберите файл'");
	
	Диалог.Показать(Новый ОписаниеОповещения("ВыборФайлаЗавершение", ЭтотОбъект));

КонецПроцедуры

&НаКлиенте
Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		
		ИмяФайлаДляЗагрузки = ВыбранныеФайлы[0];
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


#Область ЧтениеДанныхИзФайла

&НаКлиенте
Процедура Команда_ЗагрузитьТЗ(Команда)

	ОшибкиЗаполненияЗначений = ПолучитьОшибкиЗаполненияЗначенийДляЗагрузкиИзФайла();
	Если ОшибкиЗаполненияЗначений.Количество() > 0 Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = СтрСоединить(ОшибкиЗаполненияЗначений, Символы.ПС);
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;

	ПомещаемыеФайлы = Новый Массив;
	
	ОписаниеФайлаСпр = Новый ОписаниеПередаваемогоФайла();
	ОписаниеФайлаСпр.Имя = СокрЛП(ИмяФайлаДляЗагрузки);
	
	ПомещаемыеФайлы.Добавить(ОписаниеФайлаСпр);
	
	НачатьПомещениеФайлов(Новый ОписаниеОповещения("ПомещениеФайловЗавершение", ЭтотОбъект), ПомещаемыеФайлы, , Ложь, ЭтаФорма.УникальныйИдентификатор);
		
КонецПроцедуры

&НаКлиенте
Функция ПолучитьОшибкиЗаполненияЗначенийДляЗагрузкиИзФайла()

	Результат = Новый Массив;
	
	Если НЕ ЗначениеЗаполнено(Объект.Организация) Тогда
		Результат.Добавить("Загрузка файла прервана, не заполнено поле Организация!");
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(ИмяФайлаДляЗагрузки) Тогда
		Результат.Добавить("Загрузка файла прервана, не выбран файл!");
	КонецЕсли;

	Если Объект.ДатаНачала < Дата(2024, 1, 1) ИЛИ Объект.ДатаОкончания < Дата(2024, 1, 1) ИЛИ Объект.ДатаОкончания < Объект.ДатаНачала Тогда
		Результат.Добавить("Загрузка файла прервана, не корректно заполнен период!");
	КонецЕсли;
		
	Возврат Результат;

КонецФункции		

&НаКлиенте
Процедура ПомещениеФайловЗавершение(ПомещенныеФайлы, ДопПараметры) Экспорт
	
	Если ТипЗнч(ПомещенныеФайлы) = Тип("Массив") Тогда
		Результат = ПомещениеФайловЗавершениеНаСервере(ПомещенныеФайлы[0]);
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = Результат;
		Сообщение.Сообщить();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция ПомещениеФайловЗавершениеНаСервере(Знач ДанныеФайла)
	
	Результат = ЧтениеФайлаExcelВТабличныйДокумент(ДанныеФайла);
	
	Элементы.ОтсутствиеТаблицы.Видимость = Элементы.Таблица.ПодчиненныеЭлементы.Количество() = 0;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ЧтениеФайлаExcelВТабличныйДокумент(Знач ДанныеФайла)
	
	Результат = "Выполнена загрузка из файла.";
	
	РасширениеФайла = ?(Прав(ДанныеФайла.Имя, 4) = "xlsx", "xlsx", "xls");
	ИмяПромежуточногоФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
	
	ФайлExcelНаСервере = ПолучитьИзВременногоХранилища(ДанныеФайла.Хранение);
	ФайлExcelНаСервере.Записать(ИмяПромежуточногоФайла);

	Попытка
		РезультатТД = Новый ТабличныйДокумент();
		РезультатТД.Прочитать(ИмяПромежуточногоФайла, СпособЧтенияЗначенийТабличногоДокумента.Значение);
		УдалитьФайлы(ИмяПромежуточногоФайла);
		
		РезультатТЗ = ПрочитатьТаблицуЗначенийИзТабличногоДокумента(РезультатТД);
		РезультатТЗ = УдалитьСтрокиСПустойПервойКолонкой(РезультатТЗ);
		РезультатТЗ = ОтобратьСтрокиПоФильтруПоКомментарию(РезультатТЗ);

		КоличествоСуществующихКолонок = Элементы.Таблица.ПодчиненныеЭлементы.Количество();
		Если КоличествоСуществующихКолонок > 0 Тогда
			МассивУдаляемыхРеквизитов = Новый Массив;
			Пока КоличествоСуществующихКолонок > 0 Цикл
				МассивУдаляемыхРеквизитов.Добавить("Таблица." + Элементы.Таблица.ПодчиненныеЭлементы[КоличествоСуществующихКолонок - 1].Имя);
				Элементы.Удалить(Элементы.Таблица.ПодчиненныеЭлементы[КоличествоСуществующихКолонок - 1]);
				КоличествоСуществующихКолонок = КоличествоСуществующихКолонок - 1;
			КонецЦикла; 
			ИзменитьРеквизиты(, МассивУдаляемыхРеквизитов); 
		КонецЕсли;

		Для каждого Колонка Из РезультатТЗ.Колонки Цикл
			ДобавитьКолонку(Колонка.Имя, Колонка.ТипЗначения);
		КонецЦикла; 
	
		ЗначениеВДанныеФормы(РезультатТЗ, Таблица);	
	Исключение
	    Результат = "Ошибка при получении файла! Описание: " + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПрочитатьТаблицуЗначенийИзТабличногоДокумента(ДанныеВТабличномДокументе)
	
    ПоследняяСтрока = ДанныеВТабличномДокументе.ВысотаТаблицы;
    ПоследняяКолонка = ДанныеВТабличномДокументе.ШиринаТаблицы;
    ОбластьЯчеек = ДанныеВТабличномДокументе.Область(1, 1, ПоследняяСтрока, ПоследняяКолонка);
    ИсточникДанных = Новый ОписаниеИсточникаДанных(ОбластьЯчеек);
    ПостроительОтчета = Новый ПостроительОтчета;
    ПостроительОтчета.ИсточникДанных = ИсточникДанных;
    ПостроительОтчета.Выполнить();
    Результат = ПостроительОтчета.Результат.Выгрузить();
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция УдалитьСтрокиСПустойПервойКолонкой(ИсходныеДанные)
	
	Если ИсходныеДанные.Колонки.Количество() = 0 Тогда
		Возврат ИсходныеДанные;
	КонецЕсли;

	ИмяПервойКолонки = ИсходныеДанные.Колонки.Получить(0).Имя;

	ТекстЗапроса = "
		|ВЫБРАТЬ *
		|ПОМЕСТИТЬ ИсходныеДанные
		|ИЗ
		|	&ИсходныеДанные КАК ИсходныеДанные
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ *
		|ИЗ
		|	ИсходныеДанные КАК ИсходныеДанные
		|ГДЕ
		|	ИсходныеДанные." + ИмяПервойКолонки + " > "" ""
		|";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Запрос.УстановитьПараметр("ИсходныеДанные", ИсходныеДанные);
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Возврат РезультатЗапроса;
	
КонецФункции

&НаСервере
Функция ОтобратьСтрокиПоФильтруПоКомментарию(ИсходныеДанные)
	
	Комментарий = СокрЛП(Объект.ФильтрПоКомментарию);
	Если ПустаяСтрока(Комментарий) ИЛИ НЕ Объект.ОтбиратьСтрокиПоФильтруПоКомментарию Тогда
		Возврат ИсходныеДанные;
	КонецЕсли;
	
	ТекстЗапроса = "
	|ВЫБРАТЬ *
	|ПОМЕСТИТЬ ИсходныеДанные
	|ИЗ
	|	&ИсходныеДанные КАК ИсходныеДанные
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ *
	|ИЗ
	|	ИсходныеДанные КАК ИсходныеДанные
	|ГДЕ
	|	ИсходныеДанные.Комментарий ПОДОБНО &Комментарий
	|";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Запрос.УстановитьПараметр("ИсходныеДанные", ИсходныеДанные);
	Запрос.УстановитьПараметр("Комментарий", Комментарий);
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Возврат РезультатЗапроса;
	
КонецФункции

&НаСервере
Процедура ДобавитьКолонку(Имя, ТипЗначения)

	МассивДобавляемыхРеквизитов = Новый Массив;
	РеквизитФормы = Новый РеквизитФормы(Имя, ТипЗначения, "Таблица", Имя); 
	МассивДобавляемыхРеквизитов.Добавить(РеквизитФормы); 
	ИзменитьРеквизиты(МассивДобавляемыхРеквизитов);
	
	Элемент = Элементы.Добавить(Имя, Тип("ПолеФормы"), Элементы.Таблица); 
	Элемент.ПутьКДанным = "Таблица." + Имя;
	Элемент.Вид = ВидПоляФормы.ПолеВвода;

КонецПроцедуры

#КонецОбласти

