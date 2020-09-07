
# OData Syabse Example

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

``` raml
#%RAML 1.0 Library
uses:
  odata: libraries/odataLibrary.raml

types:
  ODemo:
    description: Example Table Exposed by OData
    (odata.remote): ODemo
    properties:
      Id:
        format: int32
        description: Primary key for OTest
        required: false
        type: number
        (odata.key): true
        (odata.nullable): false
      Name:
        type: string
        description: Name of OTest Record
        (odata.key): false
        (odata.nullable): false
```

You must annotate at least one of the properties on each `Entity` by using the annotation `(odata.key)`.

The following annotations are optional for each property:

- `(odata.nullable)`: bool
- `(odata.precision)`: int
- `(odata.scale)`: int

There's an optional `(odata.remote)` annotation for the `Entity`'s, that allow you to provide the name of the `Entity` in the remote data source.

## Known Issues

1. **MySQL Driver is missing Error**

 If your example project does not find MySQL Driver, you need to update your Maven dependencies:
  1. Mavenize your project (unless you have already imported it as a Maven-based Mule Project from pom.xml)
  2. Right click on your project -> Maven Support in Studio -> Update Project Dependencies.
