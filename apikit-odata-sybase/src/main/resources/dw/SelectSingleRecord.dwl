%dw 2.0

output application/java  

//APIkit Odata Service creates a variable that contains the fields of your entity. It's a list of string (List<String>)
var entityFields: Array<String> = vars.odata.fields match {
  case fields is Array<String> -> fields
  else -> []
}

//APIkit Odata Service creates a variable that contains the table's name
var remoteEntityName = vars.odata.remoteEntityName match {
  case remoteEntityName is String -> remoteEntityName
  else -> ""
}

//This entity doesn't have an auto-generated PK so PK's value is in original payload.
var id = vars.id
---
"SELECT " ++ (entityFields joinBy ", ") ++ " FROM $(remoteEntityName) where CustomerID = '$(id)'"
