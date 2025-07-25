
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

#КонецОбласти

#Область ПрограммныйИнтерфейс



#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения (Отказ, РезультатПроведения)
		
	Движения.ВКМ_ДополнительныеНачисления.Записывать = Истина;
	Движения.ВКМ_Удержания.Записывать = Истина;
	
	Для Каждого ТекСтрокаНачисления из Начисления Цикл
		Если ТекСтрокаНачисления.СуммаПремии <= 0 Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СТРШаблон("У сотрудника %1 некорректно указана сумма премии", ТекСтрокаНачисления.Сотрудник);
			Сообщение.Сообщить();
			Продолжить;
		КонецЕсли;	
		Движение = Движения.ВКМ_ДополнительныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ДополнительныеНачисления.Премия;
		Движение.ПериодРегистрации = Дата;
		Движение.Сотрудник = ТекСтрокаНачисления.Сотрудник;
		Движение.Подразделение = ТекСтрокаНачисления.Подразделение;
		Движение.Сумма = ТекСтрокаНачисления.СуммаПремии;
		
		ДвижениеУдержание = Движения.ВКМ_Удержания.Добавить();
		ДвижениеУдержание.Сторно = Ложь;
		ДвижениеУдержание.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		ДвижениеУдержание.ПериодРегистрации = Дата;
		ДвижениеУдержание.Сотрудник = ТекСтрокаНачисления.Сотрудник;
		ДвижениеУдержание.Подразделение = ТекСтрокаНачисления.Подразделение;
		ДвижениеУдержание.СуммаУдержания = ОКР(ТекСтрокаНачисления.СуммаПремии * 0.13,2);
	КонецЦикла;

	Движения.ВКМ_ДополнительныеНачисления.Записать();
	Движения.ВКМ_Удержания.Записать();

	
	СформироватьДвиженияВзаиморасчетыПриход();
	СформироватьДвиженияВзаиморасчетыРасход();
//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	//Данный фрагмент построен конструктором.
	//При повторном использовании конструктора, внесенные вручную данные будут утеряны!
	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура СформироватьДвиженияВзаиморасчетыРасход()
		
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_Удержания.Сотрудник,
		|	СУММА(ВКМ_Удержания.СуммаУдержания) КАК СуммаУдержания
		|ИЗ
		|	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
		|ГДЕ
		|	ВКМ_Удержания.Регистратор = &Регистратор
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_Удержания.Сотрудник";
	
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;    
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками");  
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = Начисления;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Сотрудник","Сотрудник"); 
	Блокировка.Заблокировать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Сотрудник = ВыборкаДетальныеЗаписи.Сотрудник;
		Движение.Сумма = ВыборкаДетальныеЗаписи.СуммаУдержания ;
	КонецЦикла;

	
КонецПроцедуры
Процедура СформироватьДвиженияВзаиморасчетыПриход()
		
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ДополнительныеНачисления.Сотрудник,
		|	СУММА(ВКМ_ДополнительныеНачисления.Сумма) КАК СуммаНачисления
		|ИЗ
		|	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
		|ГДЕ
		|	ВКМ_ДополнительныеНачисления.Регистратор = &Регистратор
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ДополнительныеНачисления.Сотрудник";
	
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;    
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками");  
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = Начисления;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Сотрудник","Сотрудник"); 
	Блокировка.Заблокировать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Сотрудник = ВыборкаДетальныеЗаписи.Сотрудник;
		Движение.Сумма = ВыборкаДетальныеЗаписи.СуммаНачисления ;
	КонецЦикла;
	
	
	
КонецПроцедуры

#КонецОбласти

#Область Инициализация

#КонецОбласти

#КонецЕсли
