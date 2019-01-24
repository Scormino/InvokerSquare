var sFileName = '[BaseLib/utils.js] '

var DEBUG_SPEW = true   //Включить db()?



var db
if(DEBUG_SPEW){
  db = function(){
    var args = []
    for (var i = 0; i < arguments.length; i++) {
      args[i] = arguments[i]
    }    
    $.Msg.apply($.Msg, args)
  }
}else{
  db = function(){}
}

db(sFileName, "complete...")





  
var sPrePrefix = '__ST'
var sPostPrefixKey = 'k'
var sPostPrefixVal = 'v'

function StringTable2Table(stTable, nSTableId){
  var hResult = {} //это будет результирующая таблица для текущей функции
  nSTableId = nSTableId || 1 
  var sST = sPrePrefix + nSTableId.toString() //название строковой таблицы этой функции
  var sSTk = sST + sPostPrefixKey //просто для уменьшения сложения строк в каждой новой итерации
  var sSTv = sST + sPostPrefixVal //просто для уменьшения сложения строк в каждой новой итерации

  var nKVIndex = 1 //текущий индекс пары Key-Val
  while(true){//Будем обходить все Key-Val пары sST строковой таблицы
    var CurrentKey, CurrentVal  //сюда собираем очередную пару
    //предпологаемая пара
    var CurrentSTk = stTable[sSTk + nKVIndex.toString()]  //предпологаемый ключ
    var CurrentSTv = stTable[sSTv + nKVIndex.toString()]  //предпологаемое значение

    if(CurrentSTk != undefined){  //есть ли предпологаемый ключ (это val строковой таблицы)
      if ((typeof(CurrentSTk) == 'string') && (CurrentSTk.substring(0, sPrePrefix.length) == sPrePrefix)){  //Если есть ожидаемый префикс
        //то расшифровываем очередную строковую таблицу в таблицу
        var nSTChildNumber = parseInt(CurrentSTk.substring(sPrePrefix.length, CurrentSTk.length))
        CurrentKey = StringTable2Table(stTable, nSTChildNumber)  //будет расшифровывать только свою и вложенные строковые таблицы
      }else{
        //иначе текущее значение ключа из пары Key-Val -> будет использовано в качестве ключа для результирующей таблицы
        CurrentKey = CurrentSTk
      }

      if((typeof(CurrentSTv) == 'string') && (CurrentSTv.substring(0, sPrePrefix.length) == sPrePrefix) ){
        var nSTChildNumber = parseInt(CurrentSTv.substring(sPrePrefix.length, CurrentSTv.length)) //берёт номер текущей строковой таблицы
        CurrentVal = StringTable2Table(stTable, nSTChildNumber)  //будет расшифровывать только указанную и вложенные строковые таблицы
      }else{
        CurrentVal = CurrentSTv
      }
    }else{
      break //если ключа нет, то и значения тоже, значит текущий индекс - пустой
    }

    hResult[CurrentKey] = CurrentVal  //записываем новую пару
    nKVIndex = nKVIndex + 1
  }
  return hResult
}

//$.Msg('Tdata = ', StringTable2Table(data))

