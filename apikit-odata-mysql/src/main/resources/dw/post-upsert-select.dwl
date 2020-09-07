%dw 2.0
import modules::OData
import * from dw::core::Objects

output application/java  

//APIkit Odata Service creates a variable that contains the fields of your entity.
var entityFields: Array<String> = OData::fields(vars.odata)

//APIkit OData Service creates a variable that contains the keys of your entity
var keys: String = OData::keyNames(vars.odata)

//APIkit Odata Service creates a variable that contains the table's name
var remoteEntityName: String = OData::remoteEntityName(vars.odata)

//This entity doesn't have an auto-generated PK so PK's value is in original payload.
var id = vars.id

//Get filter the payload just key fields
fun payloadKeys(): Object =
  vars.requestPayload filterObject ((value, key) -> keys splitBy "," contains key)

//Creates string for the where clause `fieldX` = 'feildValue'
fun whereKeys(): String =
  payloadKeys() pluck (value, key) -> "`$(key)` = '$(value)'" joinBy " AND "
---
"SELECT " ++ (entityFields joinBy ", ") ++ " FROM $(remoteEntityName) WHERE CustomerID = '$(whereKeys())'"
