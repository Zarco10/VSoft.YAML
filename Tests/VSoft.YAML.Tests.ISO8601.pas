unit VSoft.YAML.Tests.ISO8601;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.DateUtils;

type
  [TestFixture]
  TTestISO8601DateTime = class
  private
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Basic date parsing tests
    [Test]
    procedure TestBasicDateOnly;
    [Test]
    procedure TestCompactDateFormat;
    [Test]
    procedure TestDateTimeWithT;
    [Test]
    procedure TestDateTimeWithSpace;

    // Time parsing tests
    [Test]
    procedure TestTimeWithColons;
    [Test]
    procedure TestTimeCompact;
    [Test]
    procedure TestTimeWithMilliseconds;
    [Test]
    procedure TestTimeWithCommaMilliseconds;

    // Timezone tests
    [Test]
    procedure TestUTCTimeZone;
    [Test]
    procedure TestPositiveTimeZone;
    [Test]
    procedure TestNegativeTimeZone;
    [Test]
    procedure TestCompactTimeZone;
    [Test]
    procedure TestTimeZoneConversion;

    // Edge cases
    [Test]
    procedure TestEmptyString;
    [Test]
    procedure TestLeapYear;
    [Test]
    procedure TestEndOfYear;
    [Test]
    procedure TestMidnight;
    [Test]
    procedure TestNoon;

    // Error cases
    [Test]
    procedure TestInvalidDate;
    [Test]
    procedure TestInvalidTime;
    [Test]
    procedure TestInvalidFormat;
    [Test]
    procedure TestInvalidMonth;
    [Test]
    procedure TestInvalidDay;

    // Complex formats
    [Test]
    procedure TestComplexISO8601Formats;
    [Test]
    procedure TestFractionalSecondsVariations;
  end;

implementation

uses
  VSoft.YAML.Utils;

{ TTestISO8601DateTime }

procedure TTestISO8601DateTime.Setup;
begin
  // Setup code if needed
end;

procedure TTestISO8601DateTime.TearDown;
begin
  // Teardown code if needed
end;


// Test implementations

procedure TTestISO8601DateTime.TestBasicDateOnly;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25', False);
  Assert.AreEqual(2023, YearOf(dt));
  Assert.AreEqual(12, MonthOf(dt));
  Assert.AreEqual(25, DayOf(dt));
  Assert.AreEqual(0, HourOf(dt));
  Assert.AreEqual(0, MinuteOf(dt));
  Assert.AreEqual(0, SecondOf(dt));
end;

procedure TTestISO8601DateTime.TestCompactDateFormat;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('20231225', False);
  Assert.AreEqual(2023, YearOf(dt));
  Assert.AreEqual(12, MonthOf(dt));
  Assert.AreEqual(25, DayOf(dt));
end;

procedure TTestISO8601DateTime.TestDateTimeWithT;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15', False);
  Assert.AreEqual(2023, YearOf(dt));
  Assert.AreEqual(12, MonthOf(dt));
  Assert.AreEqual(25, DayOf(dt));
  Assert.AreEqual(14, HourOf(dt));
  Assert.AreEqual(30, MinuteOf(dt));
  Assert.AreEqual(15, SecondOf(dt));
end;

procedure TTestISO8601DateTime.TestDateTimeWithSpace;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25 14:30:15', False);
  Assert.AreEqual(14, HourOf(dt));
  Assert.AreEqual(30, MinuteOf(dt));
  Assert.AreEqual(15, SecondOf(dt));
end;

procedure TTestISO8601DateTime.TestTimeWithColons;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-01-01T08:45:30', False);
  Assert.AreEqual(8, HourOf(dt));
  Assert.AreEqual(45, MinuteOf(dt));
  Assert.AreEqual(30, SecondOf(dt));
end;

procedure TTestISO8601DateTime.TestTimeCompact;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-01-01T084530', False);
  Assert.AreEqual(8, HourOf(dt));
  Assert.AreEqual(45, MinuteOf(dt));
  Assert.AreEqual(30, SecondOf(dt));
end;

procedure TTestISO8601DateTime.TestTimeWithMilliseconds;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-01-01T14:30:15.123', False);
  Assert.AreEqual(14, HourOf(dt));
  Assert.AreEqual(30, MinuteOf(dt));
  Assert.AreEqual(15, SecondOf(dt));
  Assert.AreEqual(123, MilliSecondOf(dt));
end;

procedure TTestISO8601DateTime.TestTimeWithCommaMilliseconds;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-01-01T14:30:15,456', False);
  Assert.AreEqual(456, MilliSecondOf(dt));
end;

procedure TTestISO8601DateTime.TestUTCTimeZone;
var
  dt1, dt2: TDateTime;
begin
  dt1 := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15Z', True);
  dt2 := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15Z', False);
  // Both should be the same since Z indicates UTC
  Assert.AreEqual(dt1, dt2, 0.0001); // Small tolerance for floating point comparison
end;

procedure TTestISO8601DateTime.TestPositiveTimeZone;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15+05:30', True);
  // Should convert to UTC by subtracting 5:30
  Assert.AreEqual(9, HourOf(dt));  // 14:30 - 5:30 = 09:00
  Assert.AreEqual(0, MinuteOf(dt));
