unit VSoft.YAML.Tests.JSON;

interface

uses
  DUnitX.TestFramework,
  VSoft.YAML;

type
  [TestFixture]
  TJSONParsingTests = class

  public

    [Test]
    procedure TestSimpleJSONObject;

    [Test]
    procedure TestJSONArray;

    [Test]
    procedure TestNestedJSONStructure;

    [Test]
    procedure TestJSONDataTypes;

    [Test]
    procedure TestJSONStringsWithEscapes;

    [Test]
    procedure TestJSONNumbers;

    [Test]
    procedure TestJSONBooleanAndNull;

    [Test]
    procedure TestComplexJSONExample;

  end;


implementation

uses 
  System.SysUtils;

{ TJSONParsingTests }

procedure TJSONParsingTests.TestSimpleJSONObject;
var
  jsonText: string;
  doc: IYAMLDocument;
begin
  jsonText := '{"name": "John Doe", "age": 30, "city": "New York"}';
  
  doc := TYAML.LoadFromString(jsonText);
  Assert.IsNotNull(doc.Root, 'LoadFromString returned null');
  Assert.AreEqual(TYAMLValueType.vtMapping, doc.Root.ValueType);
  
  Assert.AreEqual('John Doe', doc.Root.Values['name'].AsString);
  Assert.AreEqual<Int64>(30, doc.Root.Values['age'].AsInteger);
  Assert.AreEqual('New York', doc.Root.Values['city'].AsString);
end;

procedure TJSONParsingTests.TestJSONArray;
var
  jsonText: string;
  doc: IYAMLDocument;
  arrayValue: IYAMLSequence;
begin
  jsonText := '["apple", "banana", "cherry"]';
  
  doc := TYAML.LoadFromString(jsonText);
  Assert.IsNotNull(doc.Root, 'LoadFromString returned null');
  Assert.AreEqual(TYAMLValueType.vtSequence, doc.Root.ValueType);
  
  arrayValue := doc.Root.AsSequence;
  Assert.AreEqual(3, arrayValue.Count);
  Assert.AreEqual('apple', arrayValue.Items[0].AsString);
  Assert.AreEqual('banana', arrayValue.Items[1].AsString);
  Assert.AreEqual('cherry', arrayValue.Items[2].AsString);
end;

procedure TJSONParsingTests.TestNestedJSONStructure;
var
  jsonText: string;
  doc: IYAMLDocument;
begin
  jsonText := '{' +
    '"person": {' +
      '"name": "Jane Smith",' +
      '"age": 25,' +
      '"hobbies": ["reading", "swimming", "coding"]' +
    '},' +
    '"company": "ACME Corp",' +
    '"employees": [' +
      '{"name": "Alice", "role": "Developer"},' +
      '{"name": "Bob", "role": "Designer"}' +
    ']' +
  '}';
  
  doc := TYAML.LoadFromString(jsonText);
  Assert.IsNotNull(doc.Root, 'LoadFromString returned null');
  Assert.AreEqual(TYAMLValueType.vtMapping, doc.Root.ValueType);
  
  Assert.AreEqual('Jane Smith', doc.Root.Values['person'].Values['name'].AsString);
  Assert.AreEqual<Int64>(25, doc.Root.Values['person'].Values['age'].AsInteger);
  Assert.AreEqual('ACME Corp', doc.Root.Values['company'].AsString);
  Assert.AreEqual(2, doc.Root.Values['employees'].AsSequence.Count);
  Assert.AreEqual(3, doc.Root.Values['person'].Values['hobbies'].AsSequence.Count);
end;

procedure TJSONParsingTests.TestJSONDataTypes;
var
  jsonText: string;
  doc: IYAMLDocument;
begin
  jsonText := '{' +
    '"nullValue": null,' +
    '"boolTrue": true,' +
    '"boolFalse": false,' +
    '"intValue": 42,' +
    '"floatValue": 3.14159,' +
    '"stringValue": "Hello World"' +
  '}';
  
  doc := TYAML.LoadFromString(jsonText);
  Assert.IsNotNull(doc.Root, 'LoadFromString returned null');
  
  Assert.IsTrue(doc.Root.Values['nullValue'].IsNull);
  Assert.AreEqual(true, doc.Root.Values['boolTrue'].AsBoolean);
  Assert.AreEqual(false, doc.Root.Values['boolFalse'].AsBoolean);
  Assert.AreEqual<Int64>(42, doc.Root.Values['intValue'].AsInteger);
  Assert.AreEqual(3.14159, doc.Root.Values['floatValue'].AsFloat, 0.00001);
  Assert.AreEqual('Hello World', doc.Root.Values['stringValue'].AsString);
end;

procedure TJSONParsingTests.TestJSONStringsWithEscapes;
var
  jsonText: string;
  doc: IYAMLDocument;
