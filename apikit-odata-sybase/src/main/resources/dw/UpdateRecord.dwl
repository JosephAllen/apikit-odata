%dw 2.0

output application/java  

//This DataWeave generates a MySQL Update Query from your metadata for a particular entity
//APIkit Odata Service creates a variable that contains the table's name
var remoteEntityName = vars.odata.remoteEntityName match {
  case remoteEntityName is String -> remoteEntityName
  else -> ""
}

var id = attributes.uriParams.CustomerID match {
  case id is String -> id
  else -> ""
}

//Transform your payload (myKey1: myValue1, myKey2: myValue2) into something like myKey1 = 'myValue1', myKey2 = 'myValue2'
var sqlValues = (payload mapObject ((value, key) -> 
  "$(key)": "$(key) = '$(value)'"
)) pluck ((value, key, index) -> value) joinBy ","
---
"UPDATE $(remoteEntityName) SET $(sqlValues) WHERE CustomerID = '$(id)'"
