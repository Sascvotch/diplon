
#Область ОписаниеПеременных

#КонецОбласти

#Область ОбработчикиСобытийФормы

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура СформироватьСписокДоговоров(Команда)
		
		ЗаполнитьТаблицуДоговора();
	    ОбновитьОтображениеДанных();
	    
КонецПроцедуры

&НаКлиенте
Процедура СформироватьРеализации(Команда)

//	КолЗаписей = Объект.Акты.Количество();
//	Если КолЗаписей = 0 Тогда
//		Сообщение = Новый СообщениеПользователю;
//		Сообщение.Текст = "Нет договоров для формирования реализаций";
//		Сообщение.Сообщить();
//		Возврат;
//	КонецЕсли;

	ДлительнаяОперация = СоздатьНовыйДокумент();
	
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтаФорма);
	ПараметрыОжидания.Интервал = 1;
	ПараметрыОжидания.ВыводитьПрогрессВыполнения = Истина;
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
	
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения ("ОповещениеОЗавершении", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение (ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = "Операция завершена";
	Сообщение.Сообщить();
 	
КонецПроцедуры

&НаКлиенте
Процедура ОповещениеОЗавершении (Результат, ДополнительныеПараметры) Экспорт
	Если Результат.Статус = "Выполнено" Тогда
		Сообщить (ПолучитьИзВременногоХранилища (Результат.АдресРезультата));
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОповеститьОПрогрессе (Прогресс, ДополнительныеПараметры) Экспорт
	Если Прогресс.Прогресс <> Неопределено Тогда
		Состояние ("Выполняется тяжелая фоновая операция", Прогресс.Прогресс.Процент);
	КонецЕсли;	
	
КонецПроцедуры





#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция СоздатьНовыйДокумент()
	Организация = Объект.Организация;
	Дата = КонецМесяца(Объект.Период);
	//ТабАкты = Объект.Акты.Выгрузить();
	ДлительнаяОперация = ДлительныеОперации.ВыполнитьФункцию(УникальныйИдентификатор,"Обработки.ВКМ_МассовоеСозданиеАктов.СоздатьНовыйДокумент", Организация, Дата);
	//Обработки.ВКМ_МассовоеСозданиеАктов.СоздатьНовыйДокумент(Организация,Дата );
	Возврат ДлительнаяОперация;

КонецФункции 


&НаСервере
Процедура ЗаполнитьТаблицуДоговора()
	
	Если НЕ ЗначениеЗаполнено(Объект.Период) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Необходимо указать период";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(Объект.Организация) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Необходимо указать организацию";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;	
		
	ДатаНачалаОтчетногоМесяца = НачалоМесяца(Объект.Период);
	ДатаОкончанияОтчетногоМесяца = КонецМесяца(Объект.Период);
	
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
		|	ВТ_Реализации.Ссылка КАК Документ
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
	Запрос.УстановитьПараметр("ВКМ_ДатаНачалаДействияДоговора",  ДатаНачалаОтчетногоМесяца);
	Запрос.УстановитьПараметр("НачалоМесяца", ДатаНачалаОтчетногоМесяца);
	Запрос.УстановитьПараметр("КонецМесяца", ДатаОкончанияОтчетногоМесяца);
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Запрос.Выполнить().Пустой() Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон ("Нет договора Абонентского обслуживания у организации %1 за период %2",Объект.Организация,Формат(ДатаНачалаОтчетногоМесяца, "ДФ=ММMM.yyyy") );
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();

	Объект.Акты.Очистить();

	Пока Выборка.Следующий() Цикл
		НоваяСтрока = Объект.Акты.Добавить();
		НоваяСтрока.Договор = Выборка.Договор;
		НоваяСтрока.Реализация = Выборка.Документ;
		НоваяСтрока.ДатаНачалаАО = Выборка.ДатаНачалаДействияДоговора;
		НоваяСтрока.ДатаОкончанияАО = Выборка.ДатаОкончанияДействияДоговора;
		НоваяСтрока.Контрагент = Выборка.Контрагент;
	КонецЦикла;
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = СтрШаблон("Список договоров за %1 сформирован", Формат(ДатаНачалаОтчетногоМесяца, "ДФ=MMММ.yyyy"));
	Сообщение.Сообщить();
	
КонецПроцедуры	


#КонецОбласти

		