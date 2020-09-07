%dw 2.0

//APIkit OData Service creates a variable that contains the fields of your entity.
fun fields(odata: Object): Array<String> = odata.fields match {
  case fields is Array<String> -> fields
  else -> []
}

//APIkit OData Service creates a variable that contains the keys of the entity
fun keyNames(odata: Object): String = odata.keyNames match {
  case keyNames is String -> keyNames
  else -> ""
}

//APIkit OData Service creates a variable that contains the table's name
fun remoteEntityName(odata: Object): String = odata.remoteEntityName match {
  case remoteEntityName is String -> remoteEntityName
  else -> ""
}
