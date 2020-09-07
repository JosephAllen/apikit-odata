%dw 2.0
import * from dw::core::Objects

output application/java  

//APIkit OData Service creates a variable that contains the fields of your entity. It's a list of string (List<String>)
var entityFields: Array<String> = vars.odata.fields match {
  case fields is Array<String> -> fields
  else -> []
}

//APIkit OData Service creates a variable that contains the keys of your entity
var keys: String = vars.odata.keyNames match {
  case keyNames is String -> keyNames
  else -> ""
}

//APIkit OData Service creates a variable that contains the table's name
var remoteEntityName = vars.odata.remoteEntityName match {
  case remoteEntityName is String -> remoteEntityName
  else -> ""
}

//APIkit OData Service puts your oData filters into the queryParams
var filters = attributes.queryParams

var top: String = filters.top match {
  case top is String -> top
  else -> ""
}

var skip: String = filters.skip match {
  case skip is String -> skip
  else -> ""
}

var customSelect: String = filters.select match {
  case select is String -> select
  else -> ""
}

var id = attributes.uriParams.CustomerID match {
  case id is String -> id
  else -> ""
}

var whereClause = if (sizeOf(attributes.uriParams) > 0)
  " WHERE " ++ ((attributes.uriParams pluck (value, key) -> "`$(key)` = '$(value)'") joinBy " AND ")
else
  ""

fun columns() =
  ((keySet(payload) map "`$($)`") joinBy ", ")

fun columnValues() =
  ((valueSet(payload) map "'$($)'") joinBy ", ")

//Transform your payload (myKey1: myValue1, myKey2: myValue2) into something like myKey1 = 'myValue1', myKey2 = 'myValue2'
fun getUpdates() =
  (payload pluck (value, key) -> "`$(key)` = '$(value)'") joinBy ", "

//This function transforms your skip and top OData filters into MySQL LIMIT format.
var toSQLSkipAndTop = (top, skip) -> if (top != "" and skip != "")
    " LIMIT $(top) OFFSET $(skip)"
  else if (top == "" and skip != "")
    " LIMIT 2147483647 OFFSET $(skip)"
  else if (top != "" and skip == "")
    " LIMIT $(top)"
  else
    ""

//Generate the fields you need in the query.
//It checks for a select function in case you need less filters that you're actually exposing.
//If there is no select present, it just returns your fields defined in your metadata
fun selectedFields() =
  if (customSelect != "")
    (customSelect splitBy ",") -- (keys splitBy ",") ++ (keys splitBy ",")
  else
    entityFields map "`$($)`" joinBy ", "

//case "GET" -> "SELECT " ++ generateSqlFields(customSelect) ++ " FROM $(remoteEntityName)"
/*var generateSqlFields = (select) -> ((if (select != "")
((select splitBy ",") -- (keys splitBy ",") ++ (keys splitBy ","))
else
entityFields) map "`$($)`") joinBy ", "*/
var SQL = attributes.method match {
  case "DELETE" -> "DELETE " ++ " FROM $(remoteEntityName)"
  case "GET" -> "SELECT " ++ selectedFields() ++ " FROM $(remoteEntityName)"
  case "POST" -> "INSERT " ++ " INTO $(remoteEntityName)" ++ " ($(columns())) VALUES ($(columnValues()))"
  case "PUT" -> "UPDATE " ++ "$(remoteEntityName)" ++ " SET $(getUpdates())"
}
---
SQL ++ whereClause ++ toSQLSkipAndTop(top, skip)
