
# Anypoint Template: APIkit OData Extension (SQL Server)

- [Use Case](#use-case)
- [Supported Runtimes](#supported-runtimes)
- [Model Definition](#model-definition)

## Use Case

This example is based on [this template](https://github.com/mulesoft/apikit-odata-template) and is designed to show how to create an OData API or a Custom DataGateway using APIKIT OData Extension.

## Supported Runtimes

This example runs on Mule:

- 4.2.2

## Model Definition

In this example we are using the following [OData RAML Type model](src/main/resources/api/odata.raml).

The model must be defined as a `RAML Library`, where each `DataType` represents an `EntityModel`, like:

### Model

``` yaml
#%RAML 1.0 Library
uses:
  odata: libraries/odataLibrary.raml

types:
  customers:
    (odata.remote): Customers
    properties:
      CustomerID:
        type: string
        (odata.key): true
        (odata.nullable): false
        maxLength: 5
      CompanyName:
        type: string
        (odata.nullable): true
        (odata.key): false
        maxLength: 40
        required: false
      ContactName:
        type: string
        (odata.nullable): true
        (odata.key): false
        maxLength: 30
        required: false
      ContactTitle:
        type: string
        (odata.nullable): true
        (odata.key): false
        maxLength: 30
        required: false
```

You must annotate at least one of the properties on each `Entity` by using the annotation `(odata.key)`.

The following annotations are optional for each property:

- `(odata.nullable)`: bool
- `(odata.precision)`: int
- `(odata.scale)`: int

There's an optional `(odata.remote)` annotation for the `Entity`'s, that allow you to provide the name of the `Entity` in the remote data source.

### Known Issue
