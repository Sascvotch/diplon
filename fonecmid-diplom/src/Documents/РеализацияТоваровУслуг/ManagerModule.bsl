
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

Функция ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании) Экспорт
	
	Если ПравоДоступа("Добавление", Метаданные.Документы.РеализацияТоваровУслуг) Тогда
		
        КомандаСоздатьНаОсновании = КомандыСозданияНаОсновании.Добавить();
        КомандаСоздатьНаОсновании.Менеджер = Метаданные.Документы.РеализацияТоваровУслуг.ПолноеИмя();
        КомандаСоздатьНаОсновании.Представление = ОбщегоНазначения.ПредставлениеОбъекта(Метаданные.Документы.РеализацияТоваровУслуг);
        КомандаСоздатьНаОсновании.РежимЗаписи = "Проводить";
		
		Возврат КомандаСоздатьНаОсновании;
		
	КонецЕсли;

	Возврат Неопределено;
	
КонецФункции

//код добавлен 24.06.2025
Процедура ПриОпределенииНастроекПечати(НастройкиОбъекта) Экспорт	
		НастройкиОбъекта.ПриДобавленииКомандПечати = Истина;
КонецПроцедуры

Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
		
		КомандаПечати = КомандыПечати.Добавить();
		КомандаПечати.Идентификатор = "АктОбОказанныхУслугах";
		КомандаПечати.Представление = НСтр("ru = 'Акт об оказанных услугах'");
		КомандаПечати.Порядок = 5;
		
КонецПроцедуры

Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
		
		ПечатнаяФорма = УправлениеПечатью.СведенияОПечатнойФорме(КоллекцияПечатныхФорм, "АктОбОказанныхУслугах");
		Если ПечатнаяФорма <> Неопределено Тогда
			ПечатнаяФорма.ТабличныйДокумент = ПечатьАктОбОказанныхУслугах(МассивОбъектов, ОбъектыПечати);
			ПечатнаяФорма.СинонимМакета = НСтр("ru = 'Акт об оказанных услугах'");
			ПечатнаяФорма.ПолныйПутьКМакету = "Документ.РеализацияТоваровУслуг.ПФ_MXL_АктОбОказанныхУслугах";
		КонецЕсли;
			
КонецПроцедуры

//конец добавленного кода

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

//код добавлен 24.06.2025
Функция ПечатьАктОбОказанныхУслугах(МассивОбъектов, ОбъектыПечати) Экспорт
		
		ТабличныйДокумент = Новый ТабличныйДокумент;
		ТабличныйДокумент.КлючПараметровПечати = "ПараметрыПечати_АктОбОказанныхУслугах";
		
		Макет = УправлениеПечатью.МакетПечатнойФормы("Документ.РеализацияТоваровУслуг.ПФ_MXL_АктОбОказанныхУслугах");
		
		ДанныеДокументов = ПолучитьДанныеДокументов(МассивОбъектов);
		
		ПервыйДокумент = Истина;
		
		Пока ДанныеДокументов.Следующий() Цикл
			
			Если Не ПервыйДокумент Тогда
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			КонецЕсли;
			
			ПервыйДокумент = Ложь;
			
			НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
			
			ВывестиЗаголовокАктОбОказанныхУслугах(ДанныеДокументов, ТабличныйДокумент, Макет);
			
			ВывестиСодержаниеАктОбОказанныхУслугах(ДанныеДокументов, ТабличныйДокумент, Макет);
			
			ВывестиСуммуИтог(ДанныеДокументов, ТабличныйДокумент, Макет);
			
			ВывестиПодвалАктОбОказанныхУслугах(ДанныеДокументов, ТабличныйДокумент, Макет);
			
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, 
			НомерСтрокиНачало, ОбъектыПечати, ДанныеДокументов.Ссылка);		
			
		КонецЦикла;	
		
		Возврат ТабличныйДокумент;
		
	КонецФункции   

