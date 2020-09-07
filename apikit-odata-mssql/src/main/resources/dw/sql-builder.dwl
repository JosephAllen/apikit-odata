%dw 2.0
import * from dw::core::Objects
import modules::OData

output application/java  

var entityFields: Array<String> = OData::fields(vars.odata)

//APIkit OData Service creates a variable that contains the keys of your entity
var keys: String = OData::keyNames(vars.odata)

//APIkit OData Service creates a variable that contains the table's name
var remoteEntityName: String = OData::remoteEntityName(vars.odata)

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

var id: Strings = attributes.uriParams.CustomerID match {
  case id is String -> id
  else -> ""
}

//Create the WHERE clause portion of a SQL Statement
fun whereClause(): String =
  if (sizeOf(attributes.uriParams) > 0)
    " WHERE " ++ ((attributes.uriParams pluck (value, key) -> "`$(key)` = '$(value)'") joinBy " AND ")
  else
    ""

//Gets keys from the payload Object
fun columns(): String =
  (keySet(payload) map "`$($)`") joinBy ", "

//Gets values from the payload Object
fun columnValues(): String =
  (valueSet(payload) map "'$($)'") joinBy ", "

//Transforms the payload into something like myKey1 = 'myValue1', myKey2 = 'myValue2'
fun getUpdates(): String =
  (payload pluck (value, key) -> "`$(key)` = '$(value)'") joinBy ", "

//This function transforms the skip and top OData filters into MySQL LIMIT format.
fun toSQLSkipAndTop(top, skip): String =
  if (top != "" and skip != "")
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
fun selectedFields(): String =
  if (customSelect != "")
    (customSelect splitBy ",") -- (keys splitBy ",") ++ (keys splitBy ",")
  else
    entityFields map "`$($)`" joinBy ", "

//case "GET" -> "SELECT " ++ generateSqlFields(customSelect) ++ " FROM $(remoteEntityName)"
/*var generateSqlFields = (select) -> ((if (select != "")
((select splitBy ",") -- (keys splitBy ",") ++ (keys splitBy ","))
else
entityFields) map "`$($)`") joinBy ", "*/
fun SQL(): String =
  attributes.method match {
    case "DELETE" -> "DELETE " ++ " FROM $(remoteEntityName)"
    case "GET" -> "SELECT " ++ selectedFields() ++ " FROM $(remoteEntityName)"
    case "POST" -> "INSERT " ++ " INTO $(remoteEntityName)" ++ " ($(columns())) VALUES ($(columnValues()))"
    case "PUT" -> "UPDATE " ++ "$(remoteEntityName)" ++ " SET $(getUpdates())"
  }
---
SQL() ++ whereClause() ++ toSQLSkipAndTop(top, skip)