end;

procedure TTestISO8601DateTime.TestNegativeTimeZone;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15-08:00', True);
  // Should convert to UTC by adding 8:00
  Assert.AreEqual(22, HourOf(dt));  // 14:30 + 8:00 = 22:30
  Assert.AreEqual(30, MinuteOf(dt));
end;

procedure TTestISO8601DateTime.TestCompactTimeZone;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15+0530', True);
  Assert.AreEqual(9, HourOf(dt));   // 14:30 - 5:30 = 09:00
  Assert.AreEqual(0, MinuteOf(dt));
end;

procedure TTestISO8601DateTime.TestTimeZoneConversion;
var
  dtUTC, dtLocal: TDateTime;
begin
  dtUTC := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15+02:00', True);
  dtLocal := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15+02:00', False);

  // UTC should be 2 hours earlier
  Assert.AreEqual(12, HourOf(dtUTC));   // 14:30 - 2:00 = 12:30
  Assert.AreEqual(30, MinuteOf(dtUTC));

  // Local should keep original time plus timezone adjustment
  Assert.AreEqual(16, HourOf(dtLocal)); // 14:30 + 2:00 = 16:30
  Assert.AreEqual(30, MinuteOf(dtLocal));
end;

procedure TTestISO8601DateTime.TestEmptyString;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('', False);
  Assert.AreEqual<TDateTime>(0, dt);
end;

procedure TTestISO8601DateTime.TestLeapYear;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2024-02-29', False);
  Assert.AreEqual(2024, YearOf(dt));
  Assert.AreEqual(2, MonthOf(dt));
  Assert.AreEqual(29, DayOf(dt));
end;

procedure TTestISO8601DateTime.TestEndOfYear;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-31T23:59:59', False);
  Assert.AreEqual(2023, YearOf(dt));
  Assert.AreEqual(12, MonthOf(dt));
  Assert.AreEqual(31, DayOf(dt));
  Assert.AreEqual(23, HourOf(dt));
  Assert.AreEqual(59, MinuteOf(dt));
  Assert.AreEqual(59, SecondOf(dt));
end;

procedure TTestISO8601DateTime.TestMidnight;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T00:00:00', False);
  Assert.AreEqual(0, HourOf(dt));
  Assert.AreEqual(0, MinuteOf(dt));
  Assert.AreEqual(0, SecondOf(dt));
end;

procedure TTestISO8601DateTime.TestNoon;
var
  dt: TDateTime;
begin
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T12:00:00', False);
  Assert.AreEqual(12, HourOf(dt));
  Assert.AreEqual(0, MinuteOf(dt));
  Assert.AreEqual(0, SecondOf(dt));
end;

procedure TTestISO8601DateTime.TestInvalidDate;
begin
  Assert.WillRaise(
    procedure
    begin
      TYAMLDateUtils.ISO8601StrToDateTime('invalid-date', False);
    end,
    Exception
  );
end;

procedure TTestISO8601DateTime.TestInvalidTime;
begin
  Assert.WillRaise(
    procedure
    begin
      TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T25:30:15', False);
    end,
    Exception
  );
end;

procedure TTestISO8601DateTime.TestInvalidFormat;
begin
  Assert.WillRaise(
    procedure
    begin
      TYAMLDateUtils.ISO8601StrToDateTime('2023/12/25', False);
    end,
    Exception
  );
end;

procedure TTestISO8601DateTime.TestInvalidMonth;
begin
  Assert.WillRaise(
    procedure
    begin
      TYAMLDateUtils.ISO8601StrToDateTime('2023-13-25', False);
    end,
    Exception
  );
end;

procedure TTestISO8601DateTime.TestInvalidDay;
begin
  Assert.WillRaise(
    procedure
    begin
      TYAMLDateUtils.ISO8601StrToDateTime('2023-02-30', False);
    end,
    Exception
  );
end;

procedure TTestISO8601DateTime.TestComplexISO8601Formats;
var
  dt: TDateTime;
begin
  // Test various complex but valid formats
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15.123Z', True);
  Assert.AreEqual(123, MilliSecondOf(dt));

  dt := TYAMLDateUtils.ISO8601StrToDateTime('20231225T143015Z', True);
  Assert.AreEqual(2023, YearOf(dt));
  Assert.AreEqual(14, HourOf(dt));

  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-12-25T14:30:15-05:00', True);
  Assert.AreEqual(19, HourOf(dt)); // 14 + 5 = 19
end;

procedure TTestISO8601DateTime.TestFractionalSecondsVariations;
var
  dt: TDateTime;
begin
  // Single digit
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-01-01T12:00:00.1', False);
  Assert.AreEqual(100, MilliSecondOf(dt));

  // Two digits
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-01-01T12:00:00.12', False);
  Assert.AreEqual(120, MilliSecondOf(dt));

  // Three digits
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-01-01T12:00:00.123', False);
  Assert.AreEqual(123, MilliSecondOf(dt));

  // More than three digits (should truncate)
  dt := TYAMLDateUtils.ISO8601StrToDateTime('2023-01-01T12:00:00.123456', False);
  Assert.AreEqual(123, MilliSecondOf(dt));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestISO8601DateTime);

end.