Процедура ВывестиЗаголовокАктОбОказанныхУслугах(ДанныеДокументов, ТабличныйДокумент, Макет)
		
		ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
		
		ШаблонЗаголовка = "Акт об оказанных услугах №%1 от %2";
		ТекстЗаголовка = СтрШаблон(ШаблонЗаголовка,
		ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(ДанныеДокументов.Номер),
		Формат(ДанныеДокументов.Дата, "ДЛФ=D"));
		ДанныеПечати = Новый Структура;
		ДанныеПечати.Вставить("ТекстЗаголовка", ТекстЗаголовка);
		ДанныеПечати.Вставить("Организация", ДанныеДокументов.Организация);
		ДанныеПечати.Вставить("Контрагент", ДанныеДокументов.Контрагент);
		ДанныеПечати.Вставить("Договор", ДанныеДокументов.Договор);
		ОбластьШапка.Параметры.Заполнить(ДанныеПечати);
		ТабличныйДокумент.Вывести(ОбластьШапка);
		
КонецПроцедуры   

Процедура ВывестиСодержаниеАктОбОказанныхУслугах(ДанныеДокументов, ТабличныйДокумент, Макет)
		
		ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТЧ");
		ОбластьСтрока = Макет.ПолучитьОбласть("СтрокаТЧ");
		
		ТабличныйДокумент.Вывести(ОбластьШапкаТаблицы);
		
		ВыборкаУслуги = ДанныеДокументов.Услуги.Выбрать();
		Пока ВыборкаУслуги.Следующий() Цикл
			ОбластьСтрока.Параметры.Заполнить(ВыборкаУслуги);
			ТабличныйДокумент.Вывести(ОбластьСтрока);
		КонецЦикла;

КонецПроцедуры

Процедура ВывестиСуммуИтог(ДанныеДокументов, ТабличныйДокумент, Макет)
		
		ОбластьСумма = Макет.ПолучитьОбласть("Итог");
		ДанныеПечати = Новый Структура;
		ДанныеПечати.Вставить("СуммаИтог", ДанныеДокументов.СуммаДокумента);
		СуммаПрописью = ЧислоПрописью(ДанныеДокументов.СуммаДокумента, "Л = ru_RU; ДП = Истина", "рубль, рубля, рублей, м, копейка, копейки, копеек, ж, 2");
		ДанныеПечати.Вставить("СуммаИтогПрописью", СуммаПрописью);
		ОбластьСумма.Параметры.Заполнить(ДанныеПечати);
		ТабличныйДокумент.Вывести(ОбластьСумма);

КонецПроцедуры

Процедура ВывестиПодвалАктОбОказанныхУслугах(ДанныеДокументов, ТабличныйДокумент, Макет)
		
		ОбластьПодвал = Макет.ПолучитьОбласть("Подвал");
		ДанныеПечати = Новый Структура;
		ДанныеПечати.Вставить("Организация", ДанныеДокументов.Организация);
		ДанныеПечати.Вставить("Контрагент", ДанныеДокументов.Контрагент);
		ОбластьПодвал.Параметры.Заполнить(ДанныеПечати);
		ТабличныйДокумент.Вывести(ОбластьПодвал);
		
КонецПроцедуры

Функция ПолучитьДанныеДокументов(МассивОбъектов)
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	РеализацияТоваровУслуг.Ссылка КАК Ссылка,
		|	РеализацияТоваровУслуг.Организация КАК Организация,
		|	РеализацияТоваровУслуг.Контрагент КАК Контрагент,
		|	РеализацияТоваровУслуг.Услуги.(
		|		Ссылка КАК Ссылка,
		|		НомерСтроки КАК НомерСтроки,
		|		Номенклатура КАК Номенклатура,
		|		Количество КАК Количество,
		|		Цена,
		|		Сумма) КАК Услуги,
		|	РеализацияТоваровУслуг.Номер КАК Номер,
		|	РеализацияТоваровУслуг.Дата КАК Дата,
		|	РеализацияТоваровУслуг.Договор,
		|	РеализацияТоваровУслуг.СуммаДокумента
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|ГДЕ
		|	РеализацияТоваровУслуг.Ссылка В (&МассивОбъектов)";
		
		Запрос.УстановитьПараметр("МассивОбъектов", МассивОбъектов);
		
		Возврат Запрос.Выполнить().Выбрать();
		
КонецФункции
	
//конец добавленного кода



#КонецОбласти
#КонецЕсли