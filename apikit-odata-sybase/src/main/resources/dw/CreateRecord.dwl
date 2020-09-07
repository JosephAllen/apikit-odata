%dw 2.0

output application/java  

//This DataWeave generates a MySQL Insert Query from your payload and metadata
//APIkit Odata Service creates a variable that contains the table's name
var remoteEntityName = vars.odata.remoteEntityName match {
  case remoteEntityName is String -> remoteEntityName
  else -> ""
}

//Transform your payload into something like this: { myKey1: 'myValue1', myKey2: 'myValue2'}.
var valuesFromPayload = {
  keys: payload pluck $$,
  values: payload pluck "'$($)'"
}

//Then use joinBy to transform your keys and values into a CSV style
var columns = ((valuesFromPayload.keys map "`$($)`") joinBy ", ") //myKey1, myKey2

var values = (valuesFromPayload.values joinBy ", ") //'myValue1', 'myValue2'
---
//final expression is: INSERT INTO $remoteEntityName (myKey1, myKey2) VALUES ('myValue1', 'myValue2')
"INSERT INTO $(remoteEntityName) ($(columns)) VALUES ($(values))"
