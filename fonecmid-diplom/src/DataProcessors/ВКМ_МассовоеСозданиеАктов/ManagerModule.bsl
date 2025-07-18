#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс
#КонецОбласти

#Область ОбработчикиСобытий

// Код процедур и функций

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция СоздатьНовыйДокумент(Организация, Дата) Экспорт
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = "Началось заполнение реализаций";
	Сообщение.Сообщить();

	ДатаНачалаОтчетногоМесяца = НачалоМесяца(Дата);
	ДатаОкончанияОтчетногоМесяца = КонецМесяца(Дата);

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	РеализацияТоваровУслуг.Ссылка,
	|	РеализацияТоваровУслуг.Договор,
	|	РеализацияТоваровУслуг.Дата
	|ПОМЕСТИТЬ ВТ_Реализации
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|ГДЕ
	|	РеализацияТоваровУслуг.Дата >= &НачалоМесяца
	|	и РеализацияТоваровУслуг.Дата <= &КонецМесяца
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка КАК Договор,
	|	ДоговорыКонтрагентов.ВидДоговора,
	|	ДоговорыКонтрагентов.ВКМ_ДатаНачалаДействияДоговора КАК ДатаНачалаДействияДоговора,
	|	ДоговорыКонтрагентов.ВКМ_ДатаОкончанияДействияДоговора КАК ДатаОкончанияДействияДоговора,
	|	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	|	ВТ_Реализации.Ссылка КАК Реализация
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов 
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Реализации КАК ВТ_Реализации
	|		ПО ВТ_Реализации.Договор = ДоговорыКонтрагентов.Ссылка
	|ГДЕ
	|	ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
	|	И ДоговорыКонтрагентов.ВКМ_ДатаНачалаДействияДоговора <= &ВКМ_ДатаНачалаДействияДоговора
	|	И ДоговорыКонтрагентов.ВКМ_ДатаОкончанияДействияДоговора >= &ВКМ_ДатаНачалаДействияДоговора
	|	И ДоговорыКонтрагентов.Организация = &Организация";

	Запрос.УстановитьПараметр("ВидДоговора", Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание);
	Запрос.УстановитьПараметр("ВКМ_ДатаНачалаДействияДоговора", ДатаНачалаОтчетногоМесяца);
	Запрос.УстановитьПараметр("НачалоМесяца", ДатаНачалаОтчетногоМесяца);
	Запрос.УстановитьПараметр("КонецМесяца", ДатаОкончанияОтчетногоМесяца);
	Запрос.УстановитьПараметр("Организация", Организация);

	РезультатЗапроса = Запрос.Выполнить();

	Если Запрос.Выполнить().Пустой() Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Нет договора Абонентского обслуживания у организации %1 за период %2", Организация,
			Формат(ДатаНачалаОтчетногоМесяца, "ДФ=ММMM.yyyy"));
		Сообщение.Сообщить();
	КонецЕсли;

	Выборка = РезультатЗапроса.Выбрать();
	КолДок = Выборка.Количество();
	Сч=1;
	Пока Выборка.Следующий() Цикл

		Если Не ЗначениеЗаполнено(Выборка.Реализация) Тогда
			Реализация = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
			Реализация.Договор = Выборка.Договор;
			Реализация.Контрагент = Выборка.Контрагент;
			Реализация.Организация = Организация;
			Реализация.Комментарий = "Создано из обработки массовое создание актов";
		Иначе
			Реализация = Выборка.Реализация.ПолучитьОбъект();
			Реализация.Комментарий = "Обновлено из обработки массовое создание актов";
		КонецЕсли;
		Реализация.Дата = Дата; //ТекущаяДата()
		Реализация.ВыполнитьАвтозаполнение();

		Попытка
			Реализация.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
		Исключение
			Реализация.Записать(РежимЗаписиДокумента.Запись);
		КонецПопытки;

		ПроцентВыполнения = (Сч / КолДок) * 100;
		ПроцентВыполнения = Окр(ПроцентВыполнения, 0);
		Сч = Сч + 1;
		ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения);
	КонецЦикла;

КонецФункции

#КонецОбласти

#КонецЕсли