
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
Процедура СформироватьВыплаты(Команда)
	
	
	
СформироватьВыплатыИзРегистра();


КонецПроцедуры
#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СформироватьВыплатыИзРегистра()
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.Сотрудник,
		|	СУММА(ВКМ_ВзаиморасчетыССотрудникамиОстатки.СуммаОстаток) КАК СуммаОстаток
		|ИЗ
		|	РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками.Остатки(&Период,) КАК ВКМ_ВзаиморасчетыССотрудникамиОстатки
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.Сотрудник";
	
	Запрос.УстановитьПараметр("Период", Объект.Дата);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Объект.Выплаты.Очистить();
	Пока Выборка.Следующий() Цикл
		СтрокаВыплаты = Объект.Выплаты.Добавить();
		СтрокаВыплаты.Сотрудник = Выборка.Сотрудник;
		СтрокаВыплаты.Сумма = Выборка.СуммаОстаток;
	КонецЦикла;
	
КонецПроцедуры	
// Код процедур и функций

#КонецОбласти
