%dw 2.0

output application/java  

//This DataWeave generates a SQL Anywhere Select Query from your metadata
//APIkit Odata Service creates a variable that contains the fields of your entity. It's a list of string (List<String>)
var entityFields: Array<String> = vars.odata.fields match {
  case fields is Array<String> -> fields
  else -> []
}

//APIkit Odata Service creates a variable that contains the keys of your entity
var keys: String = vars.odata.keyNames match {
  case keyNames is String -> keyNames
  else -> ""
}

//APIkit Odata Service creates a variable that contains the table's name
var remoteEntityName = vars.odata.remoteEntityName match {
  case remoteEntityName is String -> remoteEntityName
  else -> ""
}

//Generate the fields you need in the query.
//It checks for a select function in case you need less filters that you're actually exposing.
//If there is no select present, it just returns your fields defined in your metadata
var generateSqlFields = (select) -> ((if (select != "")
    ((select splitBy ",") -- (keys splitBy ",") ++ (keys splitBy ","))
  else
    entityFields) map "$($)") joinBy ", "

//Transform oDataFilters into SQL Anywhere Filters
var odataFilterToSQLFilter = (odataFilter) ->
odataFilter replace "eq null" with "is null"
    replace "ne null" with "is not null"
    replace " eq " with " = "
    replace " ne " with " != "
    replace " gt " with " > "
    replace " lt " with " < "
    replace " ge " with " >= "
    replace " le " with " <= "
    replace " and " with " AND "
    replace " or " with " OR "

//APIkit Odata Service puts your oData filters into the queryParams
var filters = attributes.queryParams

var top: String = filters.top match {
  case top is String -> top
  else -> ""
}

var skip: String = filters.skip match {
  case skip is String -> skip
  else -> ""
}

var select: String = filters.select match {
  case select is String -> select
  else -> ""
}

var filter: String = filters.filter match {
  case filter is String -> filter
  else -> ""
}

var orderby: String = filters.orderby match {
  case orderby is String -> orderby
  else -> ""
}

//This function transforms your orderby oData filters into SQL Anywhere Order by format.
//Transforms something like orderby=myField, ASC into ORDER BY myField, ASC
//If no orderby is present, it just returns an empty string
var toSQLOrderBy = (orderby) -> if (orderby != "")
    (" ORDER BY " ++ (orderby replace "=" with " "))
  else
    ""

//This function transforms your skip and top oData filters into SQL Anywhere LIMIT format.
var toSQLSkipAndTop = (top, skip) -> if (top != "" and skip != "")
    " LIMIT $(top) OFFSET $(skip)"
  else if (top == "" and skip != "")
    " LIMIT 2147483647 OFFSET $(skip)"
  else if (top != "" and skip == "")
    " LIMIT $(top)"
  else
    ""

//Generate the where part of your query.
var toSQLWhere = (odataFilter) -> if (odataFilter != "")
    " WHERE " ++ odataFilterToSQLFilter(odataFilter)
  else
    ""
---
"SELECT " ++ generateSqlFields(select) ++ " FROM $(remoteEntityName)" ++ ((toSQLWhere(filter)) ++ (toSQLOrderBy(orderby)) ++ (toSQLSkipAndTop(top, skip)))