begin
  jsonText := '{' +
    '"escaped": "Line 1\nLine 2\tTabbed",' +
    '"quotes": "She said, \"Hello!\"",' +
    '"unicode": "Caf\u00e9"' +
  '}';

  doc := TYAML.LoadFromString(jsonText);
  Assert.IsNotNull(doc.Root, 'LoadFromString returned null');

  // YAML parser preserves JSON escape sequences as literal strings
  Assert.AreEqual('Line 1' + #10 + 'Line 2' + #9 + 'Tabbed', doc.Root.Values['escaped'].AsString);
  Assert.AreEqual('She said, "Hello!"', doc.Root.Values['quotes'].AsString);
  Assert.AreEqual('Café', doc.Root.Values['unicode'].AsString);
end;

procedure TJSONParsingTests.TestJSONNumbers;
var
  jsonText: string;
  doc: IYAMLDocument;
begin
  jsonText := '{' +
    '"positiveInt": 123,' +
    '"negativeInt": -456,' +
    '"positiveFloat": 12.34,' +
    '"negativeFloat": -56.78,' +
    '"scientificNotation": 1.23e4,' +
    '"zero": 0' +
  '}';
  
  doc := TYAML.LoadFromString(jsonText);
  Assert.IsNotNull(doc.Root, 'LoadFromString returned null');
  
  Assert.AreEqual<Int64>(123, doc.Root.Values['positiveInt'].AsInteger);
  Assert.AreEqual<Int64>(-456, doc.Root.Values['negativeInt'].AsInteger);
  Assert.AreEqual(12.34, doc.Root.Values['positiveFloat'].AsFloat, 0.01);
  Assert.AreEqual(-56.78, doc.Root.Values['negativeFloat'].AsFloat, 0.01);
  Assert.AreEqual(12300.0, doc.Root.Values['scientificNotation'].AsFloat, 0.1);
  Assert.AreEqual<Int64>(0, doc.Root.Values['zero'].AsInteger);
end;

procedure TJSONParsingTests.TestJSONBooleanAndNull;
var
  jsonText: string;
  doc: IYAMLDocument;
begin
  jsonText := '{' +
    '"isTrue": true,' +
    '"isFalse": false,' +
    '"isNull": null' +
  '}';
  
  doc := TYAML.LoadFromString(jsonText);
  Assert.IsNotNull(doc.Root, 'LoadFromString returned null');
  
  Assert.AreEqual(true, doc.Root.Values['isTrue'].AsBoolean);
  Assert.AreEqual(false, doc.Root.Values['isFalse'].AsBoolean);
  Assert.IsTrue(doc.Root.Values['isNull'].IsNull);
end;

procedure TJSONParsingTests.TestComplexJSONExample;
var
  jsonText: string;
  doc: IYAMLDocument;
  addressValue: IYAMLMapping;
  phoneNumbers: IYAMLSequence;
begin
  jsonText := '{' +
    '"firstName": "John",' +
    '"lastName": "Smith",' +
    '"age": 35,' +
    '"address": {' +
      '"streetAddress": "123 Main St",' +
      '"city": "Anytown",' +
      '"state": "NY",' +
      '"postalCode": "12345"' +
    '},' +
    '"phoneNumbers": [' +
      '{"type": "home", "number": "555-1234"},' +
      '{"type": "work", "number": "555-5678"}' +
    '],' +
    '"isMarried": true,' +
    '"spouse": null' +
  '}';
  
  doc := TYAML.LoadFromString(jsonText);
  Assert.IsNotNull(doc.Root, 'LoadFromString returned null');
  
  Assert.AreEqual('John', doc.Root.Values['firstName'].AsString);
  Assert.AreEqual('Smith', doc.Root.Values['lastName'].AsString);
  Assert.AreEqual<Int64>(35, doc.Root.Values['age'].AsInteger);
  
  addressValue := doc.Root.Values['address'].AsMapping;
  Assert.AreEqual('123 Main St', addressValue.Values['streetAddress'].AsString);
  Assert.AreEqual('Anytown', addressValue.Values['city'].AsString);
  Assert.AreEqual('NY', addressValue.Values['state'].AsString);
  Assert.AreEqual('12345', addressValue.Values['postalCode'].AsString);
  
  phoneNumbers := doc.Root.Values['phoneNumbers'].AsSequence;
  Assert.AreEqual(2, phoneNumbers.Count);
  Assert.AreEqual('home', phoneNumbers.Items[0].Values['type'].AsString);
  Assert.AreEqual('555-1234', phoneNumbers.Items[0].Values['number'].AsString);
  Assert.AreEqual('work', phoneNumbers.Items[1].Values['type'].AsString);
  Assert.AreEqual('555-5678', phoneNumbers.Items[1].Values['number'].AsString);
  
  Assert.AreEqual(true, doc.Root.Values['isMarried'].AsBoolean);
  Assert.IsTrue(doc.Root.Values['spouse'].IsNull);
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONParsingTests);

end.